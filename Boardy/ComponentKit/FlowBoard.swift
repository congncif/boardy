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

open class FlowBoard<Input, Output, Action: BoardFlowAction>: ModernContinuableBoard, GuaranteedBoard, FlowingBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard {
    public typealias InputType = Input
    public typealias OutputType = Output
    public typealias FlowActionType = Action

    public typealias FlowRegistration = (FlowBoard<Input, Output, Action>) -> Void
    public typealias FlowActivation = (FlowBoard<Input, Output, Action>, InputType) -> Void

    private let flowActivation: FlowActivation
    private let flowRegistration: FlowRegistration

    public init(identifier: BoardID,
                producer: ActivableBoardProducer,
                flowRegistration: @escaping FlowRegistration,
                flowActivation: @escaping FlowActivation) {
        self.flowActivation = flowActivation
        self.flowRegistration = flowRegistration
        super.init(identifier: identifier, boardProducer: producer)
        registerFlows()
    }

    open func activate(withGuaranteedInput input: InputType) {
        flowActivation(self, input)
    }

    open func registerFlows() {
        flowRegistration(self)
    }
}
