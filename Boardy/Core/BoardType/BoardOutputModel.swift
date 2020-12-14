//
//  BoardOutputModel.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 12/14/20.
//

import Foundation

public protocol BoardOutputModel {
    var identifier: BoardID { get }
    var data: Any? { get }
}
