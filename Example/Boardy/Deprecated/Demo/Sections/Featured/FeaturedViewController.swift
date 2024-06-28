//
//  FeaturedViewController.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import SiFUtilities
import UIKit
import ViewStateCore

final class FeaturedViewController: UIViewController, FeaturedController {
    // MARK: Dependencies

    weak var delegate: FeaturedDelegate?

    lazy var state: FeaturedViewState = .init()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random()

        state.register(subscriberObject: self)
    }

    // MARK: Privates

    @IBOutlet private var constraint: NSLayoutConstraint!

    @IBAction private func goButtonDidTap() {
        let randomSpace = CGFloat.random(in: 50 ... 150)
        constraint.constant = randomSpace

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }

        view.closestContainerTableView?.performUpdates()
    }

    @IBAction private func removeButtonDidTap() {
        delegate?.removeFeaturedContent()
    }

    @IBAction private func refreshButtonDidTap() {
        delegate?.refreshHeadline()
    }
}

// MARK: - Behaviors

extension FeaturedViewController {
    // testable func
}

// MARK: - ViewState

extension FeaturedViewController: DedicatedViewStateRenderable {
    func dedicatedRender(state _: FeaturedViewState) {
        // handle state changes
    }
}
