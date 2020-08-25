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

class ViewController: UIViewController {
    @LazyInjected var motherboard: Motherboard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        motherboard.registerFlowSteps(.login >=> .main >=> .login)
        
        motherboard.install(into: self)
    }

    override func viewDidDisplay() {
        motherboard.activateBoard(identity: .login)
    }
}
