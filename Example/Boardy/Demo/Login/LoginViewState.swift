//
//  LoginViewState.swift
//  SuperProject
//
//  Created by NGUYEN CHI CONG on 2/9/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import ViewStateCore

final class LoginViewState: ViewState {
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
}

extension LoginViewState {
    var userInfo: UserInfo {
        UserInfo(username: username, password: password)
    }
}
