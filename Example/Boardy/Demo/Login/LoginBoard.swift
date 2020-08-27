//
//  LoginBoard.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Boardy
import Foundation

final class LoginBoard: Board, ActivatableBoard {
    private let builder: LoginBuildable

    init(builder: LoginBuildable) {
        self.builder = builder
        super.init(identifier: .login)
    }

    func activate(withOption option: Any?) {
        let login = builder.build()
        login.delegate = self
        login.modalPresentationStyle = .fullScreen
        rootViewController.present(login, animated: true)
    }
}

extension LoginBoard: LoginDelegate {
    func didLogin(userInfo: UserInfo) {
        rootViewController.dismiss(animated: true, completion: { [weak self] in
            self?.sendToMotherboard(data: userInfo)
        })
    }
}
