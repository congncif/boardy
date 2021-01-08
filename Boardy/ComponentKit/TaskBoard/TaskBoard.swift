//
//  TaskBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 1/7/21.
//

import Foundation
import UIKit

public final class TaskBoard<Input, Output>: Board, GuaranteedBoard {
    public typealias ExcutorCompletion = (Result<Output, Error>) -> Void
    public typealias Executor = (NormalBoard, Input, @escaping ExcutorCompletion) -> Void

    public typealias SuccessHandler = (NormalBoard, Output) -> Void
    public typealias ProcessingHandler = (NormalBoard, Bool) -> Void
    public typealias ErrorHandler = (NormalBoard, Error) -> Void
    public typealias CompletionHandler = (NormalBoard) -> Void

    public typealias InputType = Input

    private let executor: Executor
    private let successHandler: SuccessHandler
    private let processingHandler: ProcessingHandler
    private let errorHandler: ErrorHandler
    private let completionHandler: CompletionHandler

    public init(identifier: BoardID,
                executor: @escaping Executor,
                successHandler: @escaping SuccessHandler = { $0.sendToMotherboard(data: $1) },
                processingHandler: @escaping ProcessingHandler = { _, _ in },
                errorHandler: @escaping ErrorHandler = {
                    let alert = UIAlertController(title: "", message: $1.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                    let viewController = $0.rootViewController.presentedViewController ?? $0.rootViewController
                    viewController.present(alert, animated: true)
                },
                completionHandler: @escaping CompletionHandler = { $0.complete() }) {
        self.executor = executor
        self.successHandler = successHandler
        self.processingHandler = processingHandler
        self.errorHandler = errorHandler
        self.completionHandler = completionHandler
        super.init(identifier: identifier)
    }

    public func activate(withGuaranteedInput input: Input) {
        processingHandler(self, true)

        execute(input: input) { [weak self] result in
            guard let self = self else { return }

            defer {
                self.completionHandler(self)
            }

            self.processingHandler(self, false)

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
