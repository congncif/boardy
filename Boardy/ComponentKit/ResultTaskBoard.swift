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
    private let allowBypassGatewayBarrier: Bool

    private let activeState = Locked(false)

    private var isActive: Bool { activeState.withLock { $0 } }

    /// Claims the board. Returns `false` when it is already active.
    ///
    /// Testing the flag and setting it must be one indivisible operation: as two separate
    /// operations, concurrent callers both observe an inactive board and both start work.
    private func claimActivation() -> Bool {
        activeState.withLock { active in
            guard !active else { return false }
            active = true
            return true
        }
    }

    /// Releases the board. Returns `false` when it was already released, which makes a duplicate
    /// terminal result a no-op instead of sending output twice.
    private func releaseActivation() -> Bool {
        activeState.withLock { active in
            guard active else { return false }
            active = false
            return true
        }
    }

    public init(identifier: BoardID,
                allowBypassGatewayBarrier: Bool = true,
                executor: @escaping Executor) {
        self.executor = executor
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

        execute(input: input) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .progress(fractionCompleted):
                self.sendOutput(.progress(fractionCompleted: fractionCompleted))
            case let .success(output):
                guard self.releaseActivation() else { return }
                self.sendOutput(.success(output))
                self.complete(true)
            case let .failure(error):
                guard self.releaseActivation() else { return }
                self.sendOutput(.failure(error))
                self.complete(false)
            case .cancel:
                guard self.releaseActivation() else { return }
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
