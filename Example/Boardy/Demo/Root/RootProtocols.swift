//
//  RootProtocols.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/13/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit

protocol RootController: UIViewController {
    var delegate: RootDelegate? { get set }
}

protocol RootDelegate: AnyObject {
    func didReadyToShow()
    func startApplication()
}

protocol RootBuildable {
    func build() -> RootController
}
