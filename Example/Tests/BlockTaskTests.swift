//
//  BlockTaskTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 8/20/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

private final class BlockTaskEventRecorder {
    private let storage = Locked<[String]>([])

    var values: [String] {
        storage.withLock { $0 }
    }

    func append(_ value: String) {
        storage.withLock { $0.append(value) }
    }
}

/// Upper bound for any wait in this test target, shared across all test files.
///
/// Every wait here is signalled by a controlled executor, an injected completion or a run-loop
/// turn — never by elapsed time. The timeout exists only so a hung test fails instead of blocking
/// the suite forever, so it is deliberately generous: a value tight enough to be exceeded on a
/// loaded CI runner turns a deadlock guard into a flake. Two of these did exactly that and failed
/// a release.
let hangGuardTimeout: TimeInterval = 10

private final class ControlledBlockTaskExecutor {
    typealias Completion = BlockTaskBoard<String, String>.ExecutorCompletion

    private struct Invocation {
        let input: String
        let completion: Completion
    }

    private struct State {
        var invocations: [Invocation] = []
        var cancellationCounts: [String: Int] = [:]
        var startObserver: ((String) -> Void)?
    }

    private let state = Locked(State())

    var executor: BlockTaskBoard<String, String>.Executor {
        { [weak self] _, input, completion in
            guard let self else { return .none }

            let observer = state.withLock { state -> ((String) -> Void)? in
                state.invocations.append(Invocation(input: input, completion: completion))
                return state.startObserver
            }
            observer?(input)

            return .default { [weak self] in
                self?.state.withLock { state in
                    state.cancellationCounts[input, default: 0] += 1
                }
            }
        }
    }

    var startedInputs: [String] {
        state.withLock { $0.invocations.map(\.input) }
    }

    func observeStarts(_ observer: @escaping (String) -> Void) {
        state.withLock { $0.startObserver = observer }
    }

    func cancellationCount(for input: String) -> Int {
        state.withLock { $0.cancellationCounts[input, default: 0] }
    }

    @discardableResult
    func complete(_ input: String, with result: Result<String, Error>) -> Bool {
        guard let completion = state.withLock({ state in
            state.invocations.last { $0.input == input }?.completion
        }) else {
            return false
        }
        completion(result)
        return true
    }
}

private enum BlockTaskTestError: Error {
    case failed
}

final class BlockTaskTests: XCTestCase {
    private let boardID: BoardID = "block-task"
    private var motherboard: Motherboard!

    override func setUpWithError() throws {
        motherboard = Motherboard()
    }

    override func tearDownWithError() throws {
        motherboard = nil
    }

    func testDuplicateCompletionDeliversSuccessAndTerminalSequenceOnce() {
        let executor = ControlledBlockTaskExecutor()
        let events = BlockTaskEventRecorder()
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: executor.executor)
        motherboard.installBoard(board)

        (motherboard as FlowManageable).matchedFlow(boardID, with: String.self).handle { output in
            events.append("output.\(output)")
        }
        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            events.append("board.complete")
        }

        let parameter = BlockTaskParameter<String, String>(input: "input")
            .onSuccess { _, output in events.append("success.\(output)") }
            .onProcessing { _, processing in events.append("processing.\(processing)") }
            .onError { _, _ in events.append("error") }
            .onCompletion { _, status in
                events.append(status == .done ? "completion.done" : "completion.cancelled")
            }

        motherboard.activateBoard(.target(boardID, parameter))
        XCTAssertEqual(events.values, ["processing.true"])

        XCTAssertTrue(executor.complete("input", with: .success("output")))
        XCTAssertEqual(events.values, [
            "processing.true",
            "success.output",
            "output.output",
            "processing.false",
            "completion.done",
            "board.complete",
        ])

        XCTAssertTrue(executor.complete("input", with: .failure(BlockTaskTestError.failed)))
        XCTAssertEqual(events.values, [
            "processing.true",
            "success.output",
            "output.output",
            "processing.false",
            "completion.done",
            "board.complete",
        ])
    }

    func testFailurePreservesErrorProcessingCompletionAndBoardOrder() {
        let executor = ControlledBlockTaskExecutor()
        let events = BlockTaskEventRecorder()
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: executor.executor)
        motherboard.installBoard(board)

        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            events.append("board.complete")
        }

        let parameter = BlockTaskParameter<String, String>(input: "input")
            .onSuccess { _, _ in events.append("success") }
            .onProcessing { _, processing in events.append("processing.\(processing)") }
            .onError { _, _ in events.append("error") }
            .onCompletion { _, status in
                events.append(status == .done ? "completion.done" : "completion.cancelled")
            }

        motherboard.activateBoard(.target(boardID, parameter))
        XCTAssertTrue(executor.complete("input", with: .failure(BlockTaskTestError.failed)))

        let expectedEvents = [
            "processing.true",
            "error",
            "processing.false",
            "completion.done",
            "board.complete",
        ]
        XCTAssertEqual(events.values, expectedEvents)

        XCTAssertTrue(executor.complete("input", with: .success("late")))
        XCTAssertEqual(events.values, expectedEvents)
    }

    func testDirectCancellationInvokesRetainedCancelerAndIgnoresLateCompletion() {
        let executor = ControlledBlockTaskExecutor()
        let events = BlockTaskEventRecorder()
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: executor.executor)
        motherboard.installBoard(board)

        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            events.append("board.complete")
        }

        let parameter = BlockTaskParameter<String, String>(input: "input")
            .onSuccess { _, _ in events.append("success") }
            .onProcessing { _, processing in events.append("processing.\(processing)") }
            .onError { _, _ in events.append("error") }
            .onCompletion { _, status in
                events.append(status == .done ? "completion.done" : "completion.cancelled")
            }

        motherboard.activateBoard(.target(boardID, parameter))
        board.cancelPendingTasksIfNeeded()

        XCTAssertEqual(executor.cancellationCount(for: "input"), 1)
        XCTAssertEqual(events.values, [
            "processing.true",
            "processing.false",
            "completion.cancelled",
        ])

        XCTAssertTrue(executor.complete("input", with: .success("late")))
        XCTAssertEqual(executor.cancellationCount(for: "input"), 1)
        XCTAssertEqual(events.values, [
            "processing.true",
            "processing.false",
            "completion.cancelled",
        ])
    }

    func testLatestCancelsEveryOlderStartedTaskExactlyOnce() {
        let executor = ControlledBlockTaskExecutor()
        let firstStarted = expectation(description: "first started")
        let secondStarted = expectation(description: "second started")
        let thirdStarted = expectation(description: "third started")
        executor.observeStarts { input in
            switch input {
            case "first": firstStarted.fulfill()
            case "second": secondStarted.fulfill()
            case "third": thirdStarted.fulfill()
            default: break
            }
        }

        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .latest, executor: executor.executor)
        motherboard.installBoard(board)
        let statuses = Locked<[String: TaskCompletionStatus]>([:])

        func parameter(_ input: String) -> BlockTaskParameter<String, String> {
            BlockTaskParameter<String, String>(input: input)
                .onCompletion { status in statuses.withLock { $0[input] = status } }
        }

        motherboard.activateBoard(.target(boardID, parameter("first")))
        wait(for: [firstStarted], timeout: hangGuardTimeout)
        motherboard.activateBoard(.target(boardID, parameter("second")))
        wait(for: [secondStarted], timeout: hangGuardTimeout)
        motherboard.activateBoard(.target(boardID, parameter("third")))
        wait(for: [thirdStarted], timeout: hangGuardTimeout)
        XCTAssertTrue(executor.complete("third", with: .success("third")))

        XCTAssertEqual(statuses.withLock { $0["first"] }, .cancelled)
        XCTAssertEqual(statuses.withLock { $0["second"] }, .cancelled)
        XCTAssertEqual(statuses.withLock { $0["third"] }, .done)
        XCTAssertEqual(executor.cancellationCount(for: "first"), 1)
        XCTAssertEqual(executor.cancellationCount(for: "second"), 1)
        XCTAssertEqual(executor.cancellationCount(for: "third"), 0)
    }

    func testQueueStartsNextOnlyAfterCurrentTerminalTransition() {
        let executor = ControlledBlockTaskExecutor()
        let events = BlockTaskEventRecorder()
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .queue, executor: executor.executor)
        motherboard.installBoard(board)

        func parameter(_ input: String) -> BlockTaskParameter<String, String> {
            BlockTaskParameter<String, String>(input: input)
                .onSuccess { _, output in events.append("success.\(input).\(output)") }
                .onCompletion { status in
                    events.append(status == .done ? "completion.\(input).done" : "completion.\(input).cancelled")
                }
        }

        motherboard.activateBoard(.target(boardID, parameter("first")))
        motherboard.activateBoard(.target(boardID, parameter("second")))
        XCTAssertEqual(executor.startedInputs, ["first"])

        XCTAssertTrue(executor.complete("first", with: .success("one")))
        XCTAssertEqual(executor.startedInputs, ["first", "second"])
        XCTAssertEqual(events.values, ["success.first.one", "completion.first.done"])

        XCTAssertTrue(executor.complete("second", with: .success("two")))
        XCTAssertEqual(events.values, [
            "success.first.one",
            "completion.first.done",
            "success.second.two",
            "completion.second.done",
        ])
    }

    func testQueueReentrantActivationDefersBoardCompletionUntilReentrantTaskFinishes() {
        let executor = ControlledBlockTaskExecutor()
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .queue, executor: executor.executor)
        motherboard.installBoard(board)
        let completionCount = Locked(0)
        let statuses = Locked<[String: TaskCompletionStatus]>([:])

        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            completionCount.withLock { $0 += 1 }
        }

        let second = BlockTaskParameter<String, String>(input: "second")
            .onCompletion { status in statuses.withLock { $0["second"] = status } }
        let first = BlockTaskParameter<String, String>(input: "first")
            .onSuccess { [motherboard, boardID] _, _ in
                motherboard?.activateBoard(.target(boardID, second))
            }
            .onCompletion { status in statuses.withLock { $0["first"] = status } }

        motherboard.activateBoard(.target(boardID, first))
        XCTAssertTrue(executor.complete("first", with: .success("first")))

        XCTAssertEqual(executor.startedInputs, ["first", "second"])
        XCTAssertEqual(statuses.withLock { $0["first"] }, .done)
        XCTAssertEqual(completionCount.withLock { $0 }, 0)

        XCTAssertTrue(executor.complete("second", with: .success("second")))
        XCTAssertEqual(statuses.withLock { $0["second"] }, .done)
        XCTAssertEqual(completionCount.withLock { $0 }, 1)
    }

    func testOnlyResultFansResultToPendingHandlersOnceInActivationOrder() {
        let executor = ControlledBlockTaskExecutor()
        let events = BlockTaskEventRecorder()
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .onlyResult, executor: executor.executor)
        motherboard.installBoard(board)

        (motherboard as FlowManageable).matchedFlow(boardID, with: String.self).handle { output in
            events.append("output.\(output)")
        }
        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            events.append("board.complete")
        }

        func parameter(_ input: String) -> BlockTaskParameter<String, String> {
            BlockTaskParameter<String, String>(input: input)
                .onSuccess { _, output in events.append("success.\(input).\(output)") }
                .onProcessing { _, processing in events.append("processing.\(input).\(processing)") }
                .onCompletion { status in
                    events.append(status == .done ? "completion.\(input).done" : "completion.\(input).cancelled")
                }
        }

        motherboard.activateBoard(.target(boardID, parameter("first")))
        motherboard.activateBoard(.target(boardID, parameter("second")))
        XCTAssertEqual(executor.startedInputs, ["first"])

        XCTAssertTrue(executor.complete("first", with: .success("shared")))
        XCTAssertEqual(events.values, [
            "processing.first.true",
            "processing.second.true",
            "success.first.shared",
            "output.shared",
            "processing.first.false",
            "completion.first.done",
            "success.second.shared",
            "output.shared",
            "processing.second.false",
            "completion.second.done",
            "board.complete",
        ])

        XCTAssertTrue(executor.complete("first", with: .failure(BlockTaskTestError.failed)))
        XCTAssertEqual(events.values.count, 11)
    }

    func testConcurrentZeroIsClampedToOneAndDoesNotStall() {
        let executor = ControlledBlockTaskExecutor()
        let firstStarted = expectation(description: "first started")
        let secondStarted = expectation(description: "second started")
        executor.observeStarts { input in
            if input == "first" {
                firstStarted.fulfill()
            } else if input == "second" {
                secondStarted.fulfill()
            }
        }

        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .concurrent(max: 0), executor: executor.executor)
        motherboard.installBoard(board)
        let statuses = Locked<[String: TaskCompletionStatus]>([:])

        func parameter(_ input: String) -> BlockTaskParameter<String, String> {
            BlockTaskParameter<String, String>(input: input)
                .onCompletion { status in statuses.withLock { $0[input] = status } }
        }

        motherboard.activateBoard(.target(boardID, parameter("first")))
        motherboard.activateBoard(.target(boardID, parameter("second")))
        wait(for: [firstStarted], timeout: hangGuardTimeout)
        XCTAssertEqual(executor.startedInputs, ["first"])

        XCTAssertTrue(executor.complete("first", with: .success("first")))
        wait(for: [secondStarted], timeout: hangGuardTimeout)
        XCTAssertEqual(executor.startedInputs, ["first", "second"])
        XCTAssertTrue(executor.complete("second", with: .success("second")))

        XCTAssertEqual(statuses.withLock { $0["first"] }, .done)
        XCTAssertEqual(statuses.withLock { $0["second"] }, .done)
    }

    func testCancellationBeforeDirectCancelerInstallationWinsExactlyOnce() {
        typealias Completion = BlockTaskBoard<String, String>.ExecutorCompletion
        let enteredExecutor = DispatchSemaphore(value: 0)
        let allowCancelerReturn = DispatchSemaphore(value: 0)
        let completionStore = Locked<Completion?>(nil)
        let cancellationCount = Locked(0)
        let activationReturned = expectation(description: "activation returned")
        let events = BlockTaskEventRecorder()

        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: { _, _, completion in
            completionStore.withLock { $0 = completion }
            enteredExecutor.signal()
            _ = allowCancelerReturn.wait(timeout: .now() + hangGuardTimeout)
            return .default { cancellationCount.withLock { $0 += 1 } }
        })
        motherboard.installBoard(board)
        let parameter = BlockTaskParameter<String, String>(input: "input")
            .onProcessing { processing in events.append("processing.\(processing)") }
            .onCompletion { status in
                events.append(status == .done ? "completion.done" : "completion.cancelled")
            }

        DispatchQueue.global().async {
            board.activate(withGuaranteedInput: parameter)
            activationReturned.fulfill()
        }
        XCTAssertEqual(enteredExecutor.wait(timeout: .now() + hangGuardTimeout), .success)

        board.cancelPendingTasksIfNeeded()
        XCTAssertEqual(events.values, ["processing.true", "processing.false", "completion.cancelled"])
        XCTAssertEqual(cancellationCount.withLock { $0 }, 0)

        allowCancelerReturn.signal()
        wait(for: [activationReturned], timeout: hangGuardTimeout)
        XCTAssertEqual(cancellationCount.withLock { $0 }, 1)

        completionStore.withLock { $0 }?(.success("late"))
        XCTAssertEqual(events.values, ["processing.true", "processing.false", "completion.cancelled"])
        XCTAssertEqual(cancellationCount.withLock { $0 }, 1)
    }

    func testCompletionBeforeDirectCancelerInstallationCompletesImmediatelyAndDiscardsCanceler() {
        typealias Completion = BlockTaskBoard<String, String>.ExecutorCompletion
        let executorEntered = DispatchSemaphore(value: 0)
        let allowCancelerReturn = DispatchSemaphore(value: 0)
        let completionStore = Locked<Completion?>(nil)
        let cancellationCount = Locked(0)
        let activationReturned = expectation(description: "activation returned")
        let events = BlockTaskEventRecorder()

        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: { _, _, completion in
            completionStore.withLock { $0 = completion }
            executorEntered.signal()
            _ = allowCancelerReturn.wait(timeout: .now() + hangGuardTimeout)
            return .default { cancellationCount.withLock { $0 += 1 } }
        })
        motherboard.installBoard(board)
        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            events.append("board.complete")
        }
        let parameter = BlockTaskParameter<String, String>(input: "input")
            .onSuccess { _, output in events.append("success.\(output)") }
            .onProcessing { processing in events.append("processing.\(processing)") }
            .onCompletion { status in
                events.append(status == .done ? "completion.done" : "completion.cancelled")
            }

        DispatchQueue.global().async {
            board.activate(withGuaranteedInput: parameter)
            activationReturned.fulfill()
        }
        XCTAssertEqual(executorEntered.wait(timeout: .now() + hangGuardTimeout), .success)

        let completionDelivered = expectation(description: "completion delivered on main")
        DispatchQueue.main.async {
            completionStore.withLock { $0 }?(.success("input"))
            completionDelivered.fulfill()
        }
        wait(for: [completionDelivered], timeout: hangGuardTimeout)

        XCTAssertEqual(events.values, [
            "processing.true",
            "success.input",
            "processing.false",
            "completion.done",
            "board.complete",
        ])
        XCTAssertEqual(cancellationCount.withLock { $0 }, 0)

        allowCancelerReturn.signal()
        wait(for: [activationReturned], timeout: hangGuardTimeout)
        XCTAssertEqual(cancellationCount.withLock { $0 }, 0)
        XCTAssertEqual(events.values.last, "board.complete")
    }

    func testOperationCancellationBeforeCancelerInstallationInvokesCancelerAndFinishesOnce() {
        let enteredExecutor = DispatchSemaphore(value: 0)
        let allowCancelerReturn = DispatchSemaphore(value: 0)
        let cancellationCount = Locked(0)
        let startReturned = expectation(description: "operation start returned")
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: { _, _, _ in
            enteredExecutor.signal()
            _ = allowCancelerReturn.wait(timeout: .now() + hangGuardTimeout)
            return .default { cancellationCount.withLock { $0 += 1 } }
        })
        let operation = BlockTaskExecutionOperation(taskID: "task", input: "input", taskBoard: board)

        DispatchQueue.global().async {
            operation.start()
            startReturned.fulfill()
        }
        XCTAssertEqual(enteredExecutor.wait(timeout: .now() + hangGuardTimeout), .success)

        operation.cancel()
        operation.cancel()
        XCTAssertTrue(operation.isCancelled)
        XCTAssertTrue(operation.isFinished)
        XCTAssertEqual(cancellationCount.withLock { $0 }, 0)

        allowCancelerReturn.signal()
        wait(for: [startReturned], timeout: hangGuardTimeout)
        XCTAssertEqual(cancellationCount.withLock { $0 }, 1)
        XCTAssertTrue(operation.isFinished)
    }

    func testBlockTaskInputAdapterUsesControlledExecutor() {
        let executor = ControlledBlockTaskExecutor()
        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: executor.executor)
        motherboard.installBoard(board)
        let result = Locked<String?>(nil)
        let completionCount = Locked(0)

        (motherboard as FlowManageable).matchedFlow(boardID, with: String.self).handle { value in
            result.withLock { $0 = value }
        }
        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            completionCount.withLock { $0 += 1 }
        }

        (motherboard as MotherboardType)
            .blockActivation(boardID, with: BlockTaskParameter<String, String>.self)
            .activate(with: "input")
        XCTAssertEqual(executor.startedInputs, ["input"])
        XCTAssertTrue(executor.complete("input", with: .success("output")))

        XCTAssertEqual(result.withLock { $0 }, "output")
        XCTAssertEqual(completionCount.withLock { $0 }, 1)
    }

    func testTerminalSequenceStaysOnActivationExecutor() {
        let queue = DispatchQueue(label: "boardy.block-task.executor")
        let key = DispatchSpecificKey<String>()
        queue.setSpecific(key: key, value: "block-task-executor")
        let events = BlockTaskEventRecorder()
        let completionStore = Locked<BlockTaskBoard<String, String>.ExecutorCompletion?>(nil)
        let executorMarker = "block-task-executor"

        func marker() -> String {
            DispatchQueue.getSpecific(key: key) == executorMarker ? executorMarker : "other"
        }

        let board = BlockTaskBoard<String, String>(identifier: boardID, executingType: .default, executor: { _, _, completion in
            events.append("executor.\(marker())")
            completionStore.withLock { $0 = completion }
            return .default {}
        })
        motherboard.installBoard(board)

        (motherboard as FlowManageable).matchedFlow(boardID, with: String.self).handle { output in
            events.append("output.\(output).\(marker())")
        }
        (motherboard as FlowManageable).completionFlow(boardID).handle { _ in
            events.append("board.complete.\(marker())")
        }

        let parameter = BlockTaskParameter<String, String>(input: "input")
            .onSuccess { _, output in events.append("success.\(output).\(marker())") }
            .onProcessing { _, processing in events.append("processing.\(processing).\(marker())") }
            .onCompletion { _, status in
                let value = status == .done ? "done" : "cancelled"
                events.append("completion.\(value).\(marker())")
            }

        queue.sync {
            motherboard.activateBoard(.target(boardID, parameter))
            completionStore.withLock { $0 }?(.success("output"))
        }

        XCTAssertEqual(events.values, [
            "processing.true.block-task-executor",
            "executor.block-task-executor",
            "success.output.block-task-executor",
            "output.output.block-task-executor",
            "processing.false.block-task-executor",
            "completion.done.block-task-executor",
            "board.complete.block-task-executor",
        ])
    }
}
