//
//  URL+Extensions.swift
//  Boardy
//
//  Created by CONGNC7 on 11/05/2022.
//

import Foundation

public extension URL {
    var boardy: BoardyURLExtensions {
        BoardyURLExtensions(url: self)
    }
}

public struct BoardyURLExtensions {
    let url: URL

    public var queryParameters: [String: String] {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems {
            return queryItems.reduce(into: [:]) { partialResult, item in
                partialResult[item.name] = item.value?.removingPercentEncoding
            }
        } else {
            return [:]
        }
    }

    public var queryData: Data {
        (try? JSONSerialization.data(withJSONObject: queryParameters, options: .prettyPrinted)) ?? Data()
    }
}
