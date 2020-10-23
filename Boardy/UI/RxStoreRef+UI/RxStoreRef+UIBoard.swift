//
//  RxStoreRef+UIBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/23/20.
//

import Foundation

/***/
extension UIBoardInterface where Self: ReactiveDisposableObject {
    public func justPlugUIMotherboard(_ board: UIMotherboardType) {
        board.plug(in: self, with: freshDisposeBag)
    }
}

extension UIMotherboardType where Self: ReactiveDisposableObject {
    public func justPlug(in interface: UIBoardInterface) {
        plug(in: interface, with: freshDisposeBag)
    }
}
