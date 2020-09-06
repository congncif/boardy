//
//  DeepLinkHandlerLivable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/6/20.
//

import Foundation
import UIKit

public protocol DeepLinkHandlerLivable: AnyObject {
    var deepLinkHandler: DeepLinkHandlingComposable { get set }
}

private var deepLinkHandlerKey: UInt8 = 106

extension DeepLinkHandlerLivable where Self: UIViewController {
    func getAssociatedDeepLinkHandler() -> DeepLinkHandlingComposable? {
        return objc_getAssociatedObject(self, &deepLinkHandlerKey) as? DeepLinkHandlingComposable
    }

    func setAssociatedDeepLinkHandler(_ value: DeepLinkHandlingComposable?) {
        objc_setAssociatedObject(self, &deepLinkHandlerKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var deepLinkHandler: DeepLinkHandlingComposable {
        get {
            if let handler = getAssociatedDeepLinkHandler() {
                return handler
            } else {
                let newHandler = DeepLinkHandler()
                setAssociatedDeepLinkHandler(newHandler)
                return newHandler
            }
        }

        set {
            newValue.start(with: self)
            setAssociatedDeepLinkHandler(newValue)
        }
    }
}

// MARK: - Utility extensions

extension UIViewController: DeepLinkHandlerLivable {
    public func registerDeepLinkHandlerClubIfNeeded(_ handlerClub: DeepLinkHandlerClubbing) {
        if deepLinkHandler.registredHandlerClub(withIdentifier: handlerClub.identifier) == nil {
            deepLinkHandler.registerHandlerClub(handlerClub)
        }
    }

    public func handleDeepLink(_ deepLink: String, with handlerClub: DeepLinkHandlerClubbing) {
        registerDeepLinkHandlerClubIfNeeded(handlerClub)
        deepLinkHandler.handleDeepLink(deepLink)
    }
}
