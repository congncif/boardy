//
//  LoginInOut.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - Input

public typealias LoginInput = Void

public typealias LoginParameter = LoginInput

// MARK: - Output

public typealias LoginOutput = User

// MARK: - Command

public typealias LoginCommand = Void

// MARK: - Action

public enum LoginAction: BoardFlowAction {}
