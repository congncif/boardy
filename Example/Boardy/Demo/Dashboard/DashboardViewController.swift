//
//  DashboardViewController.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import RxSwift
import UIKit

final class DashboardViewController: ListViewController, DashboardController {
    private(set) var composedElements: [UIElement] = [] {
        didSet {
            let items = composedElements.map {
                UIBoardItem(identifier: $0.identifier, version: Int.random(in: 1 ... 1000), viewController: $0.contentViewController ?? UIViewController())
            }
            boardItems.onNext(items)
        }
    }

    func composeInterface(elements: [UIElement]) {
        composedElements = elements
        print("COMPOSE elements: \(elements)")
    }

    weak var delegate: DashboardDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("👉 \(String(describing: self)) 👉 \(#function)")
    }
}
