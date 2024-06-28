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

public typealias CurrentUserInput = Void

public typealias CurrentUserParameter = CurrentUserInput

// MARK: - Output

public typealias CurrentUserOutput = User?

// MARK: - Command

public enum CurrentUserCommand {}

// MARK: - Action

public enum CurrentUserAction: BoardFlowAction {}
