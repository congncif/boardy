//
//  DeepLink+Attachable.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/26/21.
//

import Foundation
import UIKit

extension UIViewController {
    public func handleDeepLink(_ deepLink: String, handlerClub: DeepLinkHandlerClubbing) {
        let deepLinkHandler: DeepLinkHandlingComposable
        if let handler: DeepLinkHandlingComposable = firstAttachedObject() {
            handler.registerHandlerClubIfNeeded(handlerClub)
            deepLinkHandler = handler
        } else {
            let handler = DeepLinkHandler(handlerClubbing: handlerClub)
            attachObject(handler)
            deepLinkHandler = handler
        }
        deepLinkHandler.start(with: self)
        deepLinkHandler.handleDeepLink(deepLink)
    }
}
