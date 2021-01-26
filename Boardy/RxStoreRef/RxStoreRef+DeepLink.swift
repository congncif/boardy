//
//  RxStoreRef+DeepLink.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 9/15/20.
//

import Foundation
import ReferenceStoreManager
import UIKit

extension DeepLinkHandler: PairableObject, SelfStorableObject {}

extension NSObject {
    public func handleDeepLink(_ deepLink: String, usePairClub handlerClub: DeepLinkHandlerClubbing) {
        let deepLinkHandler: DeepLinkHandlingComposable
        if let handler: DeepLinkHandlingComposable = pairedObject() {
            handler.registerHandlerClubIfNeeded(handlerClub)
            deepLinkHandler = handler
        } else {
            let handler = DeepLinkHandler(handlerClubbing: handlerClub)
            handler.pairWith(object: self)
            deepLinkHandler = handler
        }
        deepLinkHandler.start(with: self)
        deepLinkHandler.handleDeepLink(deepLink)
    }
}
