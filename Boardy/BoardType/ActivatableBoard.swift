//
//  ActivatableBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

public protocol BoardDelegate: AnyObject {
    func board(_ board: IdentifiableBoard, didSendData data: Any?)
}

// MARK: - Board

public protocol InstallableBoard {
    var rootViewController: UIViewController { get }

    func install(into rootViewController: UIViewController)
}

public protocol IdentifiableBoard {
    var delegate: BoardDelegate? { get set }
    var identifier: String { get }
}

extension IdentifiableBoard {
    public func sendToMotherboard(data: Any?) {
        delegate?.board(self, didSendData: data)
    }
}

public protocol ActivatableBoard: IdentifiableBoard, InstallableBoard {
    func activate(withOption option: Any?)
}
