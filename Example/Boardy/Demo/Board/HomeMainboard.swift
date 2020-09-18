//
//  HomeMainboard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/1/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation

protocol HomeMotherboard: FlowMotherboard {}

final class HomeMainboard: Motherboard, HomeMotherboard {
    init() {
        super.init()
        // register extra flows if needed
    }
}
