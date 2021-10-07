//
//  CombinedFlow.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 10/7/21.
//

import Foundation

public protocol OutputSpecifications {
    var identifier: BoardID { get }

    func validateOutput(_ data: Any?) -> Bool
}

public struct GeneralOutputSpecifications: OutputSpecifications {
    public init(identifier: BoardID, validation: ((Any?) -> Bool)? = nil) {
        self.identifier = identifier
        self.validation = validation ?? { data in !isSilentData(data) }
    }

    public let identifier: BoardID
    public let validation: (Any?) -> Bool

    public func validateOutput(_ data: Any?) -> Bool { validation(data) }
}

public struct GuaranteedOutputSpecifications<Value>: OutputSpecifications {
    public init(identifier: BoardID, valueType: Value.Type) {
        self.identifier = identifier
        self.valueType = valueType
    }

    public let identifier: BoardID
    public let valueType: Value.Type

    public func validateOutput(_ data: Any?) -> Bool {
        data is Value
    }
}

public class OutputCombinedFlow: BoardFlow {
    public let specifications: [OutputSpecifications]

    let handler: ([Any]) -> Void

    private let syncQueue = DispatchQueue(label: "boardy.combined-flow.sync-queue")

    public var matchedIdentifiers: [BoardID] {
        specifications.map { $0.identifier }
    }

    public init(matchedIdentifiers: [BoardID],
                handler: @escaping ([Any]) -> Void) {
        let specs = matchedIdentifiers.map {
            GeneralOutputSpecifications(identifier: $0)
        }
        specifications = specs
        self.handler = handler
    }

    public init(specifications: [OutputSpecifications], handler: @escaping ([Any]) -> Void) {
        self.specifications = specifications
        self.handler = handler
    }

    private var _outputValues: [BoardID: Any] = [:]

    public func match(with output: BoardOutputModel) -> Bool {
        guard matchedIdentifiers.contains(output.identifier) else { return false }
        guard let spec = specifications.first(where: { $0.identifier == output.identifier }) else {
            return true
        }
        return spec.validateOutput(output.data)
    }

    public func doNext(with output: BoardOutputModel) {
        syncQueue.sync {
            let data = filterValidOutputData(output)
            _outputValues[output.identifier] = data

            var isDone = true
            for id in matchedIdentifiers {
                isDone = isDone && _outputValues.keys.contains(id)
            }

            if isDone {
                let result = matchedIdentifiers.compactMap {
                    _outputValues[$0]
                }

                handler(result)

                print(result)
                _outputValues.removeAll() // clear data
            }
        }
    }

    /// Exclude special data from the output
    func filterValidOutputData(_ output: BoardOutputModel) -> Any? {
        output.data
    }
}

public class OutputCombined2Flow<V1, V2>: OutputCombinedFlow {
    public init(spec1: GuaranteedOutputSpecifications<V1>, spec2: GuaranteedOutputSpecifications<V2>, handler: @escaping (V1, V2) -> Void) {
        let convertedHandler: ([Any]) -> Void = { values in
            guard let v1 = values[0] as? V1 else {
                if !isSilentData(values[0]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec1.identifier)\n👉 ➤ \(spec1.valueType)")
                }
                return
            }

            guard let v2 = values[1] as? V2 else {
                if !isSilentData(values[1]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec2.identifier)\n👉 ➤ \(spec2.valueType)")
                }
                return
            }

            handler(v1, v2)
        }

        super.init(specifications: [spec1, spec2], handler: convertedHandler)
    }
}

public class OutputCombined3Flow<V1, V2, V3>: OutputCombinedFlow {
    public init(spec1: GuaranteedOutputSpecifications<V1>,
                spec2: GuaranteedOutputSpecifications<V2>,
                spec3: GuaranteedOutputSpecifications<V3>,
                handler: @escaping (V1, V2, V3) -> Void) {
        let convertedHandler: ([Any]) -> Void = { values in
            guard let v1 = values[0] as? V1 else {
                if !isSilentData(values[0]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec1.identifier)\n👉 ➤ \(spec1.valueType)")
                }
                return
            }

            guard let v2 = values[1] as? V2 else {
                if !isSilentData(values[1]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec2.identifier)\n👉 ➤ \(spec2.valueType)")
                }
                return
            }

            guard let v3 = values[2] as? V3 else {
                if !isSilentData(values[2]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec3.identifier)\n👉 ➤ \(spec3.valueType)")
                }
                return
            }

            handler(v1, v2, v3)
        }

        super.init(specifications: [spec1, spec2, spec3], handler: convertedHandler)
    }
}

public class OutputCombined4Flow<V1, V2, V3, V4>: OutputCombinedFlow {
    public init(spec1: GuaranteedOutputSpecifications<V1>,
                spec2: GuaranteedOutputSpecifications<V2>,
                spec3: GuaranteedOutputSpecifications<V3>,
                spec4: GuaranteedOutputSpecifications<V4>,
                handler: @escaping (V1, V2, V3, V4) -> Void) {
        let convertedHandler: ([Any]) -> Void = { values in
            guard let v1 = values[0] as? V1 else {
                if !isSilentData(values[0]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec1.identifier)\n👉 ➤ \(spec1.valueType)")
                }
                return
            }

            guard let v2 = values[1] as? V2 else {
                if !isSilentData(values[1]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec2.identifier)\n👉 ➤ \(spec2.valueType)")
                }
                return
            }

            guard let v3 = values[2] as? V3 else {
                if !isSilentData(values[2]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec3.identifier)\n👉 ➤ \(spec3.valueType)")
                }
                return
            }

            guard let v4 = values[3] as? V4 else {
                if !isSilentData(values[3]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec4.identifier)\n👉 ➤ \(spec4.valueType)")
                }
                return
            }

            handler(v1, v2, v3, v4)
        }

        super.init(specifications: [spec1, spec2, spec3, spec4], handler: convertedHandler)
    }
}

public class OutputCombined5Flow<V1, V2, V3, V4, V5>: OutputCombinedFlow {
    public init(spec1: GuaranteedOutputSpecifications<V1>,
                spec2: GuaranteedOutputSpecifications<V2>,
                spec3: GuaranteedOutputSpecifications<V3>,
                spec4: GuaranteedOutputSpecifications<V4>,
                spec5: GuaranteedOutputSpecifications<V5>,
                handler: @escaping (V1, V2, V3, V4, V5) -> Void) {
        let convertedHandler: ([Any]) -> Void = { values in
            guard let v1 = values[0] as? V1 else {
                if !isSilentData(values[0]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec1.identifier)\n👉 ➤ \(spec1.valueType)")
                }
                return
            }

            guard let v2 = values[1] as? V2 else {
                if !isSilentData(values[1]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec2.identifier)\n👉 ➤ \(spec2.valueType)")
                }
                return
            }

            guard let v3 = values[2] as? V3 else {
                if !isSilentData(values[2]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec3.identifier)\n👉 ➤ \(spec3.valueType)")
                }
                return
            }

            guard let v4 = values[3] as? V4 else {
                if !isSilentData(values[3]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec4.identifier)\n👉 ➤ \(spec4.valueType)")
                }
                return
            }

            guard let v5 = values[4] as? V5 else {
                if !isSilentData(values[4]) {
                    assertionFailure("🆘 [Flow mismatch data type] \n🚀 ➤ \(spec5.identifier)\n👉 ➤ \(spec5.valueType)")
                }
                return
            }

            handler(v1, v2, v3, v4, v5)
        }

        super.init(specifications: [spec1, spec2, spec3, spec4, spec5], handler: convertedHandler)
    }
}

public extension FlowManageable {
    @discardableResult
    func registerCombinedFlow<O1, O2>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                      _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                      nextHandler: @escaping (O1, O2) -> Void) -> Self {
        let generalFlow = OutputCombined2Flow(spec1: outputSpecifications1, spec2: outputSpecifications2, handler: nextHandler)
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    func registerCombinedFlow<Target, O1, O2>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                              _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                              target: Target,
                                              action: @escaping (Target, O1, O2) -> Void) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        let generalFlow = OutputCombined2Flow(spec1: outputSpecifications1, spec2: outputSpecifications2, handler: { [box] v1, v2 in
            guard let unboxedTarget = box.unboxed(Target.self) else { return }
            action(unboxedTarget, v1, v2)
        })
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    func registerCombinedFlow<O1, O2, O3>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                          _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                          _ outputSpecifications3: GuaranteedOutputSpecifications<O3>,
                                          nextHandler: @escaping (O1, O2, O3) -> Void) -> Self {
        let generalFlow = OutputCombined3Flow(spec1: outputSpecifications1,
                                              spec2: outputSpecifications2,
                                              spec3: outputSpecifications3,
                                              handler: nextHandler)
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    func registerCombinedFlow<Target, O1, O2, O3>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                                  _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                                  _ outputSpecifications3: GuaranteedOutputSpecifications<O3>,
                                                  target: Target,
                                                  action: @escaping (Target, O1, O2, O3) -> Void) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        let generalFlow = OutputCombined3Flow(spec1: outputSpecifications1,
                                              spec2: outputSpecifications2,
                                              spec3: outputSpecifications3,
                                              handler: { [box] v1, v2, v3 in
                                                  guard let unboxedTarget = box.unboxed(Target.self) else { return }
                                                  action(unboxedTarget, v1, v2, v3)
                                              })
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    func registerCombinedFlow<O1, O2, O3, O4>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                              _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                              _ outputSpecifications3: GuaranteedOutputSpecifications<O3>,
                                              _ outputSpecifications4: GuaranteedOutputSpecifications<O4>,
                                              nextHandler: @escaping (O1, O2, O3, O4) -> Void) -> Self {
        let generalFlow = OutputCombined4Flow(spec1: outputSpecifications1,
                                              spec2: outputSpecifications2,
                                              spec3: outputSpecifications3,
                                              spec4: outputSpecifications4,
                                              handler: nextHandler)
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    func registerCombinedFlow<Target, O1, O2, O3, O4>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                                      _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                                      _ outputSpecifications3: GuaranteedOutputSpecifications<O3>,
                                                      _ outputSpecifications4: GuaranteedOutputSpecifications<O4>,
                                                      target: Target,
                                                      action: @escaping (Target, O1, O2, O3, O4) -> Void) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        let generalFlow = OutputCombined4Flow(spec1: outputSpecifications1,
                                              spec2: outputSpecifications2,
                                              spec3: outputSpecifications3,
                                              spec4: outputSpecifications4,
                                              handler: { [box] v1, v2, v3, v4 in
                                                  guard let unboxedTarget = box.unboxed(Target.self) else { return }
                                                  action(unboxedTarget, v1, v2, v3, v4)
                                              })
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    func registerCombinedFlow<O1, O2, O3, O4, O5>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                                  _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                                  _ outputSpecifications3: GuaranteedOutputSpecifications<O3>,
                                                  _ outputSpecifications4: GuaranteedOutputSpecifications<O4>,
                                                  _ outputSpecifications5: GuaranteedOutputSpecifications<O5>,
                                                  nextHandler: @escaping (O1, O2, O3, O4, O5) -> Void) -> Self {
        let generalFlow = OutputCombined5Flow(spec1: outputSpecifications1,
                                              spec2: outputSpecifications2,
                                              spec3: outputSpecifications3,
                                              spec4: outputSpecifications4,
                                              spec5: outputSpecifications5,
                                              handler: nextHandler)
        registerFlow(generalFlow)
        return self
    }

    @discardableResult
    func registerCombinedFlow<Target, O1, O2, O3, O4, O5>(_ outputSpecifications1: GuaranteedOutputSpecifications<O1>,
                                                          _ outputSpecifications2: GuaranteedOutputSpecifications<O2>,
                                                          _ outputSpecifications3: GuaranteedOutputSpecifications<O3>,
                                                          _ outputSpecifications4: GuaranteedOutputSpecifications<O4>,
                                                          _ outputSpecifications5: GuaranteedOutputSpecifications<O5>,
                                                          target: Target,
                                                          action: @escaping (Target, O1, O2, O3, O4, O5) -> Void) -> Self {
        let box = ObjectBox()
        box.setObject(target)

        let generalFlow = OutputCombined5Flow(spec1: outputSpecifications1,
                                              spec2: outputSpecifications2,
                                              spec3: outputSpecifications3,
                                              spec4: outputSpecifications4,
                                              spec5: outputSpecifications5,
                                              handler: { [box] v1, v2, v3, v4, v5 in
                                                  guard let unboxedTarget = box.unboxed(Target.self) else { return }
                                                  action(unboxedTarget, v1, v2, v3, v4, v5)
                                              })
        registerFlow(generalFlow)
        return self
    }
}
