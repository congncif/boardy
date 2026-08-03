//
//  ServiceMapTests.swift
//  Boardy_Tests
//
//  SLICE S4 — ServiceMap and bulk board registration.
//  See docs/02-working-docs/review/2026-08-02-coverage-plan.md §4 items 1.4 and 1.9.
//
//  Contracts to assert:
//
//  1.4 `ServiceMap` (docs/ServiceMap.md — has its own page, zero tests)
//      · `motherboard.serviceMap` is reachable from any FlowMotherboard
//      · a module's own map, exposed via `extension ServiceMap`, returns a working destination
//      · `link(_:)` produces a typed sub-map sharing the same mainboard
//      · `board.serviceMap` reaches the map through the board's motherboard
//      · a board that is NOT installed traps — that is the documented precondition
//
//  1.9 `registerBoards` (docs/BU.md lists it as BoardContainer's distinguishing capability)
//      · several identifiers can share one factory
//      · each identifier produces its own instance
//      · the variadic and array forms agree
//
//  API brief:
//      ServiceMap(mainboard: FlowMotherboard) — `required init`, so subclasses inherit it.
//      Extend with: `public extension ServiceMap { var myModule: MyMap { MyMap(mainboard: mainboard) } }`
//      `link<MapType: ServiceMap>(_:)` for a ServiceMap subclass.
//      BoardContainer.registerBoards([BoardID], factory:) and the variadic overload.
//
//  Traps:
//      · `IdentifiableBoard.serviceMap` calls `preconditionFailure` when the board has no
//        motherboard. That is by design and is one of the contracts to assert — use
//        CwlPreconditionTesting's `catchBadInstruction`, the way FlowTests does, rather than letting
//        the test crash.
//      · `serviceMap` builds a NEW ServiceMap each access; do not assert identity between two reads.
//
//  Rules: no wall-clock waits. Do not edit any file outside this one — in particular not
//  ProducerTests.swift. If production code looks wrong, stop and report.
//

@testable import Boardy
import XCTest

final class ServiceMapTests: XCTestCase {}
