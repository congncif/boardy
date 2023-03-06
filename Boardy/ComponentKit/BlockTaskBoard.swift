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

    public let input: Input

    public private(set) var successHandler: SuccessHandler?
    public private(set) var processingHandler: ProcessingHandler?
    public private(set) var errorHandler: ErrorHandler?
    public private(set) var completionHandler: CompletionHandler?

    public typealias SuccessHandler = (ActivatableBoard, Output) -> Void
    public typealias ProcessingHandler = (ActivatableBoard, Bool) -> Void
    public typealias ErrorHandler = (ActivatableBoard, Error) -> Void
    public typealias CompletionHandler = (ActivatableBoard, TaskCompletionStatus) -> Void
}

public extension BlockTaskParameter {
    func appendingSuccessHandler(_ handler: @escaping SuccessHandler) -> Self {
        let currentHandler = successHandler
        return onSuccess { board, output in
            currentHandler?(board, output)
            handler(board, output)
        }
    }

    func appendingErrorHandler(_ handler: @escaping ErrorHandler) -> Self {
        let currentHandler = errorHandler
        return onError { board, output in
            currentHandler?(board, output)
            handler(board, output)
        }
    }

    func appendingCompletionHandler(_ handler: @escaping CompletionHandler) -> Self {
        let currentHandler = completionHandler
        return onCompletion { board, output in
            currentHandler?(board, output)
            handler(board, output)
        }
    }

    func appendingProcessingHandler(_ handler: @escaping ProcessingHandler) -> Self {
        let currentHandler = processingHandler
        return onProcessing { board, output in
            currentHandler?(board, output)
            handler(board, output)
        }
    }
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

public extension BlockTaskParameter where Input == Void {
    convenience init() {
        self.init(input: ())
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

public extension BlockTaskBoard {
    convenience init(identifier: BoardID,
                     executingType: ExecutingType = .default,
                     execute work: @escaping (BlockTaskBoard<Input, Output>, Input, @escaping ExecutorCompletion) -> Void) {
        self.init(identifier: identifier, executingType: executingType, executor: { board, input, completion in
            work(board, input, completion)
            return .none
        })
    }
}

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

public final class BlockTaskBoard<Input, Output>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    public typealias InputType = BlockTaskParameter<Input, Output>
    public typealias OutputType = Output

    public typealias ExecutorCompletion = (Result<Output, Error>) -> Void
    public typealias Executor = (BlockTaskBoard<Input, Output>, Input, @escaping ExecutorCompletion) -> BlockTaskCanceler

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
        case .latest:
            operationQueue.maxConcurrentOperationCount = 1
        default:
            break
        }

        super.init(identifier: identifier)
    }

    deinit {
        cancelPendingTasksIfNeeded()
    }

    // FIXME: - not working?
    public var inputAdapters: [(Any?) -> BlockTaskParameter<Input, Output>?] {
        [{ input in
            guard let input = input as? Input else {
                return nil
            }
            return BlockTaskParameter<Input, Output>(input: input)
        }]
    }

    public func activate(withGuaranteedInput input: InputType) {
        let taskID = UUID().uuidString

        func startOperationTask() {
            saveHandler(of: input, to: taskID)
            startProgressIfNeeded(with: taskID)

            let operation = BlockTaskExecutionOperation(taskID: taskID, input: input.input, taskBoard: self)
            operationQueue.addOperation(operation)
        }

        switch executingType {
        case .latest:
            cancelPendingTasksIfNeeded()
            startOperationTask()
            return
        case .concurrent:
            startOperationTask()
            return
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
        case .default:
            break
        }

        saveHandler(of: input, to: taskID)
        startProgressIfNeeded(with: taskID)

        _ = execute(input: input.input) { [weak self] result in
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
        // Cancel pending operations
        operationQueue.cancelAllOperations()

        // Send cancel feedback to the pending tasks
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
                complete(true)
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
            _ = execute(input: nextInput) { [weak self] nextResult in
                self?.finishExecuting(taskID: nextID, result: nextResult)
            }
        }
    }

    func execute(input: Input, completion: @escaping (Result<Output, Error>) -> Void) -> BlockTaskCanceler {
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

final class BlockTaskExecutionOperation<In, Out>: Operation {
    private let taskID: String
    private let input: In
    private weak var taskBoard: BlockTaskBoard<In, Out>?

    init(taskID: String, input: In, taskBoard: BlockTaskBoard<In, Out>) {
        self.taskBoard = taskBoard
        self.taskID = taskID
        self.input = input
        super.init()
    }

    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"

        fileprivate var keyPath: String { "is" + rawValue }
    }

    /// Thread-safe computed state value
    var state: State {
        get {
            stateQueue.sync {
                stateStore
            }
        }
        set {
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier) {
                stateStore = newValue
            }
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    private let stateQueue = DispatchQueue(label: "boardy.block-task-board.operation", attributes: .concurrent)

    /// Non thread-safe state storage, use only with locks
    private var stateStore: State = .ready

    private var canceler: BlockTaskCanceler?

    override var isAsynchronous: Bool {
        true
    }

    override var isExecuting: Bool {
        state == .executing
    }

    override var isFinished: Bool {
        state == .finished
    }

    override func cancel() {
        canceler?.cancel()
        state = .finished
    }

    override func start() {
        if isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }

    override func main() {
        if isCancelled {
            state = .finished
        } else {
            if let task = taskBoard {
                state = .executing
                canceler = task.execute(input: input) { [weak task, weak self, taskID] nextResult in
                    guard let currentTask = task else {
                        self?.state = .finished
                        return
                    }
                    currentTask.finishExecuting(taskID: taskID, result: nextResult)
                    self?.state = .finished
                }
            } else {
                state = .finished
            }
        }
    }
}

// public protocol TaskCancelable {
//    func cancel()
// }

public extension BlockTaskCanceler {
    static var none: BlockTaskCanceler {
        BlockTaskCanceler(handler: {})
    }

    static func `default`(handler: @escaping () -> Void) -> BlockTaskCanceler {
        BlockTaskCanceler(handler: handler)
    }
}

public struct BlockTaskCanceler {
    let handler: () -> Void

    public init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    public func cancel() {
        handler()
    }
}
