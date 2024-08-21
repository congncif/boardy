//
//  DashboardIOInterface.swift
//  Dashboard
//
//  Created by Boardy on 6/1/21.
//
//

import Boardy
import Foundation

// MARK: - ID

public extension BoardID {
    static let pubDashboard: BoardID = "pub.mod.DashboardIO.default"
}

// MARK: - Interface

public typealias DashboardDestination = BoardGenericDestination<DashboardInput, DashboardCommand>

extension ActivatableBoard {
    func ioDashboard(_ identifier: BoardID = .pubDashboard) -> DashboardDestination {
        DashboardDestination(destinationID: identifier, source: self)
    }
}

public typealias DashboardMainDestination = MainboardGenericDestination<DashboardInput, DashboardOutput, DashboardCommand, DashboardAction>

extension MotherboardType where Self: FlowManageable {
    func ioDashboard(_ identifier: BoardID = .pubDashboard) -> DashboardMainDestination {
        DashboardMainDestination(destinationID: identifier, mainboard: self)
    }
}
