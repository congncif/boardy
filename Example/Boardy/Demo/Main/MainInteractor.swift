//
//  MainInteractor.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 8/10/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

protocol MainRouting: ViewableRouting {}

protocol MainPresentable: Presentable {
    var listener: MainPresentableListener? { get set }

    func showUserInfo(_ userInfo: UserInfo)
}

protocol MainListener: AnyObject {
    func didLogout()
    func showDashboard()
}

final class MainInteractor: PresentableInteractor<MainPresentable>, MainInteractable, MainPresentableListener {
    weak var router: MainRouting?
    weak var listener: MainListener?

    private let userInfo: UserInfo

    init(presenter: MainPresentable, userInfo: UserInfo) {
        self.userInfo = userInfo
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        presenter.showUserInfo(userInfo)
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func performLogout() {
        // Perform logout here
        listener?.didLogout()
    }

    func showDashboard() {
        listener?.showDashboard()
    }
}
