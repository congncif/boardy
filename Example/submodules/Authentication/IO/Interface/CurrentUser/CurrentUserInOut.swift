//
//  CurrentUserInOut.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - Input

public struct CurrentUserInput {
    public private(set) weak var observer: CurrentUserObserver?

    public init(observer: CurrentUserObserver?) {
        self.observer = observer
    }
}

public typealias CurrentUserParameter = CurrentUserInput

// MARK: - Output

public typealias CurrentUserOutput = Void

// MARK: - Command

public typealias CurrentUserCommand = Void

// MARK: - Action

public enum CurrentUserAction: BoardFlowAction {}

public protocol CurrentUserObserver: AnyObject {
    func update(currentUser: User?)
}
