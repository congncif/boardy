//
//  PlaceholderRouter.swift
//  
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import RIBs
import UIKit

protocol PlaceholderInteractable: Interactable {
    var router: PlaceholderRouting? { get set }
    var listener: PlaceholderListener? { get set }
}

protocol PlaceholderViewControllable: ViewControllable {
    func setViewController(_ viewController: UIViewController?)
}

final class PlaceholderRouter: ViewableRouter<PlaceholderInteractable, PlaceholderViewControllable>, PlaceholderRouting {
    override init(interactor: PlaceholderInteractable, viewController: PlaceholderViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func injectViewController(_ viewController: UIViewController?) {
        self.viewController.setViewController(viewController)
    }
    
    deinit {
        injectViewController(nil)
    }
}
