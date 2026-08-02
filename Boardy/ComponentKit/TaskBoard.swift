//
//  TaskBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 1/7/21.
//

import Foundation
import UIKit

public protocol TaskingBoard: NormalBoard {
    var isCompleted: Bool { get }
    var isProcessing: Bool { get }
}

/// A board that runs one piece of work and reports the result.
///
/// Use it for the steps in a flow that are not screens: fetch, validate, upload. The executor
/// receives the input and a completion; the board turns that into typed output plus the usual
/// board completion, so it composes with flows exactly like a UI board does.
///
/// ```swift
/// let load = TaskBoard<UserID, Profile>(identifier: .loadProfile) { _, id, done in
///     api.profile(for: id) { done($0) }
/// }
/// ```
///
/// ## One activation at a time
///
/// A task board holds a single activation slot. Activating while work is in flight is rejected —
/// the executor does not run twice — and the slot is released when the executor completes.
/// A duplicate completion is a no-op rather than an error.
///
/// Execution is caller-controlled: the executor runs wherever `activate` was called from, and the
/// handlers run wherever the completion was delivered from. Hop to the main queue yourself for UI.
open class TaskBoard<Input, Output>: Board, GuaranteedBoard, TaskingBoard, GuaranteedOutputSendingBoard {
    public typealias ExecutorCompletion = (Result<Output, Error>) -> Void
    public typealias Executor = (TaskingBoard, Input, @escaping ExecutorCompletion) -> Void

    public typealias SuccessHandler = (TaskBoard<Input, Output>, Output) -> Void
    public typealias ProcessingHandler = (TaskBoard<Input, Output>) -> Void
    public typealias ErrorHandler = (TaskBoard<Input, Output>, Error) -> Void
    public typealias CompletionHandler = (TaskBoard<Input, Output>) -> Void

    public typealias InputType = Input
    public typealias OutputType = Output

    private let executor: Executor
    private let successHandler: SuccessHandler
    private let processingHandler: ProcessingHandler
    private let errorHandler: ErrorHandler
    private let completionHandler: CompletionHandler
    private let allowBypassGatewayBarrier: Bool

    private let activationSlot = Locked(0)

    /// Claims the single activation slot. Returns `false` when the board is already active.
    ///
    /// Testing the counter and writing it back must be one indivisible operation: as two separate
    /// operations, concurrent callers both read an idle board and both start work.
    private func claimActivation() -> Bool {
        activationSlot.withLock { count in
            guard count == 0 else { return false }
            count = 1
            return true
        }
    }

    /// Releases the slot. Returns `false` when it was already released, which makes a duplicate
    /// executor completion a no-op instead of driving the counter below zero.
    private func releaseActivation() -> Bool {
        activationSlot.withLock { count in
            guard count > 0 else { return false }
            count -= 1
            return true
        }
    }

    private var activateCount: Int { activationSlot.withLock { $0 } }

    public var isCompleted: Bool { activateCount == 0 }
    public var isProcessing: Bool { activateCount != 0 }

    public init(identifier: BoardID,
                allowBypassGatewayBarrier: Bool = true,
                executor: @escaping Executor,
                successHandler: @escaping SuccessHandler = { _, _ in },
                processingHandler: @escaping ProcessingHandler = { _ in },
                errorHandler: @escaping ErrorHandler = { board, error in
                    guard board.context != nil else { return }

                    // Get top view controller
                    var topViewController = board.rootViewController
                    while let viewController = topViewController.presentedViewController {
                        topViewController = viewController
                    }

                    DispatchQueue.main.async { [weak topViewController] in
                        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                        topViewController?.present(alert, animated: true)
                    }
                },
                completionHandler: @escaping CompletionHandler = { _ in }) {
        self.executor = executor
        self.successHandler = successHandler
        self.processingHandler = processingHandler
        self.errorHandler = errorHandler
        self.completionHandler = completionHandler
        self.allowBypassGatewayBarrier = allowBypassGatewayBarrier
        super.init(identifier: identifier)
    }

    public func shouldBypassGatewayBarrier() -> Bool {
        allowBypassGatewayBarrier
    }

    public func activate(withGuaranteedInput input: Input) {
        guard claimActivation() else {
            #if DEBUG
                print("⚠️ [\(String(describing: self))] [\(identifier)] is already activated. Duplicated activations should avoid.")
            #endif
            return
        }

        handleProgress()

        execute(input: input) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(output):
                handleSuccess(output)
                sendOutput(output)
                endProcess(isDone: true)
            case let .failure(error):
                handleError(error)
                endProcess(isDone: false)
            }
        }
    }

    func endProcess(isDone: Bool) {
        guard releaseActivation() else { return }

        handleProgress()
        willComplete()

        if isCompleted {
            complete(isDone)
        }
    }

    deinit {
        if !isCompleted {
            activationSlot.withLock { $0 = 0 }
            handleProgress()
        }
    }

    private func execute(input: Input, completion: @escaping (Result<Output, Error>) -> Void) {
        executor(self, input, completion)
    }

    open func handleSuccess(_ output: Output) {
        successHandler(self, output)
    }

    open func handleProgress() {
        processingHandler(self)
    }

    open func handleError(_ error: Error) {
        errorHandler(self, error)
    }

    open func willComplete() {
        completionHandler(self)
    }
}
