//
//  DedicatedBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 3/18/20.
//

import Foundation

// MARK: - AdaptableBoard

/// Supplies the input type a board is activated with, and how an untyped option converts to it.
///
/// Adopted through ``DedicatedBoard`` or ``GuaranteedBoard`` rather than directly.
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

/// A board with a declared input type that tolerates receiving nothing.
///
/// Use this when "no input" is a real case the board handles — a screen that opens blank as
/// readily as it opens on a record. If the input is required, use ``GuaranteedBoard`` instead: it
/// reports a wrong or missing input rather than quietly passing `nil` through.
///
/// ```swift
/// final class DetailBoard: Board, DedicatedBoard {
///     typealias InputType = Record
///
///     func activate(withInput record: Record?) {
///         show(DetailViewController(record: record))   // nil means "new record"
///     }
/// }
/// ```
///
/// - Warning: do not conform to both `DedicatedBoard` and ``GuaranteedBoard`` on one type. Neither
///   refines the other and both supply `activate(withOption:)` at the same specificity, so the
///   compiler cannot choose — and their intended behavior is opposite.
public protocol DedicatedBoard: AdaptableBoard, ActivatableBoard {
    func activationBarrier(withInput input: InputType?) -> ActivationBarrier?

    func activate(withInput input: InputType?)
}

public extension DedicatedBoard {
    func activate(withOption option: Any?) {
        activate(withInput: convertOptionToInput(option))
    }

    func activationBarrier(withOption option: Any?) -> ActivationBarrier? {
        let input = convertOptionToInput(option)
        return activationBarrier(withInput: input)
    }

    func activationBarrier(withInput _: InputType?) -> ActivationBarrier? {
        nil
    }
}

// MARK: - GuaranteedBoard

/// A board that requires its declared input type.
///
/// This is the usual choice. The framework converts the untyped activation option to `InputType`
/// and reports a mismatch instead of activating with nothing, so a wiring mistake surfaces during
/// development rather than as a blank screen.
///
/// ```swift
/// final class CheckoutBoard: Board, GuaranteedBoard {
///     typealias InputType = Cart
///
///     func activate(withGuaranteedInput cart: Cart) { … }
/// }
/// ```
///
/// - Note: "Guaranteed" is about the *conversion*, not about nullability. Declaring an optional
///   `InputType` such as `String?` still passes `nil` through as a successfully converted value.
///
/// - Warning: do not conform to both ``DedicatedBoard`` and `GuaranteedBoard` on one type; see the
///   warning on `DedicatedBoard`.
public protocol GuaranteedBoard: AdaptableBoard, ActivatableBoard {
    func activationBarrier(withGuaranteedInput input: InputType) -> ActivationBarrier?

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

    func activationBarrier(withOption option: Any?) -> ActivationBarrier? {
        guard let input = convertOptionToInput(option) else {
            return nil
        }
        return activationBarrier(withGuaranteedInput: input)
    }

    func activationBarrier(withGuaranteedInput _: InputType) -> ActivationBarrier? {
        nil
    }
}

public extension GuaranteedBoard where InputType: Decodable {
    var inputAdapters: [(Any?) -> InputType?] {
        [{ input in
            var data: Data?

            if let encodedData = input as? Data {
                data = encodedData
            } else if let any = input, JSONSerialization.isValidJSONObject(any), let jsonData = try? JSONSerialization.data(withJSONObject: any, options: .prettyPrinted) {
                data = jsonData
            }

            guard let rawData = data else { return nil }

            let decoder = JSONDecoder()
            return try? decoder.decode(InputType.self, from: rawData)
        }]
    }
}

// MARK: - The Board sends a type safe Output data

/// Adds a typed ``sendOutput(_:)`` to a board.
///
/// Output is what flows match on, so declaring `OutputType` is what lets a downstream board or
/// flow receive a real type rather than `Any?`.
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
