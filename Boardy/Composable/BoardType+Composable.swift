//
//  Board+Composable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/26/20.
//

import Foundation
import UIComposable
import UIKit

extension IdentifiableBoard {
    public func putToComposer(elementAction: UIElementAction) {
        sendToMotherboard(data: elementAction)
    }
}

// Overload method with BoardID
extension UIElement {
    public init(identifier: BoardID, contentViewController: UIViewController?, configuration: Any? = nil) {
        self.init(identifier: identifier.rawValue, contentViewController: contentViewController, configuration: configuration)
    }
}
