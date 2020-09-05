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

final class LoginBoard: Board, ActivatableBoard {
    @LazyInjected var builder: LoginBuildable

    init() {
        super.init(identifier: .login)
    }

    func activate(withOption option: Any?) {
        let login = builder.build()
        login.delegate = self
        login.modalPresentationStyle = .fullScreen
        login.modalTransitionStyle = .crossDissolve
        rootViewController.topPresentedViewController.present(login, animated: true)
    }
}

extension LoginBoard: LoginDelegate {
    func didLogin(userInfo: UserInfo) {
        rootViewController.dismiss(animated: true, completion: { [weak self] in
            self?.nextToBoard(.main(userInfo: userInfo))
        })
    }
}
