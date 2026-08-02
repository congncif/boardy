//
//  Logger.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 5/26/21.
//

import Foundation
#if canImport(UIComposable)
    import UIComposable
#endif

enum DebugLog {
    static func logActivation(icon: String = "🚀 [Activation]", source: IdentifiableBoard, destination: IdentifiableBoard, data: Any?) {
        #if DEBUG
            if Environment.boardyLogEnabled {
                print("\(icon) Boardy Log:")
                print("    🏝 [\(String(describing: type(of: source)))] ➤ \(source.identifier.rawValue)")

                if let motherboard = source.delegate as? IdentifiableBoard {
                    print("    🌏 [\(String(describing: type(of: motherboard)))] ➤ \(motherboard.identifier.rawValue)")
                }

                print("    🎯 [\(String(describing: type(of: destination)))] ➤ \(destination.identifier.rawValue)")
                if let data {
                    print("    🌷 [\(String(describing: type(of: data)))] ➤ \(data)")
                }
            }
        #endif
    }

    static func logActivity(source: IdentifiableBoard, data: Any?) {
        #if DEBUG
            if Environment.boardyLogEnabled {
                var icon = "🍁"
                var destination: BoardID?
                var rawData: Any?

                switch data {
                case let model as BoardInputModel:
                    icon += " [Next To Board]"
                    destination = model.identifier
                    rawData = model.option
                case is BoardFlowAction:
                    icon += " [Broadcast Action]"
                    rawData = data
                case let cmd as BoardCommandModel:
                    icon += " [Send Command]"
                    destination = cmd.identifier
                    rawData = cmd.data
                #if canImport(UIComposable)
                    case let element as UIElementAction:
                        switch element {
                        case let .update(element: elm):
                            icon += " [Update UI Element]"
                            destination = BoardID(elm.identifier)
                        case let .reload(identifier: id):
                            icon += " [Reload UI Element]"
                            destination = BoardID(id)
                        case let .removeContent(identifier: id):
                            icon += " [Remove UI Element content]"
                            destination = BoardID(id)
                        case let .updateConfiguration(identifier: id, configuration: config):
                            icon += " [Remove UI Element content]"
                            destination = BoardID(id)
                            rawData = config
                        @unknown default:
                            break
                        }
                #endif
                default:
                    icon += " [Send Out]"
                    rawData = data
                }

                print("\(icon) Boardy Log:")
                print("    🏝 [\(String(describing: type(of: source)))] ➤ \(source.identifier.rawValue)")

                if let motherboard = source.delegate as? IdentifiableBoard {
                    print("    🌏 [\(String(describing: type(of: motherboard)))] ➤ \(motherboard.identifier.rawValue)")
                }

                if let dest = destination {
                    print("    🎯 [\(String(describing: type(of: dest)))] ➤ \(dest.rawValue)")
                }

                if let logData = rawData {
                    print("    💐 [\(String(describing: type(of: logData)))] ➤ \(logData)")
                }
            }
        #endif
    }

    /// Reports something the framework dropped on purpose but that a caller cannot otherwise see.
    ///
    /// Unlike the flow logs above, this is not gated on `boardyLogEnabled`: a silently discarded
    /// activation is undiagnosable in the field, and someone reading a DEBUG console needs to see
    /// it whether or not they opted into flow tracing.
    static func logWarning(source: IdentifiableBoard, message: String) {
        #if DEBUG
            print("⚠️ [\(String(describing: type(of: source)))] ➤ \(source.identifier.rawValue)")
            print("    \(message)")
        #endif
    }
}
