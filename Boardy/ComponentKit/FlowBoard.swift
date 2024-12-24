//
//  FlowBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 6/20/21.
//

import Foundation

public protocol FlowingBoard: NormalBoard {
    var motherboard: FlowMotherboard { get }
}

open class FlowBoard<Input, Output, Command, Action: BoardFlowAction>: ModernContinuableBoard, GuaranteedBoard, FlowingBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    public typealias InputType = Input
    public typealias OutputType = Output
    public typealias CommandType = Command
    public typealias FlowActionType = Action

    public typealias FlowRegistration = (FlowBoard<Input, Output, Command, Action>) -> Void
    public typealias FlowActivation = (FlowBoard<Input, Output, Command, Action>, InputType) -> Void
    public typealias FlowInteraction = (FlowBoard<Input, Output, Command, Action>, CommandType) -> Void

    private let flowActivation: FlowActivation
    private let flowRegistration: FlowRegistration
    private let flowInteraction: FlowInteraction
    private let allowBypassGatewayBarrier: Bool

    public init(identifier: BoardID,
                producer: ActivatableBoardProducer,
                allowBypassGatewayBarrier: Bool = true,
                flowRegistration: @escaping FlowRegistration,
                flowActivation: @escaping FlowActivation,
                flowInteraction: @escaping FlowInteraction = { board, command in
                    #if DEBUG
                        print("""
                        ⚠️ The FlowBoard received an interaction command but missing a handler!
                            🏝 [\(String(describing: type(of: board)))] ➤ \(board.identifier.rawValue)
                            🚦 [\(String(describing: type(of: command)))] ➤ \(command)
                        """)
                        if let motherboard = board.delegate as? IdentifiableBoard {
                            print("    🌏 [\(String(describing: type(of: motherboard)))] ➤ \(motherboard.identifier.rawValue)")
                        }
                    #endif
                }) {
        self.flowActivation = flowActivation
        self.flowRegistration = flowRegistration
        self.flowInteraction = flowInteraction
        self.allowBypassGatewayBarrier = allowBypassGatewayBarrier
        super.init(identifier: identifier, boardProducer: producer)
        registerFlows()
    }

    open func activate(withGuaranteedInput input: InputType) {
        flowActivation(self, input)
    }

    open func interact(guaranteedCommand: CommandType) {
        flowInteraction(self, guaranteedCommand)
    }

    open func registerFlows() {
        flowRegistration(self)
    }

    open func shouldBypassGatewayBarrier() -> Bool {
        allowBypassGatewayBarrier
    }
}
