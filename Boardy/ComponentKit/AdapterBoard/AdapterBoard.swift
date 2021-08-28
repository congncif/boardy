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
        self.inputMapper = mapper
        return self
    }
    
    public func setOutputMapper(_ mapper: @escaping (Destination.OutputType) -> Out) -> Self {
        self.outputMapper = mapper
        return self
    }
    
    public func activate(withGuaranteedInput input: InputType) {
        if let mapper = inputMapper {
            self.destination.activate(withGuaranteedInput: mapper(input))
        } else {
            self.destination.activate(withOption: input)
        }
    }
    
    public func interact(command: Any?) {
        if let destination = self.destination as? InteractableBoard {
            destination.interact(command: command)
        } else {
            assertionFailure("⚠️ [\(identifier)] received an interaction command but it needs to conform \(InteractableBoard.self) to continue process!")
        }
    }
    
    public func board(_ board: IdentifiableBoard, didSendData data: Any?) {
        guard let data = data as? Destination.OutputType else {
            sendToMotherboard(data: data)
            return
        }
        
        if let mapper = outputMapper {
            sendOutput(mapper(data))
        } else {
            sendToMotherboard(data: data)
        }
    }
}

extension AdapterBoard where Destination.InputType == In {
    public convenience init(destination: Destination, outputMapper: @escaping (Destination.OutputType) -> Out) {
        self.init(destination: destination, inputMapper: { $0 }, outputMapper: outputMapper)
    }
}

extension AdapterBoard where Destination.OutputType == Out {
    public convenience init(destination: Destination, inputMapper: @escaping (In) -> Destination.InputType) {
        self.init(destination: destination, inputMapper: inputMapper, outputMapper: { $0 })
    }
}

extension AdapterBoard where Destination.InputType == In, Destination.OutputType == Out {
    public convenience init(destination: Destination) {
        self.init(destination: destination, inputMapper: { $0 }, outputMapper: { $0 })
    }
}
