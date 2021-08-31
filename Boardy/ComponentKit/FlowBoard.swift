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

public final class FlowBoard<Input, Output>: ModernContinuableBoard, GuaranteedBoard, FlowingBoard, GuaranteedOutputSendingBoard {
    public typealias InputType = Input
    public typealias OutputType = Output

    public typealias FlowRegistration = (FlowBoard<Input, Output>) -> Void
    public typealias FlowActivation = (FlowBoard<Input, Output>, InputType) -> Void

    private let flowActivation: FlowActivation

    public init(identifier: BoardID,
                producer: ActivableBoardProducer,
                flowRegistration: FlowRegistration,
                flowActivation: @escaping FlowActivation) {
        self.flowActivation = flowActivation
        super.init(identifier: identifier, boardProducer: producer)
        flowRegistration(self)
    }

    public func activate(withGuaranteedInput input: InputType) {
        flowActivation(self, input)
    }
}
