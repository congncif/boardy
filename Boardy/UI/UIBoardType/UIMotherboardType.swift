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

public typealias FlowUIMotherboard = UIMotherboardType & FlowManageable

public protocol UIMotherboardType: InstallableBoard, IdentifiableBoard {
    var uiboards: [UIActivatableBoard] { get }

    /// Append list of boards, this doesn't include installing board into rootViewController.
    func addUIBoard(_ board: UIActivatableBoard)
    func removeUIBoard(withIdentifier identifier: BoardID)

    func getUIBoard(identifier: BoardID) -> UIActivatableBoard?

    /// Activate all UIBoards before plugging them in an UIBoardInterface.
    func plug(in interface: UIBoardInterface, with disposeBag: DisposeBag)
    func reloadBoards()
}

extension UIMotherboardType {
    public func activateUIBoard(identifier: BoardID, withOption option: Any? = nil) {
        guard let board = getUIBoard(identifier: identifier) else {
            assertionFailure("Board with identifier \(identifier) was not found in mother board \(self)")
            return
        }
        board.activate(withOption: option)
    }

    public func activateUIBoard(model: BoardInputModel) {
        activateUIBoard(identifier: model.identifier, withOption: model.option)
    }

    /// Activate all of uiboards in UIMotherboard at once. This is useful for preparing to plug them in UIBoardInterface.
    public func activateAllUIBoards(withOptions options: [BoardID: Any] = [:]) {
        for board in uiboards {
            let option = options[board.identifier]
            board.activate(withOption: option)
        }
    }

    public func activateAllUIBoards(models: [BoardInputModel]) {
        let options: [BoardID: Any] = models.reduce([:]) { result, model in
            result.merging([model.identifier: model.option]) { $1 }
        }
        activateAllUIBoards(withOptions: options)
    }

    public func reloadBoards() {
        uiboards.forEach { $0.reload() }
    }

    public func removeUIBoard(_ board: UIActivatableBoard) {
        removeUIBoard(withIdentifier: board.identifier)
    }

    /// Install additional a board after its Motherboard was installed.
    public func installUIBoard(_ board: UIActivatableBoard) {
        addUIBoard(board)
        board.install(into: rootViewController)
    }
}

protocol UIMotherboardRepresentable: AnyObject, UIMotherboardType {
    /// UIBoard should maintain order so they will be stored in array.
    var uimainboard: [UIActivatableBoard] { get set }
}

extension UIMotherboardRepresentable {
    public var uiboards: [UIActivatableBoard] {
        uimainboard
    }

    public func getUIBoard(identifier: BoardID) -> UIActivatableBoard? {
        return uiboards.first { $0.identifier == identifier }
    }

    public func addUIBoard(_ board: UIActivatableBoard) {
        assert(getUIBoard(identifier: board.identifier) == nil, " 💔 UIBoard with identifier \(board.identifier) was already added to motherboard \(self).")
        uimainboard.append(board)
    }

    public func removeUIBoard(withIdentifier identifier: BoardID) {
        assert(getUIBoard(identifier: identifier) != nil, " 💔 UIBoard with identifier \(identifier) was not in motherboard \(self).")
        uimainboard.removeAll { $0.identifier == identifier }
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
