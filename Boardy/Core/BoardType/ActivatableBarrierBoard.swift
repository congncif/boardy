//
//  ActivatableBarrierBoard.swift
//  Boardy
//
//  Created by CONGNC7 on 04/05/2022.
//

import Foundation

typealias BarrierOwningMotherboard = MotherboardType & BoardDelegate & FlowManageable

/// Identity-only carrier used by completion closures that may arrive on different queues.
/// It never owns or transfers the Motherboard: cycle decisions are serialized by
/// `BarrierCycleState`, and callers promote the weak reference to a local strong value
/// before sending lifecycle messages.
final class BarrierOwnerToken: @unchecked Sendable {
    weak var owner: BarrierOwningMotherboard?
    let identity: ObjectIdentifier

    init(owner: BarrierOwningMotherboard) {
        self.owner = owner
        identity = ObjectIdentifier(owner)
    }
}

private enum BarrierCyclePhase {
    case idle
    case active
    case completing
}

private struct BarrierCycleStart {
    let identifier: UInt64
    let ownerToken: BarrierOwnerToken
    let barrierOptionValue: Any?
}

private struct BarrierEnqueueResult {
    let discardedTasks: [BarrierPendingTask]
    let start: BarrierCycleStart?
}

private struct BarrierCompletionTransition {
    let tasks: [BarrierPendingTask]
    let ownerToken: BarrierOwnerToken
}

private struct BarrierFinishResult {
    let discardedTasks: [BarrierPendingTask]
    let start: BarrierCycleStart?
}

private struct BarrierCycleState {
    private(set) var phase: BarrierCyclePhase = .idle
    private(set) var ownerToken: BarrierOwnerToken?
    private(set) var currentTasks: [BarrierPendingTask] = []
    private(set) var nextTasks: [BarrierPendingTask] = []
    private var nextCycleIdentifier: UInt64 = 0
    private var activeCycleIdentifier: UInt64?

    var pendingTasks: [BarrierPendingTask] {
        currentTasks + nextTasks
    }

    var isProcessing: Bool {
        phase != .idle
    }

    mutating func enqueue(_ task: BarrierPendingTask) -> BarrierEnqueueResult {
        switch phase {
        case .idle:
            guard task.ownerToken.owner != nil else {
                return BarrierEnqueueResult(discardedTasks: [task], start: nil)
            }
            return BarrierEnqueueResult(
                discardedTasks: [],
                start: claim([task], ownerToken: task.ownerToken)
            )

        case .active:
            if ownerToken?.owner != nil {
                currentTasks.append(task)
                return BarrierEnqueueResult(discardedTasks: [], start: nil)
            }

            let discarded = currentTasks
            resetToIdle()
            guard task.ownerToken.owner != nil else {
                return BarrierEnqueueResult(
                    discardedTasks: discarded + [task],
                    start: nil
                )
            }
            return BarrierEnqueueResult(
                discardedTasks: discarded,
                start: claim([task], ownerToken: task.ownerToken)
            )

        case .completing:
            nextTasks.append(task)
            return BarrierEnqueueResult(discardedTasks: [], start: nil)
        }
    }

    mutating func beginCompletion(
        from source: BarrierOwnerToken
    ) -> BarrierCompletionTransition? {
        guard
            phase == .active,
            ownerToken === source,
            source.owner != nil
        else {
            return nil
        }

        let tasks = currentTasks
        currentTasks.removeAll(keepingCapacity: true)
        phase = .completing
        activeCycleIdentifier = nil
        return BarrierCompletionTransition(tasks: tasks, ownerToken: source)
    }

    mutating func finishCompletion() -> BarrierFinishResult {
        guard phase == .completing else {
            return BarrierFinishResult(discardedTasks: [], start: nil)
        }

        let queued = nextTasks
        nextTasks.removeAll(keepingCapacity: true)
        ownerToken = nil
        phase = .idle

        let liveTasks = queued.filter { $0.ownerToken.owner != nil }
        let discarded = queued.filter { $0.ownerToken.owner == nil }
        guard let first = liveTasks.first else {
            return BarrierFinishResult(discardedTasks: discarded, start: nil)
        }

        return BarrierFinishResult(
            discardedTasks: discarded,
            start: claim(liveTasks, ownerToken: first.ownerToken)
        )
    }

    func owns(_ start: BarrierCycleStart) -> Bool {
        phase == .active &&
            activeCycleIdentifier == start.identifier &&
            ownerToken === start.ownerToken
    }

    mutating func recoverUnstartedCycle(
        _ start: BarrierCycleStart
    ) -> BarrierFinishResult? {
        guard owns(start) else {
            return nil
        }

        let pending = currentTasks
        resetToIdle()

        let liveTasks = pending.filter {
            $0.ownerToken !== start.ownerToken && $0.ownerToken.owner != nil
        }
        let discarded = pending.filter {
            $0.ownerToken === start.ownerToken || $0.ownerToken.owner == nil
        }
        guard let first = liveTasks.first else {
            return BarrierFinishResult(discardedTasks: discarded, start: nil)
        }

        return BarrierFinishResult(
            discardedTasks: discarded,
            start: claim(liveTasks, ownerToken: first.ownerToken)
        )
    }

    private mutating func claim(
        _ tasks: [BarrierPendingTask],
        ownerToken: BarrierOwnerToken
    ) -> BarrierCycleStart {
        nextCycleIdentifier &+= 1
        activeCycleIdentifier = nextCycleIdentifier
        phase = .active
        self.ownerToken = ownerToken
        currentTasks = tasks
        return BarrierCycleStart(
            identifier: nextCycleIdentifier,
            ownerToken: ownerToken,
            barrierOptionValue: tasks.first?.barrierOptionValue
        )
    }

    private mutating func resetToIdle() {
        phase = .idle
        ownerToken = nil
        currentTasks.removeAll(keepingCapacity: true)
        activeCycleIdentifier = nil
    }
}

private struct BarrierFlowRegistration {
    let token: BarrierOwnerToken
    /// Identifier of the completion flow registered on the owner, when one is currently installed.
    /// Checked against the owner's live flows so that `resetFlows()` does not strand the barrier.
    var flowIdentifier: String?
}

final class ActivatableBarrierBoard: Board, ActivatableBoard {
    let completableIdentifier: BoardID

    private let cycle = Locked(BarrierCycleState())
    private let registrations = Locked<[ObjectIdentifier: BarrierFlowRegistration]>([:])

    init(identifier: BoardID, completableIdentifier: BoardID) {
        self.completableIdentifier = completableIdentifier
        super.init(identifier: identifier)
    }

    var pendingTasks: [BarrierPendingTask] {
        cycle.withLock { $0.pendingTasks }
    }

    var isProcessing: Bool {
        cycle.withLock { $0.isProcessing }
    }

    func ownerToken(for owner: BarrierOwningMotherboard) -> BarrierOwnerToken {
        let identity = ObjectIdentifier(owner)
        return registrations.withLock { registrations in
            registrations = registrations.filter { $0.value.token.owner != nil }
            if let registration = registrations[identity], registration.token.owner != nil {
                return registration.token
            }
            let token = BarrierOwnerToken(owner: owner)
            registrations[identity] = BarrierFlowRegistration(
                token: token,
                flowIdentifier: nil
            )
            return token
        }
    }

    func registerCompletableFlow(to manager: FlowManageable) {
        guard let owner = manager as? BarrierOwningMotherboard else {
            assertionFailure(
                "‼️ The Motherboard \(manager) must conform to MotherboardType, BoardDelegate and FlowManageable for barrier activation"
            )
            return
        }
        let token = ownerToken(for: owner)
        registerCompletableFlow(to: owner, ownerToken: token)
    }

    func registerCompletableFlow(
        to manager: BarrierOwningMotherboard,
        ownerToken token: BarrierOwnerToken
    ) {
        let identity = ObjectIdentifier(manager)
        guard token.identity == identity else { return }

        // Deduplicate against the owner's live flows rather than a one-shot latch: `resetFlows()`
        // drops the flow, and the barrier must be able to register a replacement.
        let liveFlowIdentifiers = Set(manager.flows.map { $0.identifier })
        let flowIdentifier = completionFlowIdentifier

        let shouldRegister = registrations.withLock { registrations -> Bool in
            guard var registration = registrations[identity], registration.token === token else {
                return false
            }
            if let registered = registration.flowIdentifier, liveFlowIdentifiers.contains(registered) {
                return false
            }
            registration.flowIdentifier = flowIdentifier
            registrations[identity] = registration
            return true
        }
        guard shouldRegister else { return }

        let flow = BoardActivateFlow(
            identifier: flowIdentifier,
            matchedIdentifiers: [completableIdentifier]
        ) { [weak self, token] data in
            guard let completionAction = data as? CompleteAction else { return }
            self?.completePendingTasks(from: token, isDone: completionAction.isDone)
        }
        manager.registerFlow(flow)
    }

    /// Stable identifier so a re-registered completion flow can be recognised as the same flow.
    private var completionFlowIdentifier: String {
        "boardy.barrier.completion.\(identifier.rawValue)"
    }

    func activate(withOption option: Any?) {
        guard let task = option as? BarrierPendingTask else { return }

        let result = cycle.withLock { state in
            state.enqueue(task)
        }
        _ = result.discardedTasks
        if let start = result.start {
            perform(start)
        }
    }

    private func completePendingTasks(
        from source: BarrierOwnerToken,
        isDone: Bool
    ) {
        guard let transition = cycle.withLock({ state in
            state.beginCompletion(from: source)
        }) else {
            return
        }

        guard let owner = transition.ownerToken.owner, delegate === owner else {
            if let owner = transition.ownerToken.owner {
                cleanExactInstallations(intendedOwner: owner)
            }
            let recovery = cycle.withLock { state in
                state.finishCompletion()
            }
            _ = recovery.discardedTasks
            if let start = recovery.start {
                perform(start)
            }
            return
        }

        complete()

        if isDone {
            transition.tasks.forEach { task in
                task.activation()
            }
        }

        let result = cycle.withLock { state in
            state.finishCompletion()
        }
        _ = result.discardedTasks
        if let start = result.start {
            perform(start)
        }
    }

    private func perform(_ start: BarrierCycleStart) {
        guard cycle.withLock({ $0.owns(start) }) else { return }
        guard let owner = start.ownerToken.owner else {
            recoverUnstartedCycle(start)
            return
        }

        if let installed = owner.boards.first(where: { $0.identifier == identifier }) {
            guard installed === self else {
                recoverUnstartedCycle(start, intendedOwner: owner)
                return
            }
        } else {
            owner.installBoard(self)
        }

        guard cycle.withLock({ $0.owns(start) }), delegate === owner else {
            recoverUnstartedCycle(start, intendedOwner: owner)
            return
        }

        registerCompletableFlow(to: owner, ownerToken: start.ownerToken)

        guard cycle.withLock({ $0.owns(start) }), delegate === owner else {
            recoverUnstartedCycle(start, intendedOwner: owner)
            return
        }

        nextToBoard(BoardInput<Any?>(
            target: completableIdentifier,
            input: start.barrierOptionValue
        ))
    }

    private func recoverUnstartedCycle(
        _ start: BarrierCycleStart,
        intendedOwner: BarrierOwningMotherboard? = nil
    ) {
        guard let result = cycle.withLock({ state in
            state.recoverUnstartedCycle(start)
        }) else { return }

        if let intendedOwner {
            cleanExactInstallations(intendedOwner: intendedOwner)
        }
        _ = result.discardedTasks
        if let next = result.start {
            perform(next)
        }
    }

    private func cleanExactInstallations(
        intendedOwner: BarrierOwningMotherboard
    ) {
        let currentDelegateOwner = delegate as? BarrierOwningMotherboard
        removeExactInstallation(from: intendedOwner)

        if let currentDelegateOwner,
           ObjectIdentifier(currentDelegateOwner) != ObjectIdentifier(intendedOwner) {
            removeExactInstallation(from: currentDelegateOwner)
        }
        delegate = nil
    }

    private func removeExactInstallation(
        from owner: BarrierOwningMotherboard
    ) {
        let containsSelf = owner.boards.contains { board in
            (board as AnyObject) === self
        }
        guard containsSelf else { return }
        owner.removeBoard(withIdentifier: identifier)
    }
}

enum ActivationBarrierFactory {
    static let cache = SafeDictionary<BoardID, ActivatableBarrierBoard>()

    static func makeBarrierBoard(
        _ barrierActivation: ActivationBarrier,
        identifier: BoardID? = nil
    ) -> ActivatableBarrierBoard {
        let identifier = identifier ?? barrierActivation.barrierIdentifier

        switch barrierActivation.scope {
        case .mainboard:
            return ActivatableBarrierBoard(
                identifier: identifier,
                completableIdentifier: barrierActivation.identifier
            )
        case .application:
            return cache.value(forKey: identifier) {
                ActivatableBarrierBoard(
                    identifier: identifier,
                    completableIdentifier: barrierActivation.identifier
                )
            }
        }
    }
}

struct BarrierPendingTask {
    let activation: () -> Void
    let barrierOptionValue: Any?
    let ownerToken: BarrierOwnerToken
}
