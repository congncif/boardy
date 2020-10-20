//
//  DashboardElementFactory.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 10/20/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import Resolver

struct DashboardElementFactory: DashboardElementManufacturing, Resolving {
    func getElementBoards() -> [UIActivatableBoard] {
        let headlineBoard: HeadlineUIBoard = resolver.resolve()
        let featuredBoard: FeaturedUIBoard = resolver.resolve()
        return [headlineBoard, featuredBoard]
    }
}
