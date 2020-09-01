//
//  LoginProtocols.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import UIKit

protocol LoginDelegate: AnyObject {
    func didLogin(userInfo: UserInfo)
}

protocol LoginController: UIViewController {
    var delegate: LoginDelegate? { get set }
}

protocol LoginBuildable {
    func build() -> LoginController
}
