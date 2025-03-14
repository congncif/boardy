//
//  ModulePlugin.swift
//  DadFoundation
//
//  Created by FOLY on 5/22/21.
//

import Foundation

public extension MainOptions.Key {
    static let environment = MainOptions.Key(rawValue: "environment")
}

public struct MainOptions {
    public struct Key: RawRepresentable, Hashable {
        public typealias RawValue = String

        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

    private var values: [Key: Any]

    public init(_ values: [Key: Any] = [:]) {
        self.values = values
    }

    public static let `default` = MainOptions()

    public subscript<Value>(key: Key) -> Value? {
        self[key] as? Value
    }

    public subscript(key: Key) -> Any? {
        get {
            values[key]
        }

        set {
            values[key] = newValue
        }
    }

    public func set(_ value: Any?, forKey key: Key) -> Self {
        var result = self
        result[key] = value
        return result
    }
}

public protocol MainOption {
    static var defaultValue: Self { get }
    static var key: MainOptions.Key { get }
}

public extension MainOption {
    static var key: MainOptions.Key {
        .init(rawValue: String(describing: Self.self))
    }
}

public extension MainOptions {
    func value<Value: MainOption>(of type: Value.Type = Value.self) -> Value {
        self[type.key] ?? Value.defaultValue
    }

    func with<Value: MainOption>(_ value: Value) -> Self {
        set(value, forKey: Value.key)
    }
}

public protocol SharedValueComponent {
    var options: MainOptions { get }
}

public protocol MainComponent: SharedValueComponent {
    var producer: BoardDynamicProducer { get }
}

public protocol ModulePlugin: ModulePluginConvertible {
    var identifier: BoardID { get }

    func apply(for main: MainComponent)
}

public protocol ModulePluginConvertible {
    var modulePlugins: [ModulePlugin] { get }
}

public extension ModulePlugin {
    var modulePlugins: [ModulePlugin] { [self] }
}

public protocol ModuleBuilderPlugin: ModulePlugin {
    @BoardRegistrationBuilder
    func internalContinuousRegistrations(sharedComponent: any SharedValueComponent, producer: any ActivatableBoardProducer) -> [BoardRegistration]

    func build(with identifier: BoardID, sharedComponent: any SharedValueComponent, internalContinuousProducer: any ActivatableBoardProducer) -> ActivatableBoard

    func pluginDidLoad(with sharedComponent: any SharedValueComponent)
}

public extension ModuleBuilderPlugin {
    func apply(for main: any MainComponent) {
        let mainProducer = main.producer

        let continuousProducer = BoardProducer(externalProducer: mainProducer, registrations: [])
        let registrations = internalContinuousRegistrations(sharedComponent: main, producer: BoardDynamicProducerBox(producer: continuousProducer))
        for registration in registrations {
            continuousProducer.add(registration: registration)
        }

        let pluginBox = ObjectBox()
        pluginBox.setObject(self)

        let componentBox = ObjectBox()
        componentBox.setObject(main)

        mainProducer.registerBoard(identifier) { [pluginBox, componentBox] identifier in
            guard let unboxedTarget = pluginBox.unboxed(Self.self) else {
                preconditionFailure("\(Self.self) BAD ACCESS")
            }
            guard let unboxedComponent = componentBox.unboxed(SharedValueComponent.self) else {
                preconditionFailure("\(SharedValueComponent.self) BAD ACCESS")
            }
            return unboxedTarget.build(with: identifier, sharedComponent: unboxedComponent, internalContinuousProducer: continuousProducer)
        }

        pluginDidLoad(with: main)
    }

    func pluginDidLoad(with _: any SharedValueComponent) {}
}
