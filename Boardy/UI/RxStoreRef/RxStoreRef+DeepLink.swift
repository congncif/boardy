//
//  RxStoreRef+DeepLink.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation

extension DeepLinkHandler: ObjectReferenceStorable {}

extension UIViewController {
    public func handleDeepLink(_ deepLink: String, usePairClub handlerClub: DeepLinkHandlerClubbing) {
        let deepLinkHandler = DeepLinkHandler(handlerClubbing: handlerClub)
        deepLinkHandler.pairWith(object: self)
        deepLinkHandler.start(with: self)
        deepLinkHandler.handleDeepLink(deepLink)
    }
}
