//
//  FeaturedViewController.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ViewStateCore

final class FeaturedViewController: UIViewController, FeaturedController {
    // MARK: Dependencies

    weak var delegate: FeaturedDelegate?

    lazy var state: FeaturedViewState = FeaturedViewState()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        state.register(subscriberObject: self)
    }

    // MARK: Privates

    @IBOutlet private var bottomConstraint: NSLayoutConstraint!

    @IBAction private func goButtonDidTap() {
        let randomSpace = CGFloat.random(in: 50 ... 150)
        bottomConstraint.constant = randomSpace
        delegate?.featuredContentDidUpdate()
    }
}

// MARK: - Behaviors

extension FeaturedViewController {
    // testable func
}

// MARK: - ViewState

extension FeaturedViewController: DedicatedViewStateRenderable {
    func dedicatedRender(state: FeaturedViewState) {
        // handle state changes
    }
}
