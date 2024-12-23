//
//  GatewayBarrierPlugin.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 23/12/24.
//

import Foundation

public enum GatewayBarrier {
    case none
    case required(BoardConstructor)
}

public protocol GatewayBarrierPlugin {
    var gatewayBarrier: GatewayBarrier { get }
}
