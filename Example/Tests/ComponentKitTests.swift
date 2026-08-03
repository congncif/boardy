//
//  ComponentKitTests.swift
//  Boardy_Tests
//
//  SLICE S3 — the two documented ComponentKit components with no verification.
//  See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4 items 1.3 and 1.11.
//  DEPENDS ON: TestSupport.swift (`UIHost`).
//
//  Contracts to assert:
//
//  1.3 `FlowBoard` (docs/ComponentKit.md — "a Board with flow registrations only", 0% covered)
//      · the registration closure runs and its flows are live
//      · the activation closure receives the board and the typed input
//      · the interaction closure receives a typed command
//      · `shouldBypassGatewayBarrier()` follows `allowBypassGatewayBarrier`
//
//  1.11 `AlertBoard`
//      · presents a `UIAlertController` with the documented style
//      · an action's handler runs when that action is invoked
//      · `activateAlert(_:)` is equivalent to activating the board directly
//      · the target-based `AlertAction` init holds its target weakly
//
//  API brief — FlowBoard's init is not obvious:
//      FlowBoard<Input, Output, Command, Action>(
//          identifier: BoardID,
//          producer: ActivatableBoardProducer,        // a producer, NOT a motherboard
//          allowBypassGatewayBarrier: Bool = true,
//          flowRegistration: (FlowBoard) -> Void,     // called from init, via registerFlows()
//          flowActivation: (FlowBoard, Input) -> Void,
//          flowInteraction: (FlowBoard, Command) -> Void = <debug-logging default>)
//      `Action` must conform to `BoardFlowAction`.
//      AlertBoard: `Alert(title:message:style:actions:)`, `AlertAction(title:style:shouldBePreferred:handler:)`.
//
//  Traps:
//      · `flowRegistration` runs during `init`, before the board is installed. A registration that
//        assumes a delegate will not see one.
//      · `AlertBoard` presents through `rootViewController`; without a `UIHost` it traps in DEBUG.
//      · Presentation completes synchronously only when the host window is key and visible — `UIHost`
//        does that by default.
//
//  Rules: no wall-clock waits. Do not edit any file outside this one. If production code looks
//  wrong — likely here, since FlowBoard has never executed in a test — stop and report, do not fix.
//

@testable import Boardy
import UIKit
import XCTest

final class ComponentKitTests: XCTestCase {}
