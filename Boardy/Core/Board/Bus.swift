//
//  Bus.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 1/25/21.
//

import Foundation

/// One subscription on a ``Bus``.
///
/// A cable carries values from the bus to whatever it was created for, and can be invalidated to
/// stop receiving. Use ``Bus/connect(target:handler:)`` rather than building cables by hand — the
/// target variant invalidates itself when its target is released.
open class BusCable<Input> {
    public typealias Handler = (Input) -> Void

    let transportHandler: Handler

    public init(transportHandler: @escaping Handler) {
        self.transportHandler = transportHandler
    }

    open func transport(input: Input) {
        transportHandler(input)
    }

    open private(set) var isValid: Bool = true

    open func invalidate() {
        isValid = false
    }
}

final class ObjectBox {
    private weak var object: AnyObject?
    private var value: Any?

    func setObject(_ object: Any) {
        if type(of: object as Any) is AnyClass {
            self.object = object as AnyObject
        } else {
            value = object
        }
    }

    func makeEmpty() {
        object = nil
        value = nil
    }

    func unboxed<Object>(_: Object.Type = Object.self) -> Object? {
        object as? Object ?? value as? Object
    }

    var isEmpty: Bool {
        object == nil && value == nil
    }
}

public final class TargetBusCable<Target, Input>: BusCable<Input> {
    private let box = ObjectBox()

    public init(target: Target, handler: @escaping (Target, Input) -> Void) {
        box.setObject(target)
        super.init(transportHandler: { [weak box] input in
            guard let destination = box?.unboxed(Target.self) else { return }
            handler(destination, input)
        })
    }

    override public var isValid: Bool {
        !box.isEmpty
    }

    override public func invalidate() {
        box.makeEmpty()
    }
}

/// A typed broadcast channel a board can expose to whoever holds it.
///
/// Flows route between boards; a bus routes *within* one board's world — from the board to the
/// controller it built, or from a controller callback back into the board. It is the piece that
/// keeps a controller from having to know about `Boardy` at all:
///
/// ```swift
/// private let events = Bus<CartEvent>()
///
/// func activate(withGuaranteedInput input: Cart) {
///     let component = builder.build(withDelegate: self)
///     events.connect(target: component.controller) { controller, event in
///         controller.apply(event)
///     }
/// }
/// ```
///
/// Connecting with a target holds that target weakly and drops the cable once it is gone, so a bus
/// does not keep a screen alive.
///
/// - Important: `Bus` performs no synchronization. Connect and transport from one thread — in
///   practice the main thread. Mutating the cable list from a handler while a transport is in
///   flight is undefined behavior, not merely a missed delivery.
public final class Bus<Input> {
    private var cables: [BusCable<Input>] = []

    public init() {}

    func cleanInvalidCablesIfNeeded() {
        cables.removeAll { !$0.isValid }
    }

    /// Adds `cable` to the channel. Invalid cables are pruned first.
    public func connect(_ cable: BusCable<Input>) {
        cleanInvalidCablesIfNeeded()
        cables.append(cable)
    }

    /// Delivers `input` to every valid cable, in connection order.
    ///
    /// A handler may connect to or invalidate cables on this bus. Delivery iterates the set of
    /// cables as it stood when the transport began, so a cable connected from inside a handler
    /// starts receiving from the *next* transport rather than the current one.
    public func transport(input: Input) {
        cleanInvalidCablesIfNeeded()

        // Iterate an explicit snapshot. Reading `cables` already yields a copy today — `Bus` is a
        // class, so the property get hands back a copy-on-write value rather than a long-term
        // borrow — but relying on that leaves the re-entrancy guarantee resting on an
        // implementation detail of property access. Naming the snapshot makes it a decision.
        let snapshot = cables
        snapshot.forEach {
            $0.transport(input: input)
        }
    }
}

public extension Bus {
    func connect<Target>(target: Target, handler: @escaping (Target, Input) -> Void) {
        let cable = TargetBusCable<Target, Input>(target: target, handler: handler)
        connect(cable)
    }

    func connect<Target>(target: Target, handler: @escaping (Target) -> Void) {
        connect(target: target) { target, _ in
            handler(target)
        }
    }

    func deliver(handler: @escaping (Input) -> Void) {
        let cab = BusCable(transportHandler: handler)
        connect(cab)
    }
}

public extension Bus where Input == Void {
    func transport() {
        transport(input: ())
    }
}

public extension Bus where Input == Any? {
    func transport() {
        transport(input: nil)
    }
}

public extension Bus where Input == Any {
    func transport() {
        transport(input: Any?.none as Any)
    }
}
