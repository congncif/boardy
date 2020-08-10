//
//  MainViewController.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift
import UIKit

protocol MainPresentableListener: AnyObject {
    func performLogout()
}

final class MainViewController: UIViewController, MainPresentable, MainViewControllable {
    weak var listener: MainPresentableListener?

    @IBOutlet private var nameLabel: UILabel!

    private var userInfoHandler: (() -> Void)?

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfoHandler?()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction private func logoutButtonDidTap() {
        listener?.performLogout()
    }

    func showUserInfo(_ userInfo: UserInfo) {
        userInfoHandler = { [weak self] in
            self?.nameLabel.text = "Hello \(userInfo.username)!"
        }
    }
}
