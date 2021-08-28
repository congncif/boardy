//
//  LoginBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Boardy
import Foundation
import Resolver
import UIComposable

protocol XXX: UIViewController, ComposableInterface {
    
}

final class LoginBoard: ModernContinuableBoard, ActivatableBoard, GuaranteedCommandBoard {
    func interact(command: String) {}

    @LazyInjected var builder: LoginBuildable

    typealias CommandType = String

    init() {
        super.init(identifier: .login, boardProducer: NoBoardProducer())
    }

    func activate(withOption option: Any?) {
        let login = builder.build()
        login.delegate = self
        login.modalPresentationStyle = .fullScreen
        login.modalTransitionStyle = .crossDissolve
        rootViewController.topPresentedViewController.present(login, animated: true)
        
//        var xxx: XXX!
//        
//        xxx.attachObject(self)
//        
//        attachComposableMotherboard(to: xxx, configurationBuilder: {_ in})
    }
}

extension LoginBoard: LoginDelegate {
    func didLogin(userInfo: UserInfo) {
        rootViewController.dismiss(animated: true, completion: { [weak self] in
            self?.nextToBoard(.main(userInfo: userInfo))
        })
    }
}
