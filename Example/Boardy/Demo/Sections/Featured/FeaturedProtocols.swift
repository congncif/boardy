//
//  FeaturedProtocols.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit

protocol FeaturedController: UIViewController {
    var delegate: FeaturedDelegate? { get set }
}

protocol FeaturedDelegate: AnyObject {}

protocol FeaturedBuildable {
    func build() -> FeaturedController
}
