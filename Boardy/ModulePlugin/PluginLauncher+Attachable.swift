//
//  PluginLauncher+Attachable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 29/6/24.
//

import Foundation

public extension PluginLauncher {
    func attachLaunch(in context: AttachableObject,
                      action: (_ mainboard: FlowMotherboard) -> Void = { _ in }) {
        launch(in: context, action: action)
        context.attachObject(self)
    }
}
