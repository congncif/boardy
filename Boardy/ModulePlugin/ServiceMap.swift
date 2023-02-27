//
//  ServiceMap.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 27/02/2023.
//

import Foundation

/// Centralized Service Map which should be extended for calling a Boardy. Using ServiceMap enable the manager has an overview of micro-services in whole of system.
/// ```
/// // 1. Extend ServiceMap
/// public extension ServiceMap {
///     var transportation: TransportationServiceMap {
///         TransportationServiceMap(mainboard: mainboard)
///     }
/// }
///
///// 2. Define service map for a service
/// public struct TransportationServiceMap {
///     let mainboard: FlowMotherboard
///
///     public var status: TransportationStatusMainDestination {
///         mainboard.ioTransportationStatus()
///     }
/// }
/// ```
/// ```
/// // 3. Activate a service using ServiceMap
/// func checkTransportationStatus() {
///     motherboard.serviceMap.transportation.status.activate()
/// }
/// ```
///
public struct ServiceMap {
    public let mainboard: FlowMotherboard
}

public extension MotherboardType where Self: FlowManageable {
    var serviceMap: ServiceMap {
        ServiceMap(mainboard: self)
    }
}
