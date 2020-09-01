//
//  LoginBuilder.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import SiFUtilities

struct LoginBuilder: LoginBuildable {
    func build() -> LoginController {
        LoginViewController.instantiateFromStoryboard()
    }
}
