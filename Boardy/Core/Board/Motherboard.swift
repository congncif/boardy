//
//  Motherboard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 11/1/19.
//  Copyright © 2019 NGUYEN CHI CONG. All rights reserved.
//

import Foundation
import UIKit

open class Motherboard: Board, MotherboardRepresentable, BoardDelegate, FlowMotherboard, LazyMotherboard {
    /// Backing store for `flows`.
    ///
    /// Flow registration happens on the main thread, but flow *dispatch* does not: a board may
    /// send its output from whatever executor its work finished on, and `board(_:didSendData:)`
    /// reads this list to find matching flows. Reading a plain `Array` while another thread appends
    /// to it is undefined behavior rather than a stale read, so the storage is locked and every
    /// reader takes a snapshot.
    ///
    /// This is not a new caller requirement: off-main output is an existing, documented contract
    /// (`BlockTaskBoard` keeps its legacy completion executor), so the framework absorbs the
    /// synchronization instead of asking callers to hop queues.
    private let flowStorage = Locked<[BoardFlow]>([])

    public var flows: [BoardFlow] {
        get { flowStorage.withLock { $0 } }
        set { flowStorage.withLock { $0 = newValue } }
    }

    override public var debugDescription: String {
        let superDesc = super.debugDescription
        return superDesc + "\n" + """
            🌏 [Motherboard] ➤ \(String(describing: identifier))
            🍒 [Children] ➤ \(String(describing: boards.map { $0.identifier }))
            🌈 [Flows] ➤ \(String(describing: flows.count))
            🌋 [Producer] ➤ \(String(describing: boardProducer))
        """
    }

    public init(identifier: BoardID = .random(),
                boards: [ActivatableBoard] = []) {
        boardProducer = NoBoardProducer()
        super.init(identifier: identifier)

        for board in boards {
            addBoard(board)
        }

        registerDefaultFlows()
    }

    public init(identifier: BoardID = .random(),
                boardProducer: ActivatableBoardProducer) {
        self.boardProducer = boardProducer
        super.init(identifier: identifier)
        registerDefaultFlows()
    }

    public convenience init(identifier: BoardID = .random(), boardProducer: ActivatableBoardProducer, boards: [ActivatableBoard]) {
        self.init(identifier: identifier, boardProducer: boardProducer)
        for board in boards {
            addBoard(board)
        }
    }

    func registerDefaultFlows() {
        // Forward action through chain
        forwardActionFlow(to: self)

        // Register Interaction flow
        registerGeneralFlow { [weak self] in
            self?.interactWithBoard(command: $0)
        }

        // Register activation flow
        registerGeneralFlow { [weak self] in
            self?.activateBoard(model: $0)
        }

        // Register complete flow
        registerGeneralFlow { [weak self] (action: CompleteAction) in
            self?.removeBoard(withIdentifier: action.identifier)
        }
    }

    override open func putIntoContext(_ context: AnyObject) {
        super.putIntoContext(context)
        for board in boards {
            board.putIntoContext(context)
        }
    }

    @discardableResult
    public func registerFlow(_ flow: BoardFlow) -> Self {
        boardyAssertMainThread()

        // The duplicate report is advisory, so it reads a snapshot rather than holding the lock
        // while calling into `BoardFlow.identifier`. Only the append needs to be atomic.
        #if DEBUG
            if flows.contains(where: { $0.identifier == flow.identifier }) {
                print("⚠️ [Motherboard] ➤ \(identifier)\n  [Duplicated flow] ➤ A flow with identifier \(flow.identifier) is already registered!")
            }
        #endif

        flowStorage.withLock { $0.append(flow) }
        return self
    }

    public func resetFlows() {
        boardyAssertMainThread()
        flowStorage.withLock { $0.removeAll() }
        registerDefaultFlows()
        restoreBarrierCompletionFlows()
    }

    public func removeFlow(by identifier: String) {
        boardyAssertMainThread()
        flowStorage.withLock { registeredFlows in
            registeredFlows.removeAll { $0.identifier == identifier }
        }
    }

    // MARK: - MotherboardRepresentable

    var mainboard: [ActivatableBoard] = [] {
        didSet {
            for board in boards {
                board.delegate = self
                if board.context == nil, let root = context {
                    board.putIntoContext(root)
                }
            }
        }
    }

    // MARK: - LazyMotherboard

    public private(set) var boardProducer: ActivatableBoardProducer
}
