//
//  HeadlineViewController.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit
import ViewStateCore

final class HeadlineViewController: UIViewController, HeadlineController {

    // MARK: Dependencies

    weak var delegate: HeadlineDelegate?

    lazy var state = HeadlineViewState()

    // MARK: LifeCycle

    deinit {
        print("👉 \(String(describing: self)) 👉 \(#function)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        state.register(subscriberObject: self)
    }

    func accept(label: String) {
        print("Accept a input: \(label)")
    }

    // MARK: Privates

    @IBAction private func returnButtonDidTap() {
        delegate?.returnRoot()
    }

    @IBAction private func nextButtonDidTap() {
        delegate?.gotoNext()
    }
}

// MARK: - Behaviors

extension HeadlineViewController {
    // testable func
}

// MARK: - ViewState

extension HeadlineViewController: DedicatedViewStateRenderable {
    func dedicatedRender(state: HeadlineViewState) {
        // handle state changes
    }
}
