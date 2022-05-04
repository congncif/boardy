//
//  RootViewController.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/13/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit
import ViewStateCore

final class RootViewController: UIViewController, RootController {
    // MARK: Dependencies

    weak var delegate: RootDelegate?

    lazy var state: RootViewState = .init()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        state.register(subscriberObject: self)
    }

    override func viewDidDisplay() {
        delegate?.didReadyToShow()
    }

    override func viewDidResume() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.startButton.isHidden = !self.isVisible
        }
    }

    // MARK: Privates

    @IBOutlet private var startButton: UIButton!

    @IBAction private func startButtonDidTap() {
        startButton.isHidden = true
        delegate?.startApplication()
    }
}

// MARK: - Behaviors

extension RootViewController {
    // testable func
}

// MARK: - ViewState

extension RootViewController: DedicatedViewStateRenderable {
    func dedicatedRender(state _: RootViewState) {
        // handle state changes
    }
}
