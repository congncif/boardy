//
//  DashboardViewController.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIComposable
import UIKit

final class DashboardViewController: DiffComposableListViewController, DashboardController {
    weak var delegate: DashboardDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(changeButtonDidTap))
        navigationItem.rightBarButtonItem = rightBarItem
    }

    deinit {
        print("👉 \(String(describing: self)) 👉 \(#function)")
    }

    @IBAction private func changeButtonDidTap() {
        delegate?.changePlugins(viewController: self)
    }
}
