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

public final class TaskBoard<Input, Output>: Board, GuaranteedBoard, TaskingBoard, GuaranteedOutputSendingBoard {
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

    @Atomic
    private var activateCount = 0

    private func increaseActivateCount() { activateCount += 1 }
    private func decreaseActivateCount() { activateCount -= 1 }

    public var isCompleted: Bool { activateCount == 0 }
    public var isProcessing: Bool { activateCount != 0 }

    public init(identifier: BoardID,
                executor: @escaping Executor,
                successHandler: @escaping SuccessHandler = { $0.sendOutput($1) },
                processingHandler: @escaping ProcessingHandler = { _ in },
                errorHandler: @escaping ErrorHandler = { board, error in
                    DispatchQueue.main.async { [weak board] in
                        guard let board = board, board.root != nil else { return }
                        let viewController = board.rootViewController.presentedViewController ?? board.rootViewController
                        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                        viewController.present(alert, animated: true)
                    }
                },
                completionHandler: @escaping CompletionHandler = {
                    if $0.isCompleted { $0.complete() }
                }) {
        self.executor = executor
        self.successHandler = successHandler
        self.processingHandler = processingHandler
        self.errorHandler = errorHandler
        self.completionHandler = completionHandler
        super.init(identifier: identifier)
    }

    public func activate(withGuaranteedInput input: Input) {
        increaseActivateCount()
        processingHandler(self)

        execute(input: input) { [weak self] result in
            guard let self = self else { return }

            defer {
                self.decreaseActivateCount()
                self.processingHandler(self)
                self.completionHandler(self)
            }

            switch result {
            case let .success(output):
                self.successHandler(self, output)
            case let .failure(error):
                self.errorHandler(self, error)
            }
        }
    }

    private func execute(input: Input, completion: @escaping (Result<Output, Error>) -> Void) {
        executor(self, input, completion)
    }
}
