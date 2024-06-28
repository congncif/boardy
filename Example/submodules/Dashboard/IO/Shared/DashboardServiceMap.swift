//
//  DashboardServiceMap.swift
//  Dashboard
//
//  Created by Boardy on 6/1/21.
//
//

import Boardy
import Foundation

/// List of provided services here
public extension DashboardServiceMap {
    var ioDashboard: DashboardMainDestination {
        mainboard.ioDashboard()
    }
}

public final class DashboardServiceMap: ServiceMap {}

public extension ServiceMap {
    var modDashboard: DashboardServiceMap { link() }
}
