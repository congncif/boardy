//
//  DashboardViewController.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/27/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import RxSwift
import UIComposable
import UIKit

final class DashboardViewController: ListViewController, DashboardController {
    private(set) var composedElements: [UIElement] = [] {
        didSet {
            let items: [UIBoardItem] = composedElements.compactMap {
                guard let content = $0.contentViewController else { return nil }
                return UIBoardItem(identifier: $0.identifier, version: Int($0.version), viewController: content)
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

        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(changeButtonDidTap))
        navigationItem.rightBarButtonItem = rightBarItem
    }

    deinit {
        print("👉 \(String(describing: self)) 👉 \(#function)")
    }

    @IBAction private func changeButtonDidTap() {
        delegate?.changePlugins(viewController: self)
    }
}
