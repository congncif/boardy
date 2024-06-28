//
//  LogoutInOut.swift
//  Authentication
//
//  Created by NGUYEN CHI CONG on 28/6/24.
//  Compatible with Boardy 1.54 or later
//

import Boardy
import Foundation

// MARK: - Input

public typealias LogoutInput = Void

public typealias LogoutParameter = LogoutInput

// MARK: - Output

public typealias LogoutOutput = User?

// MARK: - Command

public enum LogoutCommand {}

// MARK: - Action

public enum LogoutAction: BoardFlowAction {}
