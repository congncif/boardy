//
//  ServiceMap.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 27/02/2023.
//

import Foundation

/// Centralized Service Map which should be extended for calling a Boardy. Using ServiceMap enables the manager has an overview of micro-services in whole of system.
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
open class ServiceMap {
    public let mainboard: FlowMotherboard

    public required init(mainboard: FlowMotherboard) {
        self.mainboard = mainboard
    }
}

public extension MotherboardType where Self: FlowManageable {
    var serviceMap: ServiceMap {
        ServiceMap(mainboard: self)
    }
}

public extension IdentifiableBoard {
    var serviceMap: ServiceMap {
        if let continuableBoard = self as? ContinuableBoard {
            return continuableBoard.serviceMap
        } else if let motherboard = delegate as? FlowMotherboard {
            return motherboard.serviceMap
        } else {
            preconditionFailure("❌ [Boardy] The board \(identifier) was not installed into any motherboard!")
        }
    }
}

public extension ServiceMap {
    func link<MapType: ServiceMap>(_: MapType.Type = MapType.self) -> MapType {
        MapType(mainboard: mainboard)
    }
}
