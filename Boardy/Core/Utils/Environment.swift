//
//  Environment.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 5/26/21.
//

import Foundation

#if DEBUG
enum Environment {
    static var boardyLogEnabled: Bool {
        if let environmentValue = ProcessInfo().environment["BOARDY_LOG_ENABLED"] {
            let lowercase = environmentValue.uppercased()
            return lowercase == "TRUE" || lowercase == "YES"
        }
        return false
    }
}
#endif
