//
//  BarrierBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/28/21.
//

import Foundation

/// Holds work until a value it is waiting for arrives.
///
/// Callers queue closures with ``Action/wait(_:)``. When the value is known, ``Action/overcome(_:)``
/// runs every queued closure with it, emits the value as output and completes successfully.
/// ``Action/cancel`` drops the queue without running anything and completes unsuccessfully.
///
/// ```swift
/// motherboard.activation(.gate, with: BarrierBoard<Token>.Action.self)
///     .activate(with: .wait { token in openSettings(with: token) })
/// ```
///
/// This is the general-purpose barrier a feature drives explicitly. It is unrelated to the
/// activation barriers the framework installs automatically around gateway boards.
public final class BarrierBoard<Input>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    public typealias InputType = Action
    public typealias OutputType = Input

    public typealias Process = (Input) -> Void

    public enum Action {
        case wait(Process)
        case overcome(OutputType)
        case cancel
    }

    public func activate(withGuaranteedInput input: InputType) {
        switch input {
        case let .wait(process):
            appendProcess(process)
        case .cancel:
            clearProcesses()
            complete(false)
        case let .overcome(value):
            getProcesses().forEach { process in
                process(value)
            }
            sendOutput(value)
            clearProcesses()
            complete(true)
        }
    }

    // MARK: Processes holding

    private var processes: [Process] = []

    private let queue = DispatchQueue(label: "boardy.barrier-board.queue", attributes: .concurrent)

    private func appendProcess(_ process: @escaping Process) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.processes.append(process)
        }
    }

    private func clearProcesses() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.processes.removeAll()
        }
    }

    private func getProcesses() -> [Process] {
        queue.sync { processes }
    }

    public func shouldBypassGatewayBarrier() -> Bool {
        true
    }
}
