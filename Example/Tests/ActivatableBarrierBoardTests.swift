//
//  ActivatableBarrierBoardTests.swift
//  Boardy_Tests
//
//  Created by CONGNC7 on 04/05/2022.
//  Copyright © 2022 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

private final class SafeDictionaryReference {}

private final class BarrierProbeBoard: Board, ActivatableBoard {
    weak var owner: BarrierTestMotherboard?

    init(identifier: BoardID, owner: BarrierTestMotherboard) {
        self.owner = owner
        super.init(identifier: identifier)
    }

    func activate(withOption option: Any?) {
        owner?.recordBarrierActivation(option)
    }
}

private final class BarrierTargetBoard: Board, GuaranteedBoard, @unchecked Sendable {
    typealias InputType = String

    let barrierDestination: BoardID
    let barrierScope: ActivationBarrierScope
    private(set) var activatedValues: [String] = []
    var activationHandler: ((String) -> Void)?

    init(
        identifier: BoardID,
        barrierDestination: BoardID,
        barrierScope: ActivationBarrierScope = .application
    ) {
        self.barrierDestination = barrierDestination
        self.barrierScope = barrierScope
        super.init(identifier: identifier)
    }

    func activationBarrier(withGuaranteedInput _: String) -> ActivationBarrier? {
        ActivationBarrier(
            identifier: barrierDestination,
            scope: barrierScope,
            option: .void
        )
    }

    func activate(withGuaranteedInput input: String) {
        activatedValues.append(input)
        activationHandler?(input)
    }
}

private final class BarrierTestMotherboard: Board, MotherboardType, BoardDelegate, FlowManageable, @unchecked Sendable {
    let barrierDestination: BoardID
    private(set) var boards: [ActivatableBoard] = []
    private(set) var flows: [BoardFlow] = []
    private(set) var barrierActivationOptions: [Any?] = []
    private(set) var installCounts: [BoardID: Int] = [:]
    private(set) var removalCounts: [BoardID: Int] = [:]
    private(set) var duplicateInstallAttempts = 0
    private(set) var duplicateRemovalAttempts = 0
    var boardInstallationHandler: ((ActivatableBoard) -> Void)?

    init(identifier: BoardID = .random(), barrierDestination: BoardID) {
        self.barrierDestination = barrierDestination
        super.init(identifier: identifier)

        registerGeneralFlow { [weak self] (input: BoardInputModel) in
            self?.activateBoard(model: input)
        }
        registerGeneralFlow { [weak self] (action: CompleteAction) in
            self?.removeBoard(withIdentifier: action.identifier)
        }
    }

    var barrierActivationCount: Int {
        barrierActivationOptions.count
    }

    @discardableResult
    func registerFlow(_ flow: BoardFlow) -> Self {
        flows.append(flow)
        return self
    }

    func resetFlows() {
        flows.removeAll()
    }

    func removeFlow(by identifier: String) {
        flows.removeAll { $0.identifier == identifier }
    }

    func addBoard(_ board: ActivatableBoard) {
        guard boards.contains(where: { $0.identifier == board.identifier }) == false else {
            duplicateInstallAttempts += 1
            return
        }
        boards.append(board)
        board.delegate = self
        installCounts[board.identifier, default: 0] += 1
        boardInstallationHandler?(board)
    }

    func removeBoard(withIdentifier identifier: BoardID) {
        guard boards.contains(where: { $0.identifier == identifier }) else {
            duplicateRemovalAttempts += 1
            return
        }
        boards.removeAll { $0.identifier == identifier }
        removalCounts[identifier, default: 0] += 1
    }

    func getBoard(identifier: BoardID) -> ActivatableBoard? {
        if let installed = boards.first(where: { $0.identifier == identifier }) {
            return installed
        }
        guard identifier == barrierDestination else { return nil }
        let probe = BarrierProbeBoard(identifier: identifier, owner: self)
        installBoard(probe)
        return probe
    }

    func getGatewayBoard(identifier _: BoardID) -> ActivatableBoard? {
        nil
    }

    func clearActiveBoards() {
        boards.removeAll()
    }

    func finishBarrier(isDone: Bool) -> Bool {
        guard let probe = boards.first(where: { $0.identifier == barrierDestination }) else {
            return false
        }
        probe.complete(isDone)
        return true
    }

    fileprivate func recordBarrierActivation(_ option: Any?) {
        barrierActivationOptions.append(option)
    }
}

final class BarrierAuthBoard: Board, GuaranteedBoard {
    typealias InputType = Void

    var activated: Bool = false
    var stubIsDone: Bool = true

    func activate(withGuaranteedInput _: Void) {
        if activated {
            complete(stubIsDone)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                self.activated = true
                self.complete(self.stubIsDone)
            }
        }
    }
}

final class BarrierSutBoard: Board, GuaranteedBoard {
    typealias InputType = String

    var activatedValue: String?
    var stubActivationBarrier: ActivationBarrier?

    func activationBarrier(withOption _: Any?) -> ActivationBarrier? {
        stubActivationBarrier
    }

    func activate(withGuaranteedInput input: String) {
        activatedValue = input
    }
}

class ActivatableBarrierBoardTests: XCTestCase {
    var sutMotherboard: Motherboard!
    var sutBoard: BarrierSutBoard!
    var sut2Board: BarrierSutBoard!
    var authBoard: BarrierAuthBoard!

    override func setUpWithError() throws {
        sutBoard = BarrierSutBoard(identifier: sampleBarrierSutID)
        sut2Board = BarrierSutBoard(identifier: sampleBarrierSutID2)
        authBoard = BarrierAuthBoard(identifier: sampleBarrierAuthID)

        sutMotherboard = Motherboard(registrationsBuilder: { _ in
            authBoard
            sutBoard
            sut2Board
        })
    }

    override func tearDownWithError() throws {}

    func testSafeDictionaryValueOrInsertReturnsOneSharedReference() {
        let dictionary = SafeDictionary<String, SafeDictionaryReference>()
        let resultLock = NSLock()
        var identifiers: [ObjectIdentifier] = []

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            let value = dictionary.value(forKey: "shared") {
                SafeDictionaryReference()
            }
            resultLock.lock()
            identifiers.append(ObjectIdentifier(value))
            resultLock.unlock()
        }

        XCTAssertEqual(Set(identifiers).count, 1)
    }

    func testSafeDictionaryFactoryCanReenterTheSameKey() {
        let dictionary = SafeDictionary<String, SafeDictionaryReference>()
        let completed = expectation(description: "reentrant factory completes")
        let result = Locked<SafeDictionaryReference?>(nil)

        DispatchQueue.global().async {
            let value = dictionary.value(forKey: "shared") {
                dictionary.value(forKey: "shared") {
                    SafeDictionaryReference()
                }
            }
            result.withLock { $0 = value }
            completed.fulfill()
        }

        wait(for: [completed], timeout: 0.5)
        XCTAssertNotNil(result.withLock { $0 })
    }

    func testFailedBarrierInstallationRemovesPartialBoard() {
        let authID: BoardID = .random()
        let target = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        let intendedOwner = BarrierTestMotherboard(barrierDestination: authID)
        let mismatchedDelegate = BarrierTestMotherboard(barrierDestination: authID)
        intendedOwner.installBoard(target)
        let barrierID = ActivationBarrier(
            identifier: authID,
            scope: .application,
            option: .void
        ).barrierIdentifier

        intendedOwner.boardInstallationHandler = { board in
            guard board.identifier == barrierID else { return }
            board.delegate = mismatchedDelegate
        }

        intendedOwner.activateBoard(identifier: target.identifier, withOption: "blocked")

        XCTAssertNil(intendedOwner.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertNil(mismatchedDelegate.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertTrue(target.activatedValues.isEmpty)
        XCTAssertEqual(intendedOwner.removalCounts[barrierID], 1)
    }

    func testCompletionDelegateMismatchCleansOldInstallationBeforeNextOwner() {
        let authID: BoardID = .random()
        let targetA = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        let targetB = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        let ownerA = BarrierTestMotherboard(barrierDestination: authID)
        let ownerB = BarrierTestMotherboard(barrierDestination: authID)
        ownerA.installBoard(targetA)
        ownerB.installBoard(targetB)
        let barrierID = ActivationBarrier(
            identifier: authID,
            scope: .application,
            option: .void
        ).barrierIdentifier

        ownerA.activateBoard(identifier: targetA.identifier, withOption: "owner-a")
        guard let barrier = ownerA.boards.first(where: { $0.identifier == barrierID }) else {
            return XCTFail("Expected owner A barrier installation")
        }
        barrier.delegate = ownerB

        XCTAssertTrue(ownerA.finishBarrier(isDone: true))
        XCTAssertNil(ownerA.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertTrue(targetA.activatedValues.isEmpty)

        ownerB.activateBoard(identifier: targetB.identifier, withOption: "owner-b")
        XCTAssertTrue(ownerB.boards.first(where: { $0.identifier == barrierID }) === barrier)
        XCTAssertTrue(barrier.delegate === ownerB)
        XCTAssertTrue(ownerB.finishBarrier(isDone: true))
        XCTAssertEqual(targetB.activatedValues, ["owner-b"])
        XCTAssertNil(ownerB.boards.first(where: { $0.identifier == barrierID }))
    }

    func testReentrantEnqueueWaitsUntilCompletingCycleIsRemoved() {
        let authID: BoardID = .random()
        let first = BarrierTargetBoard(
            identifier: .random(),
            barrierDestination: authID
        )
        let second = BarrierTargetBoard(
            identifier: .random(),
            barrierDestination: authID
        )
        let manager = BarrierTestMotherboard(barrierDestination: authID)
        manager.installBoard(first)
        manager.installBoard(second)
        let barrierID = ActivationBarrier(
            identifier: authID,
            scope: .application,
            option: .void
        ).barrierIdentifier

        manager.activateBoard(identifier: first.identifier, withOption: "first")
        let barrier = manager.boards.first(where: { $0.identifier == barrierID })
        let registeredFlowCount = manager.flows.count
        XCTAssertEqual(manager.barrierActivationCount, 1)

        let callbackEntered = DispatchSemaphore(value: 0)
        let releaseCallback = DispatchSemaphore(value: 0)
        let completionReturned = expectation(description: "first completion returned")
        first.activationHandler = { _ in
            callbackEntered.signal()
            releaseCallback.wait()
        }

        DispatchQueue.global().async {
            XCTAssertTrue(manager.finishBarrier(isDone: true))
            completionReturned.fulfill()
        }

        XCTAssertEqual(callbackEntered.wait(timeout: .now() + 2), .success)
        XCTAssertNil(manager.boards.first(where: { $0.identifier == barrierID }))

        manager.activateBoard(identifier: second.identifier, withOption: "second")
        XCTAssertEqual(manager.barrierActivationCount, 1)
        XCTAssertTrue(second.activatedValues.isEmpty)

        releaseCallback.signal()
        wait(for: [completionReturned], timeout: 2)

        let reinstalledBarrier = manager.boards.first(where: { $0.identifier == barrierID })
        XCTAssertTrue(reinstalledBarrier === barrier)
        XCTAssertEqual(manager.installCounts[barrierID], 2)
        XCTAssertEqual(manager.removalCounts[barrierID], 1)
        XCTAssertEqual(manager.barrierActivationCount, 2)
        XCTAssertEqual(manager.flows.count, registeredFlowCount)
        XCTAssertEqual(manager.duplicateInstallAttempts, 0)
        XCTAssertTrue(second.activatedValues.isEmpty)

        XCTAssertTrue(manager.finishBarrier(isDone: true))
        XCTAssertEqual(second.activatedValues, ["second"])
        XCTAssertNil(manager.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertEqual(manager.removalCounts[barrierID], 2)
        XCTAssertEqual(manager.duplicateRemovalAttempts, 0)
    }

    func testApplicationBarrierKeepsOwnerUntilCompletionThenHandsOffOnce() {
        let authID: BoardID = .random()
        let targetA = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        let coalescedB = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        let nextCycleB = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        let managerA = BarrierTestMotherboard(barrierDestination: authID)
        let managerB = BarrierTestMotherboard(barrierDestination: authID)
        managerA.installBoard(targetA)
        managerB.installBoard(coalescedB)
        managerB.installBoard(nextCycleB)
        let barrierID = ActivationBarrier(
            identifier: authID,
            scope: .application,
            option: .void
        ).barrierIdentifier

        managerA.activateBoard(identifier: targetA.identifier, withOption: "a")
        guard let barrier = managerA.boards.first(where: { $0.identifier == barrierID }) else {
            return XCTFail("Expected the application barrier to be installed in owner A")
        }
        let flowCountA = managerA.flows.count

        managerB.activateBoard(identifier: coalescedB.identifier, withOption: "b-coalesced")
        XCTAssertNil(managerB.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertTrue(barrier.delegate === managerA)
        XCTAssertEqual(managerA.barrierActivationCount, 1)
        XCTAssertEqual(managerB.barrierActivationCount, 0)

        let callbackEntered = DispatchSemaphore(value: 0)
        let releaseCallback = DispatchSemaphore(value: 0)
        let completionReturned = expectation(description: "owner A completion returned")
        targetA.activationHandler = { _ in
            callbackEntered.signal()
            releaseCallback.wait()
        }

        DispatchQueue.global().async {
            XCTAssertTrue(managerA.finishBarrier(isDone: true))
            completionReturned.fulfill()
        }

        XCTAssertEqual(callbackEntered.wait(timeout: .now() + 2), .success)
        XCTAssertNil(managerA.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertNil(managerB.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertTrue(barrier.delegate === managerA)

        managerB.activateBoard(identifier: nextCycleB.identifier, withOption: "b-next")
        XCTAssertEqual(managerB.barrierActivationCount, 0)

        releaseCallback.signal()
        wait(for: [completionReturned], timeout: 2)

        XCTAssertEqual(targetA.activatedValues, ["a"])
        XCTAssertEqual(coalescedB.activatedValues, ["b-coalesced"])
        XCTAssertTrue(nextCycleB.activatedValues.isEmpty)
        XCTAssertTrue(managerB.boards.first(where: { $0.identifier == barrierID }) === barrier)
        XCTAssertTrue(barrier.delegate === managerB)
        XCTAssertEqual(managerA.installCounts[barrierID], 1)
        XCTAssertEqual(managerB.installCounts[barrierID], 1)
        XCTAssertEqual(managerA.flows.count, flowCountA)
        XCTAssertEqual(managerB.barrierActivationCount, 1)
        XCTAssertEqual(managerA.duplicateInstallAttempts + managerB.duplicateInstallAttempts, 0)

        XCTAssertTrue(managerB.finishBarrier(isDone: true))
        XCTAssertEqual(nextCycleB.activatedValues, ["b-next"])
        XCTAssertNil(managerB.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertEqual(managerB.removalCounts[barrierID], 1)
        XCTAssertEqual(managerA.duplicateRemovalAttempts + managerB.duplicateRemovalAttempts, 0)
    }

    func testDeadApplicationOwnerIsRecoveredAndLateCompletionCannotFinishNewOwner() {
        let authID: BoardID = .random()
        let targetA = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        var managerA: BarrierTestMotherboard? = BarrierTestMotherboard(barrierDestination: authID)
        managerA?.installBoard(targetA)
        managerA?.activateBoard(identifier: targetA.identifier, withOption: "orphan")
        let barrierID = ActivationBarrier(
            identifier: authID,
            scope: .application,
            option: .void
        ).barrierIdentifier
        guard
            let barrier = managerA?.boards.first(where: { $0.identifier == barrierID }),
            let retainedLateCompletion = managerA?.flows.last
        else {
            return XCTFail("Expected owner A barrier registration")
        }

        weak var releasedOwner = managerA
        managerA = nil
        XCTAssertNil(releasedOwner)

        let targetB = BarrierTargetBoard(identifier: .random(), barrierDestination: authID)
        let managerB = BarrierTestMotherboard(barrierDestination: authID)
        managerB.installBoard(targetB)
        managerB.activateBoard(identifier: targetB.identifier, withOption: "new-owner")

        XCTAssertTrue(managerB.boards.first(where: { $0.identifier == barrierID }) === barrier)
        XCTAssertTrue(barrier.delegate === managerB)
        XCTAssertEqual(managerB.barrierActivationCount, 1)
        XCTAssertTrue(targetA.activatedValues.isEmpty)
        XCTAssertTrue(targetB.activatedValues.isEmpty)

        retainedLateCompletion.doNext(with: OutputModel(
            identifier: authID,
            data: CompleteAction(identifier: authID, isDone: true)
        ))

        XCTAssertTrue(managerB.boards.first(where: { $0.identifier == barrierID }) === barrier)
        XCTAssertEqual(managerB.barrierActivationCount, 1)
        XCTAssertTrue(targetA.activatedValues.isEmpty)
        XCTAssertTrue(targetB.activatedValues.isEmpty)

        XCTAssertTrue(managerB.finishBarrier(isDone: true))
        XCTAssertEqual(targetB.activatedValues, ["new-owner"])
        XCTAssertNil(managerB.boards.first(where: { $0.identifier == barrierID }))
        XCTAssertEqual(managerB.removalCounts[barrierID], 1)
        XCTAssertEqual(managerB.duplicateInstallAttempts, 0)
        XCTAssertEqual(managerB.duplicateRemovalAttempts, 0)
    }

    /// `resetFlows()` wipes the barrier's completion flow. `Motherboard` must restore it, otherwise
    /// the gate completes with nobody listening and every pending activation hangs forever.
    func testBarrierRecoversAfterResetFlows() {
        let activation = sutBoard.activation(sampleBarrierAuthID, with: Void.self)
        sutBoard.stubActivationBarrier = activation.barrier()

        sutMotherboard.activateBoard(identifier: sampleBarrierSutID, withOption: sampleInputValue)

        let barrierBoard = sutMotherboard.getBoard(
            identifier: sampleBarrierAuthID.appending("___PRIVATE_BARRIER___")
        ) as? ActivatableBarrierBoard
        XCTAssertEqual(barrierBoard?.pendingTasks.count, 1)
        XCTAssertNil(sutBoard.activatedValue)

        // Drops the barrier's completion flow along with everything else.
        sutMotherboard.resetFlows()

        let expectation = expectation(description: #function)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertTrue(authBoard.activated)
        XCTAssertEqual(
            sutBoard.activatedValue,
            sampleInputValue,
            "Pending activation stayed stuck because the completion flow was never restored"
        )
    }

    /// `barrierIdentifier` must be a stable value, not a fresh UUID on every read.
    func testBarrierIdentifierIsStableAcrossReads() {
        let barrier = ActivationBarrier(
            identifier: .random(),
            scope: .application,
            option: .unidentified("payload")
        )

        XCTAssertEqual(barrier.barrierIdentifier, barrier.barrierIdentifier)
    }

    /// `.application` barriers with `.unidentified` input must not coalesce different activations.
    func testApplicationScopeUnidentifiedBarrierKeepsEachActivationIdentity() {
        let destination: BoardID = .random()

        let first = ActivationBarrier(
            identifier: destination,
            scope: .application,
            option: .unidentified("payload")
        )
        let second = ActivationBarrier(
            identifier: destination,
            scope: .application,
            option: .unidentified("payload")
        )

        XCTAssertNotEqual(first.barrierIdentifier, second.barrierIdentifier)

        let firstBoard = ActivationBarrierFactory.makeBarrierBoard(first)
        let secondBoard = ActivationBarrierFactory.makeBarrierBoard(second)

        XCTAssertFalse(firstBoard === secondBoard)
    }

    func testApplicationScopeUniqueBarrierStillReusesCachedBoard() {
        let destination: BoardID = .random()
        let first = ActivationBarrier(
            identifier: destination,
            scope: .application,
            option: .unique(AnyHashable("payload"))
        )
        let second = ActivationBarrier(
            identifier: destination,
            scope: .application,
            option: .unique(AnyHashable("payload"))
        )

        XCTAssertEqual(first.barrierIdentifier, second.barrierIdentifier)
        XCTAssertTrue(
            ActivationBarrierFactory.makeBarrierBoard(first) ===
                ActivationBarrierFactory.makeBarrierBoard(second)
        )
    }

    func testUnidentifiedBarrierIdentifierIsStablePerActivation() {
        let barrier = ActivationBarrier(
            identifier: .random(),
            scope: .application,
            option: .unidentified("payload")
        )

        XCTAssertEqual(barrier.barrierIdentifier, barrier.barrierIdentifier)
    }

    func testActivationBarrierDone() throws {
        let activation = sutBoard.activation(sampleBarrierAuthID, with: Void.self)
        sutBoard.stubActivationBarrier = activation.barrier()
        sut2Board.stubActivationBarrier = activation.barrier()

        let expectation = expectation(description: #function)

        sutMotherboard.activateBoard(identifier: sampleBarrierSutID, withOption: sampleInputValue)
        sutMotherboard.activateBoard(identifier: sampleBarrierSutID2, withOption: sampleInputValue)

        let barrierBoard = sutMotherboard.getBoard(identifier: sampleBarrierAuthID.appending("___PRIVATE_BARRIER___")) as? ActivatableBarrierBoard
        XCTAssertNotNil(barrierBoard)
        XCTAssertTrue(barrierBoard?.isProcessing == true)
        XCTAssertEqual(barrierBoard?.pendingTasks.count, 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertTrue(authBoard.activated)
        XCTAssertEqual(sutBoard.activatedValue, sampleInputValue)
        XCTAssertEqual(sut2Board.activatedValue, sampleInputValue)
    }

    func testActivationBarrierNotDone() throws {
        let activation = sutBoard.activation(sampleBarrierAuthID, with: Void.self)
        sutBoard.stubActivationBarrier = activation.barrier()
        sut2Board.stubActivationBarrier = activation.barrier()

        authBoard.stubIsDone = false

        let expectation = expectation(description: #function)

        sutMotherboard.activateBoard(identifier: sampleBarrierSutID, withOption: sampleInputValue)
        sutMotherboard.activateBoard(identifier: sampleBarrierSutID2, withOption: sampleInputValue)

        let barrierBoard = sutMotherboard.getBoard(identifier: sampleBarrierAuthID.appending("___PRIVATE_BARRIER___")) as? ActivatableBarrierBoard
        XCTAssertNotNil(barrierBoard)
        XCTAssertTrue(barrierBoard?.isProcessing == true)
        XCTAssertEqual(barrierBoard?.pendingTasks.count, 2)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertTrue(authBoard.activated)
        XCTAssertEqual(sutBoard.activatedValue, nil)
        XCTAssertEqual(sut2Board.activatedValue, nil)
    }
}

let sampleBarrierAuthID: BoardID = "id.board.barrier"
let sampleBarrierSutID: BoardID = "id.board.sut"
let sampleBarrierSutID2: BoardID = "id.board.sut2"
let sampleInputValue = "SAMPLE_INPUT_VALUE"
