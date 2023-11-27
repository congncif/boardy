//
//  BoardFlow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 27/11/2023.
//

import Foundation

public protocol BoardFlow {
    var identifier: String { get }

    func match(with output: BoardOutputModel) -> Bool
    func doNext(with output: BoardOutputModel)
}

public protocol IDMatchBoardFlow: BoardFlow {
    var matchedBoardIDs: [BoardID] { get }
}

public extension IDMatchBoardFlow {
    func match(with output: BoardOutputModel) -> Bool {
        matchedBoardIDs.contains { $0 == output.identifier }
    }
}

public protocol DataMatchBoardFlow: BoardFlow {
    associatedtype Output

    func doNext(withData data: Output)
}

public extension DataMatchBoardFlow {
    func doNext(with output: BoardOutputModel) {
        guard let data = output.data as? Output else {
            guard isSilentData(output.data) else {
                assertionFailure("🔥 [Flow with mismatch data type] [\(output.identifier)]  Cannot convert output of board \(output.identifier) from type \(String(describing: output.data)) to type \(Output.self)")
                return
            }
            return
        }
        doNext(withData: data)
    }
}

public protocol GuaranteedBoardFlow: IDMatchBoardFlow, DataMatchBoardFlow {}

public struct IDGenericBoardFlow<Out>: GuaranteedBoardFlow {
    public typealias Output = Out

    public let identifier: String
    public let matchedBoardIDs: [BoardID]

    private let nextHandler: (Out) -> Void

    public init(identifier: String = UUID().uuidString,
                matchedBoardIDs: [BoardID],
                nextHandler: @escaping (Out) -> Void) {
        self.identifier = identifier
        self.matchedBoardIDs = matchedBoardIDs
        self.nextHandler = nextHandler
    }

    public init(identifier: String = UUID().uuidString,
                matchedBoardIDs: BoardID...,
                nextHandler: @escaping (Out) -> Void) {
        self.init(identifier: identifier, matchedBoardIDs: matchedBoardIDs, nextHandler: nextHandler)
    }

    public init<HandlerTarget>(identifier: String = UUID().uuidString,
                               matchedBoardIDs: [BoardID],
                               target: HandlerTarget,
                               nextHandler: @escaping (HandlerTarget, Out) -> Void) {
        self.identifier = identifier
        self.matchedBoardIDs = matchedBoardIDs

        let box = ObjectBox()
        box.setObject(target)

        self.nextHandler = { [box] data in
            guard let unboxedTarget: HandlerTarget = box.unboxed() else { return }
            nextHandler(unboxedTarget, data)
        }
    }

    public init<BoardType: GuaranteedOutputSendingBoard, HandlerTarget>(
        identifier: String = UUID().uuidString,
        matchedBoardID: BoardID,
        of _: BoardType.Type,
        target: HandlerTarget,
        nextHandler: @escaping (HandlerTarget, BoardType.OutputType) -> Void
    ) where BoardType.OutputType == Output {
        self.init(identifier: identifier, matchedBoardIDs: matchedBoardID, target: target, nextHandler: nextHandler)
    }

    public init<BoardType: GuaranteedOutputSendingBoard>(identifier: String = UUID().uuidString,
                                                         matchedBoardID: BoardID,
                                                         of _: BoardType.Type,
                                                         nextHandler: @escaping (BoardType.OutputType) -> Void) where BoardType.OutputType == Output {
        self.init(identifier: identifier, matchedBoardIDs: matchedBoardID, nextHandler: nextHandler)
    }

    public init<HandlerTarget>(identifier: String = UUID().uuidString,
                               matchedBoardIDs: BoardID...,
                               target: HandlerTarget,
                               nextHandler: @escaping (HandlerTarget, Out) -> Void) {
        self.init(identifier: identifier, matchedBoardIDs: matchedBoardIDs, target: target, nextHandler: nextHandler)
    }

    public func doNext(withData data: Out) {
        nextHandler(data)
    }
}

public struct GenericBoardFlow<Out>: DataMatchBoardFlow {
    public typealias Output = Out

    public var identifier: String

    private let matcher: (BoardOutputModel) -> Bool
    private let nextHandler: (Out) -> Void

    public func match(with output: BoardOutputModel) -> Bool {
        matcher(output)
    }

    public func doNext(withData data: Out) {
        nextHandler(data)
    }

    public init(identifier: String = UUID().uuidString,
                matcher: @escaping (BoardOutputModel) -> Bool = { _ in true },
                nextHandler: @escaping (Out) -> Void) {
        self.identifier = identifier
        self.matcher = matcher
        self.nextHandler = nextHandler
    }

    public init<HandlerTarget>(identifier: String = UUID().uuidString,
                               matcher: @escaping (BoardOutputModel) -> Bool = { _ in true },
                               target: HandlerTarget,
                               nextHandler: @escaping (HandlerTarget, Out) -> Void) {
        self.identifier = identifier
        self.matcher = matcher
        let box = ObjectBox()
        box.setObject(target)

        self.nextHandler = { [box] data in
            guard let unboxedTarget: HandlerTarget = box.unboxed() else { return }
            nextHandler(unboxedTarget, data)
        }
    }
}
