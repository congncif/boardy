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

    @Atomic
    private var activateCount = 0

    private func increaseActivateCount() { activateCount += 1 }
    private func decreaseActivateCount() { activateCount -= 1 }

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
        guard activateCount == 0 else {
            #if DEBUG
                print("⚠️ [\(String(describing: self))] [\(identifier)] is already activated. Duplicated activations should avoid.")
            #endif
            return
        }

        increaseActivateCount()
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
        decreaseActivateCount()
        handleProgress()
        willComplete()

        if isCompleted {
            complete(isDone)
        }
    }

    deinit {
        if !isCompleted {
            activateCount = 0
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
