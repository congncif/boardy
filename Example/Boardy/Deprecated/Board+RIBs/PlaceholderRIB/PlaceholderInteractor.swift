//
//  PlaceholderInteractor.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import RIBs
import UIKit

public protocol PlaceholderRouting: ViewableRouting {
    func injectViewController(_ viewController: UIViewController?)
}

protocol PlaceholderPresentable: Presentable {
    var listener: PlaceholderPresentableListener? { get set }
}

protocol PlaceholderListener: AnyObject {}

final class PlaceholderInteractor: PresentableInteractor<PlaceholderPresentable>, PlaceholderInteractable, PlaceholderPresentableListener {
    weak var router: PlaceholderRouting?
    weak var listener: PlaceholderListener?

    override init(presenter: PlaceholderPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }

    override func willResignActive() {
        super.willResignActive()
    }
}
