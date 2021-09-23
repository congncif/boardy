//
//  BlockTaskBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/20/21.
//

import Foundation

public final class BlockTaskParameter<Input, Output> {
    public init(input: Input) {
        self.input = input
    }

    public func onSuccess(_ handler: SuccessHandler?) -> Self {
        successHandler = handler
        return self
    }

    public func onSuccess(_ handler: ((Output) -> Void)?) -> Self {
        successHandler = { _, output in
            handler?(output)
        }
        return self
    }

    public func onSuccess<Target>(target: Target, action: ((Target, Output) -> Void)?) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        return onSuccess { [box] output in
            guard let action = action, let target = box.unboxed(Target.self) else { return }
            action(target, output)
        }
    }

    public func onProcessing(_ handler: ProcessingHandler?) -> Self {
        processingHandler = handler
        return self
    }

    public func onProcessing(_ handler: ((Bool) -> Void)?) -> Self {
        processingHandler = { _, inProgress in
            handler?(inProgress)
        }
        return self
    }

    public func onProcessing<Target>(target: Target, action: ((Target, Bool) -> Void)?) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        return onProcessing { [box] output in
            guard let action = action, let target = box.unboxed(Target.self) else { return }
            action(target, output)
        }
    }

    public func onError(_ handler: ErrorHandler?) -> Self {
        errorHandler = handler
        return self
    }

    public func onError(_ handler: ((Error) -> Void)?) -> Self {
        errorHandler = { _, error in
            handler?(error)
        }
        return self
    }

    public func onError<Target>(target: Target, action: ((Target, Error) -> Void)?) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        return onError { [box] output in
            guard let action = action, let target = box.unboxed(Target.self) else { return }
            action(target, output)
        }
    }

    public func onCompletion(_ handler: CompletionHandler?) -> Self {
        completionHandler = handler
        return self
    }

    public func onCompletion(_ handler: ((TaskCompletionStatus) -> Void)?) -> Self {
        completionHandler = { _, status in handler?(status) }
        return self
    }

    public func onCompletion<Target>(target: Target, action: ((Target, TaskCompletionStatus) -> Void)?) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        return onCompletion { [box] status in
            guard let action = action, let target = box.unboxed(Target.self) else { return }
            action(target, status)
        }
    }

    let input: Input

    var successHandler: SuccessHandler?
    var processingHandler: ProcessingHandler?
    var errorHandler: ErrorHandler?
    var completionHandler: CompletionHandler?

    public typealias SuccessHandler = (ActivatableBoard, Output) -> Void
    public typealias ProcessingHandler = (ActivatableBoard, Bool) -> Void
    public typealias ErrorHandler = (ActivatableBoard, Error) -> Void
    public typealias CompletionHandler = (ActivatableBoard, TaskCompletionStatus) -> Void
}

public enum TaskCompletionStatus {
    case done
    case cancelled
}

public extension BlockTaskParameter where Input: ExpressibleByNilLiteral {
    convenience init() {
        self.init(input: nil)
    }
}

struct BlockHandler<Input, Output> {
    typealias SuccessHandler = BlockTaskParameter<Input, Output>.SuccessHandler
    typealias ProcessingHandler = BlockTaskParameter<Input, Output>.ProcessingHandler
    typealias ErrorHandler = BlockTaskParameter<Input, Output>.ErrorHandler
    typealias CompletionHandler = BlockTaskParameter<Input, Output>.CompletionHandler

    let input: Input

    let successHandler: SuccessHandler?
    let processingHandler: ProcessingHandler?
    let errorHandler: ErrorHandler?
    let completionHandler: CompletionHandler?
}

public final class BlockTaskBoard<Input, Output>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    public typealias InputType = BlockTaskParameter<Input, Output>
    public typealias OutputType = Output

    public typealias ExecutorCompletion = (Result<Output, Error>) -> Void
    public typealias Executor = (BlockTaskBoard<Input, Output>, Input, @escaping ExecutorCompletion) -> Void

    public enum ExecutingType {
        /// Tasks run independently
        case `default`

        /// Only one latest task will be observed, all previous pending tasks will be cancelled.
        case latest

        /// Only one task run at the moment, all tasks activate while current task incomplete will be cancelled intermediately.
        case only

        /// The first result will be returned for all pending tasks, the input of the pending tasks after current task may be not used.
        case onlyResult

        /// Tasks run under FIFO
        case queue

        /// Schedule tasks with max concurrent operations
        case concurrent(max: Int)

        /// concurrent type with default max concurrent operation count
        public static var concurrent: ExecutingType { .concurrent(max: 3) }
    }

    private let executor: Executor
    private let executingType: ExecutingType
    private let operationQueue: OperationQueue

    public init(identifier: BoardID,
                executingType: ExecutingType = .default,
                executor: @escaping Executor) {
        self.executor = executor
        self.executingType = executingType
        operationQueue = OperationQueue()
        operationQueue.name = "boardy.block-task-board.operation.queue"
        operationQueue.qualityOfService = .utility

        switch executingType {
        case let .concurrent(max):
            operationQueue.maxConcurrentOperationCount = max
        default:
            break
        }

        super.init(identifier: identifier)
    }

    deinit {
        cancelPendingTasksIfNeeded()
        operationQueue.cancelAllOperations()
    }

    public func activate(withGuaranteedInput input: InputType) {
        let taskID = UUID().uuidString

        switch executingType {
        case .latest:
            cancelPendingTasksIfNeeded()
        case .onlyResult, .queue:
            if !isCompleted {
                // Add to pending tasks & wait current task complete
                saveHandler(of: input, to: taskID)
                startProgressIfNeeded(with: taskID)
                return
            }
        case .only:
            if !isCompleted {
                input.completionHandler?(self, .cancelled)
                return
            }
        case .concurrent:
            saveHandler(of: input, to: taskID)
            startProgressIfNeeded(with: taskID)

            let operation = ExecutionSchedulerOperation(taskID: taskID, input: input.input, taskBoard: self)
            operationQueue.addOperation(operation)
            return
        case .default:
            break
        }

        saveHandler(of: input, to: taskID)
        startProgressIfNeeded(with: taskID)

        execute(input: input.input) { [weak self] result in
            self?.finishExecuting(taskID: taskID, result: result)
        }
    }

    private func saveHandler(of input: InputType, to taskID: String) {
        let handler = BlockHandler<Input, Output>(input: input.input, successHandler: input.successHandler, processingHandler: input.processingHandler, errorHandler: input.errorHandler, completionHandler: input.completionHandler)
        appendNewTask(taskID: taskID, handler: handler)
    }

    private func startProgressIfNeeded(with taskID: String) {
        if let processHandler = getHandler(forKey: taskID)?.processingHandler {
            processHandler(self, true)
        }
    }

    private func endProgressIfNeeded(with taskID: String) {
        if let processHandler = getHandler(forKey: taskID)?.processingHandler {
            processHandler(self, false)
        }
    }

    private func cancelPendingTasksIfNeeded() {
        // Cancel pending tasks
        if !isCompleted {
            for (key, _) in completions {
                completeTask(key, status: .cancelled)
            }
        }
    }

    private func completeTask(_ taskID: String, status: TaskCompletionStatus = .done) {
        endProgressIfNeeded(with: taskID)

        if let completionHandler = getHandler(forKey: taskID)?.completionHandler {
            completionHandler(self, status)
        }

        if getHandler(forKey: taskID) != nil {
            removeTask(taskID: taskID)
        }
    }

    private func handleResult(_ result: Result<Output, Error>, with taskID: String) {
        switch result {
        case let .success(output):
            if let successHandler = getHandler(forKey: taskID)?.successHandler {
                successHandler(self, output)
            }

            sendOutput(output)
        case let .failure(error):
            if let errorHandler = getHandler(forKey: taskID)?.errorHandler {
                errorHandler(self, error)
            }
        }
    }

    func finishExecuting(taskID: String, result: Result<Output, Error>) {
        defer {
            if isCompleted {
                complete()
            }
        }

        switch executingType {
        case .onlyResult:
            handleResult(result, with: taskID)
            completeTask(taskID)

            // Complete pending tasks
            for (key, _) in completions {
                handleResult(result, with: key)
                completeTask(key)
            }
        case .default, .latest, .only, .concurrent:
            handleResult(result, with: taskID)
            completeTask(taskID)
        case .queue:
            handleResult(result, with: taskID)
            completeTask(taskID)

            guard let info = getFirstTaskInfo() else {
                return // All tasks done
            }

            let nextID = info.taskID
            let nextInput = info.handler.input
            execute(input: nextInput) { [weak self] nextResult in
                self?.finishExecuting(taskID: nextID, result: nextResult)
            }
        }
    }

    func execute(input: Input, completion: @escaping (Result<Output, Error>) -> Void) {
        executor(self, input, completion)
    }

    // MARK: - Access shared data

    private var completions: [String: BlockHandler<Input, Output>] = [:]
    private var taskIDs: [String] = []

    private let syncQueue = DispatchQueue(label: "boardy.block-task-board.sync-queue")

    private func removeTask(taskID: String) {
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            self.taskIDs.removeAll { $0 == taskID }
            self.completions.removeValue(forKey: taskID)
        }
    }

    private func appendNewTask(taskID: String, handler: BlockHandler<Input, Output>) {
        syncQueue.sync { [weak self] in
            guard let self = self else { return }
            self.taskIDs.append(taskID)
            self.completions[taskID] = handler
        }
    }

    private func getHandler(forKey key: String) -> BlockHandler<Input, Output>? {
        syncQueue.sync {
            completions[key]
        }
    }

    private func getFirstTaskInfo() -> (taskID: String, handler: BlockHandler<Input, Output>)? {
        syncQueue.sync {
            guard let firstID = taskIDs.first, let handler = completions[firstID] else {
                return nil
            }
            return (firstID, handler)
        }
    }

    private var isCompleted: Bool {
        syncQueue.sync {
            completions.isEmpty
        }
    }
}

final class ExecutionSchedulerOperation<In, Out>: Operation {
    private let taskID: String
    private let input: In
    private weak var taskBoard: BlockTaskBoard<In, Out>?

    init(taskID: String, input: In, taskBoard: BlockTaskBoard<In, Out>) {
        self.taskBoard = taskBoard
        self.taskID = taskID
        self.input = input
        super.init()
    }

    enum State {
        case ready
        case executing
        case finished
    }

    var state: State = .ready

    override var isExecuting: Bool {
        state == .executing
    }

    override var isFinished: Bool {
        state == .finished
    }

    override func cancel() {
        state = .finished
    }

    override func start() {
        if isCancelled {
            state = .finished
            return
        }

        state = .executing
        main()
    }

    override func main() {
        if let task = taskBoard {
            task.execute(input: input) { [weak task, weak self, taskID] nextResult in
                guard let currentTask = task else {
                    self?.state = .finished
                    return
                }
                task?.finishExecuting(taskID: taskID, result: nextResult)
                self?.state = .finished
            }
        } else {
            state = .finished
        }
    }
}
