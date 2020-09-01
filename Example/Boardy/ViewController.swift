//
//  ViewController.swift
//  Boardy
//
//  Created by congncif on 08/08/2020.
//  Copyright (c) 2020 congncif. All rights reserved.
//

import Boardy
import Resolver
import UIKit

final class ViewController: UIViewController {
    @LazyInjected var motherboard: AppMotherboard

    override func viewDidLoad() {
        super.viewDidLoad()
        motherboard.install(into: self)
    }

    override func viewDidDisplay() {
        motherboard.activateBoard(identity: .login)
    }
}
