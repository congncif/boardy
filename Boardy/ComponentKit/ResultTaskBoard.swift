//
//  ResultBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/5/21.
//

import Foundation

public enum BoardResult<Success, Failure> {
    case progress(fractionCompleted: Double)
    case success(Success)
    case failure(Failure)
    case cancel

    public static var progress: Self {
        .progress(fractionCompleted: 0)
    }

    public var inProgress: Bool {
        switch self {
        case .progress:
            return true
        default:
            return false
        }
    }
}

public final class ResultTaskBoard<Input, Success, Failure>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    public typealias InputType = Input
    public typealias OutputType = BoardResult<Success, Failure>

    public typealias ExecutorCallback = (BoardResult<Success, Failure>) -> Void
    public typealias Executor = (Input, @escaping ExecutorCallback) -> Void

    private let executor: Executor

    @Atomic
    private var isActive = false

    public init(identifier: BoardID,
                executor: @escaping Executor) {
        self.executor = executor
        super.init(identifier: identifier)
    }

    public func activate(withGuaranteedInput input: Input) {
        guard !isActive else {
            #if DEBUG
                print("⚠️ [\(String(describing: self))] [\(identifier)] is already activated. Duplicated activations should avoid.")
            #endif
            return
        }
        isActive = true

        execute(input: input) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .progress(fractionCompleted):
                self.sendOutput(.progress(fractionCompleted: fractionCompleted))
            case let .success(output):
                self.isActive = false
                self.sendOutput(.success(output))
                self.complete(true)
            case let .failure(error):
                self.isActive = false
                self.sendOutput(.failure(error))
                self.complete(false)
            case .cancel:
                self.isActive = false
                self.sendOutput(.cancel)
                self.complete(false)
            }
        }
    }

    deinit {
        if isActive {
            sendOutput(.cancel)
        }
    }

    private func execute(input: Input, callback: @escaping (BoardResult<Success, Failure>) -> Void) {
        executor(input, callback)
    }
}
