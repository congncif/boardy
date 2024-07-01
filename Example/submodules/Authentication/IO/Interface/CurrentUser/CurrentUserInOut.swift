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

public final class CurrentUserInput: BusCable<User?> {
    public private(set) weak var listener: CurrentUserListener?

    public init(listener: CurrentUserListener?) {
        self.listener = listener
        super.init { [weak listener] user in
            listener?.receive(currentUser: user)
        }
    }

    override public var isValid: Bool {
        listener != nil
    }

    override public func invalidate() {
        listener = nil
    }
}

public typealias CurrentUserParameter = CurrentUserInput

// MARK: - Output

public typealias CurrentUserOutput = Void

// MARK: - Command

public enum CurrentUserCommand {}

// MARK: - Action

public enum CurrentUserAction: BoardFlowAction {}

public protocol CurrentUserListener: AnyObject {
    func receive(currentUser: User?)
}
