//
//  DedicatedBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

// MARK: - AdaptableBoard

public protocol AdaptableBoard {
    associatedtype InputType

    var inputAdapters: [(Any?) -> InputType?] { get }
}

public extension AdaptableBoard {
    func convertOptionToInput(_ option: Any?) -> InputType? {
        var input: InputType?
        for adapter in validAdapters {
            input = adapter(option)
            if input != nil { break }
        }
        return input
    }

    var inputAdapters: [(Any?) -> InputType?] { [] }

    internal var validAdapters: [(Any?) -> InputType?] {
        let defaultAdapter: (Any?) -> InputType? = { $0 as? InputType }
        return inputAdapters + [defaultAdapter]
    }
}

// MARK: - DedicatedBoard

public protocol DedicatedBoard: AdaptableBoard, ActivatableBoard {
    func activate(withInput input: InputType?)
}

public extension DedicatedBoard {
    func activate(withOption option: Any?) {
        activate(withInput: convertOptionToInput(option))
    }
}

// MARK: - GuaranteedBoard

public protocol GuaranteedBoard: AdaptableBoard, ActivatableBoard {
    func activate(withGuaranteedInput input: InputType)

    var silentInputWhiteList: [(_ input: Any?) -> Bool] { get }
}

public extension GuaranteedBoard {
    private func isSilent(input: Any?) -> Bool {
        let listCheckers = [isSilentData] + silentInputWhiteList
        for checker in listCheckers {
            if checker(input) { return true }
        }
        return false
    }

    var silentInputWhiteList: [(_ input: Any?) -> Bool] { [] }

    func activate(withOption option: Any?) {
        guard let input = convertOptionToInput(option) else {
            guard isSilent(input: option) else {
                assertionFailure("\(String(describing: self))\n🔥 Cannot convert input from \(String(describing: option)) to type \(InputType.self)")
                return
            }
            return
        }
        activate(withGuaranteedInput: input)
    }
}

public extension GuaranteedBoard where InputType: Decodable {
    var inputAdapters: [(Any?) -> InputType?] {
        [{ input in
            var data: Data?

            if let encodedData = input as? Data {
                data = encodedData
            } else if let jsonData = try? JSONSerialization.data(withJSONObject: input, options: .prettyPrinted) {
                data = jsonData
            }

            guard let rawData = data else { return nil }

            let decoder = JSONDecoder()
            return try? decoder.decode(InputType.self, from: rawData)
        }]
    }
}

// MARK: - The Board sends a type safe Output data

public protocol GuaranteedOutputSendingBoard: IdentifiableBoard {
    associatedtype OutputType
}

public extension GuaranteedOutputSendingBoard {
    func sendOutput(_ data: OutputType) {
        #if DEBUG
        if isSilentData(data) {
            print("\(String(describing: self))\n🔥 Sending a special Data Type might lead unexpected behaviors!\n👉 You should wrap \(data) in custom Output Type.")
        }
        #endif
        sendToMotherboard(data: data)
    }
}

public extension GuaranteedOutputSendingBoard where OutputType: Encodable {
    func sendEncodedOutput(_ data: OutputType) {
        #if DEBUG
        if isSilentData(data) {
            print("\(String(describing: self))\n🔥 Sending a special Data Type might lead unexpected behaviors!\n👉 You should wrap \(data) in custom Output Type.")
        }
        #endif

        let encoder = JSONEncoder()
        do {
            let rawData = try encoder.encode(data)
            sendToMotherboard(data: rawData)
        } catch {
            assertionFailure("‼️ An encoding error \(error) occurred when sending output data\n\(debugDescription)")
        }
    }
}

// MARK: - The Board broadcasts a type safe BoardFlowAction

public protocol GuaranteedActionSendingBoard: IdentifiableBoard {
    associatedtype FlowActionType: BoardFlowAction
}

public extension GuaranteedActionSendingBoard {
    /// Send a Broadcast action with generic type.
    func broadcastAction(_ action: FlowActionType) {
        sendFlowAction(action)
    }
}
