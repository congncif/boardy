//
//  WrapperBoard.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/28/21.
//

import Foundation

public final class AdapterBoard<Destination, In, Out>: Board, GuaranteedBoard, GuaranteedOutputSendingBoard, InteractableBoard, BoardDelegate where Destination: GuaranteedBoard, Destination: GuaranteedOutputSendingBoard {
    public typealias InputType = In
    public typealias OutputType = Out

    public let destination: Destination

    private(set) var inputMapper: ((In) -> Destination.InputType)?
    private(set) var outputMapper: ((Destination.OutputType) -> Out)?

    public init(destination: Destination, inputMapper: @escaping (In) -> Destination.InputType, outputMapper: @escaping (Destination.OutputType) -> Out) {
        self.destination = destination
        self.inputMapper = inputMapper
        self.outputMapper = outputMapper
        super.init(identifier: destination.identifier)
        destination.delegate = self
    }

    public func setInputMapper(_ mapper: @escaping (In) -> Destination.InputType) -> Self {
        inputMapper = mapper
        return self
    }

    public func setOutputMapper(_ mapper: @escaping (Destination.OutputType) -> Out) -> Self {
        outputMapper = mapper
        return self
    }

    public func activationBarrier(withGuaranteedInput input: In) -> ActivationBarrier? {
        if let mapper = inputMapper {
            return destination.activationBarrier(withGuaranteedInput: mapper(input))
        } else {
            return destination.activationBarrier(withOption: input)
        }
    }

    public func activate(withGuaranteedInput input: InputType) {
        if let mapper = inputMapper {
            destination.activate(withGuaranteedInput: mapper(input))
        } else {
            destination.activate(withOption: input)
        }
    }

    public func interact(command: Any?) {
        if let destination = destination as? InteractableBoard {
            destination.interact(command: command)
        } else {
            assertionFailure("⚠️ [\(identifier)] received an interaction command but it needs to conform \(InteractableBoard.self) to continue process!")
        }
    }

    public func board(_: IdentifiableBoard, didSendData data: Any?) {
        guard let rawData = data as? Destination.OutputType else {
            sendToMotherboard(data: data)
            return
        }

        if let mapper = outputMapper {
            sendOutput(mapper(rawData))
        } else {
            sendToMotherboard(data: rawData)
        }
    }

    public func shouldBypassGatewayBarrier() -> Bool {
        true
    }
}

public extension AdapterBoard where Destination.InputType == In {
    convenience init(destination: Destination, outputMapper: @escaping (Destination.OutputType) -> Out) {
        self.init(destination: destination, inputMapper: { $0 }, outputMapper: outputMapper)
    }
}

public extension AdapterBoard where Destination.OutputType == Out {
    convenience init(destination: Destination, inputMapper: @escaping (In) -> Destination.InputType) {
        self.init(destination: destination, inputMapper: inputMapper, outputMapper: { $0 })
    }
}

public extension AdapterBoard where Destination.InputType == In, Destination.OutputType == Out {
    convenience init(destination: Destination) {
        self.init(destination: destination, inputMapper: { $0 }, outputMapper: { $0 })
    }
}
