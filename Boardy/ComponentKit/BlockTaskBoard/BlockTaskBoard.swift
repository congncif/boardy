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

    public func onSuccess(_ handler: BlockTaskBoard<Input, Output>.SuccessHandler?) -> Self {
        successHandler = handler
        return self
    }

    public func onProcessing(_ handler: BlockTaskBoard<Input, Output>.ProcessingHandler?) -> Self {
        processingHandler = handler
        return self
    }

    public func onError(_ handler: BlockTaskBoard<Input, Output>.ErrorHandler?) -> Self {
        errorHandler = handler
        return self
    }

    public func onCompletion(_ handler: BlockTaskBoard<Input, Output>.CompletionHandler?) -> Self {
        completionHandler = handler
        return self
    }

    let input: Input

    var successHandler: BlockTaskBoard<Input, Output>.SuccessHandler?
    var processingHandler: BlockTaskBoard<Input, Output>.ProcessingHandler?
    var errorHandler: BlockTaskBoard<Input, Output>.ErrorHandler?
    var completionHandler: BlockTaskBoard<Input, Output>.CompletionHandler?
}

struct BlockHandler<Input, Output> {
    let successHandler: BlockTaskBoard<Input, Output>.SuccessHandler?
    let processingHandler: BlockTaskBoard<Input, Output>.ProcessingHandler?
    let errorHandler: BlockTaskBoard<Input, Output>.ErrorHandler?
    let completionHandler: BlockTaskBoard<Input, Output>.CompletionHandler?
}

public final class BlockTaskBoard<Input, Output>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    public typealias InputType = BlockTaskParameter<Input, Output>
    public typealias OutputType = Output

    public typealias ExecutorCompletion = (Result<Output, Error>) -> Void
    public typealias Executor = (BlockTaskBoard<Input, Output>, Input, @escaping ExecutorCompletion) -> Void

    public typealias SuccessHandler = (BlockTaskBoard<Input, Output>, Output) -> Void
    public typealias ProcessingHandler = (BlockTaskBoard<Input, Output>, Bool) -> Void
    public typealias ErrorHandler = (BlockTaskBoard<Input, Output>, Error) -> Void
    public typealias CompletionHandler = (BlockTaskBoard<Input, Output>) -> Void

    private let executor: Executor

    public init(identifier: BoardID,
                executor: @escaping Executor) {
        self.executor = executor
        super.init(identifier: identifier)
    }

    public func activate(withGuaranteedInput input: InputType) {
        let taskID = UUID().uuidString

        let handler = BlockHandler<Input, Output>(successHandler: input.successHandler, processingHandler: input.processingHandler, errorHandler: input.errorHandler, completionHandler: input.completionHandler)

        setHandler(handler, forKey: taskID)

        if let processHandler = getHandler(forKey: taskID)?.processingHandler {
            processHandler(self, true)
        }

        execute(input: input.input) { [unowned self] result in
            defer {
                if let processHandler = self.getHandler(forKey: taskID)?.processingHandler {
                    processHandler(self, false)
                }
                if let completionHandler = self.getHandler(forKey: taskID)?.completionHandler {
                    completionHandler(self)
                }

                if self.getHandler(forKey: taskID) != nil {
                    self.setHandler(nil, forKey: taskID)
                }

                if self.isCompleted {
                    self.complete()
                }
            }

            switch result {
            case let .success(output):
                if let successHandler = self.getHandler(forKey: taskID)?.successHandler {
                    successHandler(self, output)
                }

                self.sendOutput(output)
            case let .failure(error):
                if let errorHandler = self.getHandler(forKey: taskID)?.errorHandler {
                    errorHandler(self, error)
                }
            }
        }
    }

    private func execute(input: Input, completion: @escaping (Result<Output, Error>) -> Void) {
        executor(self, input, completion)
    }

    // MARK: - Access shared data

    private var completions: [String: BlockHandler<Input, Output>] = [:]
    private let completionQueue = DispatchQueue(label: "boardy.block-task-board.queue", attributes: .concurrent)

    private func setHandler(_ handler: BlockHandler<Input, Output>?, forKey key: String) {
        completionQueue.async(flags: .barrier) { [unowned self] in
            self.completions[key] = handler
        }
    }

    private func getHandler(forKey key: String) -> BlockHandler<Input, Output>? {
        completionQueue.sync {
            completions[key]
        }
    }

    private var isCompleted: Bool {
        completionQueue.sync {
            completions.isEmpty
        }
    }
}
