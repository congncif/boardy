//
//  PlaceholderViewController.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import RIBs
import UIKit

protocol PlaceholderPresentableListener: AnyObject {}

final class PlaceholderViewController: PlaceholderPresentable, PlaceholderViewControllable {
    weak var listener: PlaceholderPresentableListener?

    private weak var viewController: UIViewController?

    var uiviewController: UIViewController {
        return viewController ?? UIViewController()
    }

    func setViewController(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}
