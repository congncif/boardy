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
    @LazyInjected var appMainBoard: AppMotherboard

    override func viewDidLoad() {
        super.viewDidLoad()
        appMainBoard.install(into: self)
    }

    override func viewDidDisplay() {
        appMainBoard.activateBoard(.login)
    }
}
