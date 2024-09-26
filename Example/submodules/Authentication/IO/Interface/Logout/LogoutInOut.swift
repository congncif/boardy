//
//  LogoutInOut.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 22/8/24.
//  Compatible with Boardy 1.55.1 or later
//

import Boardy
import Foundation

// MARK: - Input

public typealias LogoutInput = Void

public typealias LogoutParameter = BlockTaskParameter<LogoutInput, LogoutOutput>

// MARK: - Output

public typealias LogoutOutput = User?

// MARK: - Command

public typealias LogoutCommand = Void

// MARK: - Action

public enum LogoutAction: BoardFlowAction {}
