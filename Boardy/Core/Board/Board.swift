//
//  Board.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import UIKit

open class Board: InstallableBoard, IdentifiableBoard {
    public let identifier: BoardID
    public weak var delegate: BoardDelegate?

    private weak var hostingViewController: UIViewController?

    public init(identifier: BoardID = UUID().uuidString) {
        self.identifier = identifier
    }

    public var rootViewController: UIViewController {
        guard let viewController = hostingViewController else {
            assertionFailure("Board was not installed. Install \(self) into a rootViewController before activating it.")
            return UIViewController()
        }
        return viewController
    }

    public func install(into rootViewController: UIViewController) {
        hostingViewController = rootViewController
    }
}
