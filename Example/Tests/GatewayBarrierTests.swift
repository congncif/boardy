//
//  GatewayBarrierTests.swift
//  Boardy_Tests
//
//  SLICE S1 — Gateway Barrier. See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4.
//
//  Contracts to assert (from docs/Activation Barrier.md §🛡️ and §⛳):
//
//  1.1 Conditional gateway — `GatewayBarrierRegistration.registerWithActivation`
//      · the gate is activated before the destination board is
//      · gate completes true  → destination activates, with its original option
//      · gate completes false → destination does NOT activate
//      · `withFlowRegistration` is invoked so the gate can wire its own flow
//      · the barrier board is removed once the gate resolves
//
//  1.2 Bypass
//      · a board returning `shouldBypassGatewayBarrier() == true` activates without the gate running
//      · `.exempt` registered for one identifier bypasses only that identifier
//      · `.wildcard` gateway registration applies to every other identifier
//
//  API brief — verified signatures, do not guess:
//      GatewayBarrierRegistration.registerWithActivation { (barrier: GatewayBarrierBoard, option: Any?) in }
//          .withFlowRegistration { (barrier: GatewayBarrierBoard) in }
//      PluginLauncher.with(options: .default)
//          .install(plugin:) .install(gatewayBarrier:for:) .install(gatewayBarrier:)
//          .instantiate { mainboard in } → then .activateNow { mainboard in }
//      Producer-side: BoardProducer.registerGatewayBoard(_:factory:) — note it appends
//          `.gateway` to the identifier internally; `.wildcard.gateway` is the catch-all key.
//
//  Traps already hit in this repo:
//      · Activating an identifier nothing is registered for produces a `NoBoard`, whose activation
//        presents an alert and traps in DEBUG without a UIKit context. Register every identifier a
//        test activates, or install a `UIHost`.
//      · A gateway barrier that never completes leaves the activation queued — that is the designed
//        behaviour, not a hang. Assert "not activated", never wait for it.
//
//  Rules: no wall-clock waits; use `hangGuardTimeout` for deadlock guards only; name each test after
//  the contract it asserts. Do not edit any file outside this one. If production code looks wrong,
//  stop and report — do not fix it here.
//

@testable import Boardy
import XCTest

final class GatewayBarrierTests: XCTestCase {}
