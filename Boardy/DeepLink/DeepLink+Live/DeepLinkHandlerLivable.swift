//
//  DeepLinkHandlerLivable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/6/20.
//

import Foundation
import UIKit

public protocol DeepLinkHandlerLivable: AnyObject {
    var deepLinkHandler: DeepLinkHandlingComposable? { get set }
    var lazyDeepLinkHandler: DeepLinkHandlingComposable { get }
}

private var deepLinkHandlerKey: UInt8 = 106

extension DeepLinkHandlerLivable where Self: AnyObject {
    func getAssociatedDeepLinkHandler() -> DeepLinkHandlingComposable? {
        return objc_getAssociatedObject(self, &deepLinkHandlerKey) as? DeepLinkHandlingComposable
    }

    func setAssociatedDeepLinkHandler(_ value: DeepLinkHandlingComposable?) {
        value?.start(with: self)
        objc_setAssociatedObject(self, &deepLinkHandlerKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public var deepLinkHandler: DeepLinkHandlingComposable? {
        get {
            getAssociatedDeepLinkHandler()
        }

        set {
            setAssociatedDeepLinkHandler(newValue)
        }
    }

    public var lazyDeepLinkHandler: DeepLinkHandlingComposable {
        if let handler = getAssociatedDeepLinkHandler() {
            return handler
        } else {
            let newHandler = DeepLinkHandler()
            setAssociatedDeepLinkHandler(newHandler)
            return newHandler
        }
    }
}

// MARK: - Utility extensions

extension NSObject: DeepLinkHandlerLivable {
    public func handleDeepLink(_ deepLink: String, use handlerClub: DeepLinkHandlerClubbing) {
        lazyDeepLinkHandler.registerHandlerClubIfNeeded(handlerClub)
        lazyDeepLinkHandler.handleDeepLink(deepLink)
    }
}
