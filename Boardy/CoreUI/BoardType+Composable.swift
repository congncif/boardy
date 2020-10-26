//
//  Board+Composable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation
import UIComposable

extension IdentifiableBoard {
    public func putToComposer(elementAction: UIElementAction) {
        sendToMotherboard(data: elementAction)
    }
}
