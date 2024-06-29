//
//  AppDelegate+Plugins.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Copyright © 2024 [iF] Solution. All rights reserved.
//

import Boardy
import Dashboard
import Foundation

import AuthenticationPlugins
import DashboardPlugins
import EmployeeManagementPlugins

extension AppDelegate {
    func launchPlugins() {
        PluginLauncher.with(options: .default)
            .install(launcherPlugin: DashboardLauncherPlugin())
            .install(launcherPlugin: AuthenticationLauncherPlugin())
            .install(launcherPlugin: EmployeeManagementLauncherPlugin())
            .initialize()
            .launch(in: window!) { mainboard in
                mainboard.serviceMap
                    .modDashboard.ioDashboard
                    .activation.activate()
            }
    }
}
