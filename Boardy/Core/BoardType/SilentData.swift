//
//  SilentData.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 2/3/21.
//

import Foundation

/// Silent Data Types is pre-defined types (`BoardFlowAction`, `BoardInputModel`, `BoardCommandModel`, `CompleteAction`) for the certain purpose of the board activities. They should be excluded from type checking to avoid raising unnecessary problems.
#if canImport(UIComposable)
import UIComposable

func isSilentData(_ data: Any?) -> Bool {
    if data is BoardFlowAction || data is BoardInputModel || data is BoardCommandModel || data is CompleteAction || data is UIElementAction {
        return true
    }
    return false
}

#else

func isSilentData(_ data: Any?) -> Bool {
    if data is BoardFlowAction || data is BoardInputModel || data is BoardCommandModel || data is CompleteAction {
        return true
    }
    return false
}

#endif
