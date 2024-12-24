//
//  GatewayBarrierRegistration.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 23/12/24.
//

import Foundation

public final class GatewayBarrierRegistration {
    init(activation: @escaping (GatewayBarrierBoard, Any?) -> Void,
         flowRegistration: @escaping (GatewayBarrierBoard) -> Void) {
        self.activation = activation
        self.flowRegistration = flowRegistration
    }

    var activation: (GatewayBarrierBoard, Any?) -> Void
    var flowRegistration: (GatewayBarrierBoard) -> Void

    public static func registerWithActivation(_ activation: @escaping (_ barrier: GatewayBarrierBoard, _ option: Any?) -> Void) -> GatewayBarrierRegistration {
        GatewayBarrierRegistration(activation: activation, flowRegistration: { _ in })
    }

    public func withFlowRegistration(_ flowRegistration: @escaping (_ barrier: GatewayBarrierBoard) -> Void) -> Self {
        self.flowRegistration = flowRegistration
        return self
    }
}

final class GatewayBarrierProxy: ContinuousBoard, ActivatableBoard, Completable {
    init(identifier: BoardID, boardProducer: any ActivatableBoardProducer, registration: GatewayBarrierRegistration) {
        self.registration = registration
        super.init(identifier: identifier, boardProducer: boardProducer)

        registration.flowRegistration(self)
    }

    let registration: GatewayBarrierRegistration

    func activate(withOption option: Any?) {
        registration.activation(self, option)
    }
}

public typealias GatewayBarrierBoard = Completable & ContinuableBoard
