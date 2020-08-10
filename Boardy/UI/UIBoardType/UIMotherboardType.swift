//
//  UIMotherboardType.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

public protocol UIMotherboardType: InstallableBoard {
    var uiboards: [UIActivatableBoard] { get }
}

extension UIMotherboardType {
    public func getUIBoard(identifier: String) -> UIActivatableBoard? {
        return uiboards.first { $0.identifier == identifier }
    }

    public var visibleBoards: Observable<[UIActivatableBoard]> {
        Observable.combineLatest(uiboards.map { $0.changeSequence })
            .map {
                $0.filter { $0.isVisible }
            }
    }

    public var visibleBoardItems: Observable<[UIBoardItem]> {
        visibleBoards.map {
            $0.map {
                UIBoardItem(identifier: $0.identifier, version: $0.version, viewController: $0.pluggableInterface, options: $0.options)
            }
        }
    }

    public func reloadBoards() {
        uiboards.forEach { $0.reload() }
    }

    public func plug(in interface: UIBoardInterface, with disposeBag: DisposeBag) {
        visibleBoardItems.bind(to: interface.boardItems).disposed(by: disposeBag)
        reloadBoards()
    }
}
