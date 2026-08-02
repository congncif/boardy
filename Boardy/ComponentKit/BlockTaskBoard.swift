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

private enum TaskTerminalReason {
    case completed
    case cancelled
}

private enum CancelerInstallDisposition {
    case installed
    case invokeImmediately
    case discard
}

private enum DirectCancelerState {
    case notApplicable
    case notStarted
    case awaitingInstallation
    case installed(BlockTaskCanceler)
}

private struct TaskRecord<Input, Output> {
    let taskID: String
    let handler: BlockHandler<Input, Output>
    var directCancelerState: DirectCancelerState

    var installedDirectCanceler: BlockTaskCanceler? {
        guard case let .installed(canceler) = directCancelerState else {
            return nil
        }
        return canceler
    }
}

private struct TaskTerminalTransition<Input, Output> {
    let records: [TaskRecord<Input, Output>]
    let becameTerminallyEmpty: Bool
}

private struct TaskStore<Input, Output> {
    private var orderedTaskIDs: [String] = []
    private var records: [String: TaskRecord<Input, Output>] = [:]
    private var pendingInstallationTombstones: [String: TaskTerminalReason] = [:]
    private var terminalDeliveryReservations = 0

    var hasActiveTasks: Bool {
        !orderedTaskIDs.isEmpty
    }

    var canStartQueuedTask: Bool {
        !hasActiveTasks && terminalDeliveryReservations == 0
    }

    mutating func append(_ record: TaskRecord<Input, Output>) {
        orderedTaskIDs.append(record.taskID)
        records[record.taskID] = record
    }

    mutating func markDirectExecutionStarted(for taskID: String) -> TaskRecord<Input, Output>? {
        guard var record = records[taskID], case .notStarted = record.directCancelerState else {
            return nil
        }
        record.directCancelerState = .awaitingInstallation
        records[taskID] = record
        return record
    }

    mutating func transition(
        _ taskID: String,
        terminal reason: TaskTerminalReason
    ) -> TaskTerminalTransition<Input, Output>? {
        guard let record = records.removeValue(forKey: taskID) else {
            return nil
        }

        orderedTaskIDs.removeAll { $0 == taskID }
        if case .awaitingInstallation = record.directCancelerState {
            pendingInstallationTombstones[taskID] = reason
        }

        return TaskTerminalTransition(
            records: [record],
            becameTerminallyEmpty: orderedTaskIDs.isEmpty
        )
    }

    mutating func transitionAll(
        terminal reason: TaskTerminalReason
    ) -> TaskTerminalTransition<Input, Output> {
        guard !orderedTaskIDs.isEmpty else {
            return TaskTerminalTransition(records: [], becameTerminallyEmpty: false)
        }

        let transitionedRecords = orderedTaskIDs.compactMap { records[$0] }
        for record in transitionedRecords where record.directCancelerState.isAwaitingInstallation {
            pendingInstallationTombstones[record.taskID] = reason
        }
        orderedTaskIDs.removeAll()
        records.removeAll()

        return TaskTerminalTransition(records: transitionedRecords, becameTerminallyEmpty: true)
    }

    mutating func firstPending() -> TaskRecord<Input, Output>? {
        guard let taskID = orderedTaskIDs.first else {
            return nil
        }
        return records[taskID]
    }

    mutating func reserveTerminalDelivery() {
        terminalDeliveryReservations += 1
    }

    mutating func resolveTerminalDelivery(
        releasingReservation: Bool
    ) -> (nextRecord: TaskRecord<Input, Output>?, isTerminallyEmpty: Bool) {
        if releasingReservation {
            assert(terminalDeliveryReservations > 0)
            terminalDeliveryReservations -= 1
        }

        guard terminalDeliveryReservations == 0 else {
            return (nil, false)
        }
        if let pending = firstPending() {
            if let nextRecord = markDirectExecutionStarted(for: pending.taskID) {
                return (nextRecord, false)
            }
            return (nil, false)
        }
        return (nil, !hasActiveTasks)
    }

    mutating func installCanceler(
        _ canceler: BlockTaskCanceler,
        for taskID: String
    ) -> CancelerInstallDisposition {
        if var record = records[taskID] {
            guard case .awaitingInstallation = record.directCancelerState else {
                return .discard
            }
            record.directCancelerState = .installed(canceler)
            records[taskID] = record
            return .installed
        }

        guard let reason = pendingInstallationTombstones.removeValue(forKey: taskID) else {
            return .discard
        }
        switch reason {
        case .cancelled:
            return .invokeImmediately
        case .completed:
            return .discard
        }
    }
}

private extension DirectCancelerState {
    var isAwaitingInstallation: Bool {
        if case .awaitingInstallation = self {
            return true
        }
        return false
    }
}

public final class BlockTaskBoard<Input, Output>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    public typealias InputType = BlockTaskParameter<Input, Output>
    public typealias OutputType = Output

    public typealias ExecutorCompletion = (Result<Output, Error>) -> Void
    public typealias Executor = (BlockTaskBoard<Input, Output>, Input, @escaping ExecutorCompletion) -> BlockTaskCanceler

    private let executor: Executor
    private let executingType: ExecutingType
    private let operationQueue: OperationQueue
    private let allowBypassGatewayBarrier: Bool
    private let taskStore = Locked(TaskStore<Input, Output>())

    public init(identifier: BoardID,
                executingType: ExecutingType,
                allowBypassGatewayBarrier: Bool = true,
                executor: @escaping Executor) {
        self.executor = executor
        self.executingType = executingType
        operationQueue = OperationQueue()
        operationQueue.name = "boardy.block-task-board.operation.queue"
        operationQueue.qualityOfService = .userInitiated
        self.allowBypassGatewayBarrier = allowBypassGatewayBarrier

        switch executingType {
        case let .concurrent(max):
            operationQueue.maxConcurrentOperationCount = Swift.max(1, max)
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

    public func shouldBypassGatewayBarrier() -> Bool {
        allowBypassGatewayBarrier
    }

    public func activate(withGuaranteedInput input: InputType) {
        let taskID = UUID().uuidString
        let handler = BlockHandler(
            input: input.input,
            successHandler: input.successHandler,
            processingHandler: input.processingHandler,
            errorHandler: input.errorHandler,
            completionHandler: input.completionHandler
        )

        switch executingType {
        case .latest:
            cancelPendingTasksIfNeeded()
            startOperationTask(taskID: taskID, handler: handler)
        case .concurrent:
            startOperationTask(taskID: taskID, handler: handler)
        case .onlyResult, .queue:
            let shouldStart = taskStore.withLock { store in
                let shouldStart = store.canStartQueuedTask
                let cancelerState: DirectCancelerState = shouldStart ? .awaitingInstallation : .notStarted
                store.append(TaskRecord(taskID: taskID, handler: handler, directCancelerState: cancelerState))
                return shouldStart
            }
            handler.processingHandler?(self, true)
            if shouldStart {
                executeDirectTask(taskID: taskID, input: handler.input)
            }
        case .only:
            let accepted = taskStore.withLock { store in
                guard !store.hasActiveTasks else { return false }
                store.append(TaskRecord(taskID: taskID, handler: handler, directCancelerState: .awaitingInstallation))
                return true
            }
            guard accepted else {
                input.completionHandler?(self, .cancelled)
                return
            }
            handler.processingHandler?(self, true)
            executeDirectTask(taskID: taskID, input: handler.input)
        case .default:
            taskStore.withLock { store in
                store.append(TaskRecord(taskID: taskID, handler: handler, directCancelerState: .awaitingInstallation))
            }
            handler.processingHandler?(self, true)
            executeDirectTask(taskID: taskID, input: handler.input)
        }
    }

    private func startOperationTask(taskID: String, handler: BlockHandler<Input, Output>) {
        taskStore.withLock { store in
            store.append(TaskRecord(taskID: taskID, handler: handler, directCancelerState: .notApplicable))
        }
        handler.processingHandler?(self, true)

        let operation = BlockTaskExecutionOperation(taskID: taskID, input: handler.input, taskBoard: self)
        operationQueue.addOperation(operation)
    }

    private func executeDirectTask(taskID: String, input: Input) {
        let canceler = execute(input: input) { [weak self] result in
            self?.finishExecuting(taskID: taskID, result: result)
        }
        let disposition = taskStore.withLock { store in
            store.installCanceler(canceler, for: taskID)
        }
        if disposition == .invokeImmediately {
            canceler.cancel()
        }
    }

    func cancelPendingTasksIfNeeded() {
        let transition = taskStore.withLock { store in
            store.transitionAll(terminal: .cancelled)
        }

        operationQueue.cancelAllOperations()
        transition.records.forEach { $0.installedDirectCanceler?.cancel() }
        transition.records.forEach(deliverCancellation)
    }

    private func deliver(_ result: Result<Output, Error>, to record: TaskRecord<Input, Output>) {
        switch result {
        case let .success(output):
            record.handler.successHandler?(self, output)
            sendOutput(output)
        case let .failure(error):
            record.handler.errorHandler?(self, error)
        }

        record.handler.processingHandler?(self, false)
        record.handler.completionHandler?(self, .done)
    }

    private func deliverCancellation(to record: TaskRecord<Input, Output>) {
        record.handler.processingHandler?(self, false)
        record.handler.completionHandler?(self, .cancelled)
    }

    func finishExecuting(taskID: String, result: Result<Output, Error>) {
        switch executingType {
        case .onlyResult:
            let transition = taskStore.withLock { store in
                guard store.firstPending()?.taskID == taskID else {
                    return TaskTerminalTransition<Input, Output>(records: [], becameTerminallyEmpty: false)
                }
                let transition = store.transitionAll(terminal: .completed)
                if transition.becameTerminallyEmpty {
                    store.reserveTerminalDelivery()
                }
                return transition
            }
            guard !transition.records.isEmpty else { return }
            transition.records.forEach { deliver(result, to: $0) }

            let resolution = taskStore.withLock { store in
                store.resolveTerminalDelivery(releasingReservation: transition.becameTerminallyEmpty)
            }
            if let nextRecord = resolution.nextRecord {
                executeDirectTask(taskID: nextRecord.taskID, input: nextRecord.handler.input)
            } else if transition.becameTerminallyEmpty, resolution.isTerminallyEmpty {
                complete(true)
            }
        case .default, .latest, .only, .concurrent:
            guard let transition = taskStore.withLock({ store -> TaskTerminalTransition<Input, Output>? in
                store.transition(taskID, terminal: .completed)
            }) else {
                return
            }
            transition.records.forEach { deliver(result, to: $0) }
            if transition.becameTerminallyEmpty {
                complete(true)
            }
        case .queue:
            guard let transition = taskStore.withLock({ store -> TaskTerminalTransition<Input, Output>? in
                guard let transition = store.transition(taskID, terminal: .completed) else {
                    return nil
                }
                if transition.becameTerminallyEmpty {
                    store.reserveTerminalDelivery()
                }
                return transition
            }) else {
                return
            }
            transition.records.forEach { deliver(result, to: $0) }

            let resolution = taskStore.withLock { store in
                store.resolveTerminalDelivery(releasingReservation: transition.becameTerminallyEmpty)
            }
            if let nextRecord = resolution.nextRecord {
                executeDirectTask(taskID: nextRecord.taskID, input: nextRecord.handler.input)
            } else if transition.becameTerminallyEmpty, resolution.isTerminallyEmpty {
                complete(true)
            }
        }
    }

    func execute(input: Input, completion: @escaping (Result<Output, Error>) -> Void) -> BlockTaskCanceler {
        executor(self, input, completion)
    }
}

/// `@unchecked Sendable` is safe because `stateLock` is the sole owner of phase/canceler mutation,
/// the board reference is weak, and executor callbacks/canceler invocation always happen outside it.
final class BlockTaskExecutionOperation<In, Out>: Operation, @unchecked Sendable {
    private let taskID: String
    private let input: In
    private weak var taskBoard: BlockTaskBoard<In, Out>?

    private enum TerminalReason {
        case completed
        case cancelled
    }

    private enum Phase {
        case ready
        case executing
        case finishing(TerminalReason, wasExecuting: Bool)
        case finished(TerminalReason)
    }

    private struct TerminalClaim {
        let won: Bool
        let cancelerToInvoke: BlockTaskCanceler?
    }

    private let stateLock = NSRecursiveLock()
    private var phase: Phase = .ready
    private var canceler: BlockTaskCanceler?

    init(taskID: String, input: In, taskBoard: BlockTaskBoard<In, Out>) {
        self.taskBoard = taskBoard
        self.taskID = taskID
        self.input = input
        super.init()
    }

    override var isAsynchronous: Bool {
        true
    }

    override var isReady: Bool {
        stateLock.lock()
        let phaseIsReady: Bool
        if case .ready = phase {
            phaseIsReady = true
        } else {
            phaseIsReady = false
        }
        stateLock.unlock()
        return phaseIsReady && super.isReady
    }

    override var isExecuting: Bool {
        stateLock.lock()
        let value = observableValues(for: phase).isExecuting
        stateLock.unlock()
        return value
    }

    override var isFinished: Bool {
        stateLock.lock()
        let value = observableValues(for: phase).isFinished
        stateLock.unlock()
        return value
    }

    override var isCancelled: Bool {
        super.isCancelled
    }

    override func cancel() {
        super.cancel()
        let claim = claimTerminal(.cancelled)
        claim.cancelerToInvoke?.cancel()
        if claim.won {
            finishClaimedTerminal()
        }
    }

    override func start() {
        if isCancelled {
            let claim = claimTerminal(.cancelled)
            claim.cancelerToInvoke?.cancel()
            if claim.won {
                finishClaimedTerminal()
            }
            return
        }
        guard beginExecuting() else { return }
        main()
    }

    override func main() {
        guard canInvokeExecutor else { return }
        guard let task = taskBoard else {
            let claim = claimTerminal(.completed)
            if claim.won {
                finishClaimedTerminal()
            }
            return
        }

        let returnedCanceler = task.execute(input: input) { [weak task, weak self, taskID] result in
            guard let self else { return }
            let claim = self.claimTerminal(.completed)
            guard claim.won else { return }
            task?.finishExecuting(taskID: taskID, result: result)
            self.finishClaimedTerminal()
        }

        let disposition = installCanceler(returnedCanceler)
        if disposition == .invokeImmediately {
            returnedCanceler.cancel()
        }
    }

    private var canInvokeExecutor: Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        if case .executing = phase {
            return true
        }
        return false
    }

    private func beginExecuting() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard case .ready = phase else { return false }
        setPhaseLocked(.executing)
        return true
    }

    private func claimTerminal(_ reason: TerminalReason) -> TerminalClaim {
        stateLock.lock()
        defer { stateLock.unlock() }

        let wasExecuting: Bool
        switch phase {
        case .ready:
            wasExecuting = false
        case .executing:
            wasExecuting = true
        case .finishing, .finished:
            return TerminalClaim(won: false, cancelerToInvoke: nil)
        }

        let cancelerToInvoke: BlockTaskCanceler?
        switch reason {
        case .cancelled:
            cancelerToInvoke = canceler
        case .completed:
            cancelerToInvoke = nil
        }
        canceler = nil
        setPhaseLocked(.finishing(reason, wasExecuting: wasExecuting))
        return TerminalClaim(won: true, cancelerToInvoke: cancelerToInvoke)
    }

    private func finishClaimedTerminal() {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard case let .finishing(reason, _) = phase else { return }
        setPhaseLocked(.finished(reason))
    }

    private func installCanceler(_ newCanceler: BlockTaskCanceler) -> CancelerInstallDisposition {
        stateLock.lock()
        defer { stateLock.unlock() }

        switch phase {
        case .executing:
            guard canceler == nil else { return .discard }
            canceler = newCanceler
            return .installed
        case let .finishing(reason, _), let .finished(reason):
            switch reason {
            case .cancelled:
                return .invokeImmediately
            case .completed:
                return .discard
            }
        case .ready:
            return .discard
        }
    }

    private func setPhaseLocked(_ newPhase: Phase) {
        let oldValues = observableValues(for: phase)
        let newValues = observableValues(for: newPhase)
        var changedKeys: [String] = []
        if oldValues.isReady != newValues.isReady { changedKeys.append("isReady") }
        if oldValues.isExecuting != newValues.isExecuting { changedKeys.append("isExecuting") }
        if oldValues.isFinished != newValues.isFinished { changedKeys.append("isFinished") }

        for key in changedKeys {
            willChangeValue(forKey: key)
        }
        phase = newPhase
        for key in changedKeys.reversed() {
            didChangeValue(forKey: key)
        }
    }

    private func observableValues(for phase: Phase) -> (isReady: Bool, isExecuting: Bool, isFinished: Bool) {
        switch phase {
        case .ready:
            return (true, false, false)
        case .executing:
            return (false, true, false)
        case let .finishing(_, wasExecuting):
            return (false, wasExecuting, false)
        case .finished:
            return (false, false, true)
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
