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

    func addUIBoard(_ board: UIActivatableBoard)
    func removeUIBoard(withIdentifier identifier: BoardID)

    func getUIBoard(identifier: BoardID) -> UIActivatableBoard?

    func plug(in interface: UIBoardInterface, with disposeBag: DisposeBag)
    func reloadBoards()
}

extension UIMotherboardType {
    public func reloadBoards() {
        uiboards.forEach { $0.reload() }
    }
}

protocol UIMotherboardRepresentable: AnyObject, UIMotherboardType {
    var uimainboard: [BoardID: UIActivatableBoard] { get set }
}

extension UIMotherboardRepresentable {
    public var uiboards: [UIActivatableBoard] {
        uimainboard.map { $0.value }
    }

    public func getUIBoard(identifier: BoardID) -> UIActivatableBoard? {
        return uimainboard[identifier]
    }

    public func addUIBoard(_ board: UIActivatableBoard) {
        assert(uimainboard[board.identifier] == nil, " 💔 UIBoard with identifier \(board.identifier) was already added to motherboard \(self).")
        uimainboard[board.identifier] = board
    }

    public func removeUIBoard(withIdentifier identifier: BoardID) {
        assert(uimainboard[identifier] != nil, " 💔 UIBoard with identifier \(identifier) was not in motherboard \(self).")
        uimainboard[identifier] = nil
    }
}

protocol UIMotherboardObservable: UIMotherboardType {
    var visibleBoards: Observable<[UIActivatableBoard]> { get }
}

extension UIMotherboardObservable {
    var visibleBoardItems: Observable<[UIBoardItem]> {
        visibleBoards.map {
            $0.map {
                UIBoardItem(identifier: $0.identifier, version: $0.version, viewController: $0.pluggableInterface, options: $0.options)
            }
        }
    }

    public func plug(in interface: UIBoardInterface, with disposeBag: DisposeBag) {
        visibleBoardItems.bind(to: interface.boardItems).disposed(by: disposeBag)
        reloadBoards()
    }
}
