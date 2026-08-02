# Introducing Boardy

## The decision that has no home

Every app answers one question over and over: *what happens after this screen?*

In a small app the answer lives in the view controller and nobody minds. In a large one it becomes
the most expensive code you own, because it is the only code that knows about more than one feature
at a time. It shows up in three shapes, and you have probably shipped all three:

- a view controller that imports the next feature to push it,
- a coordinator that starts as a router and ends up owning half the app's state,
- a module that imports a sibling module because it needs to hand something over.

The symptom is always the same. You cannot move a screen without editing its neighbours, and you
cannot test the path between two screens without booting the UI.

Boardy exists because that decision deserves its own layer.

## Three nouns, five minutes

A **Board** is one step: show a screen, run a task, make a choice. It receives an input, does its
thing, and reports what came out. **A board never names the step that follows it.**

A **Motherboard** holds a set of boards and the flows between them. A **flow** is the rule that says
*when this board emits this, do that*.

That is the whole model. Everything else in the framework is a convenience over it.

```swift
extension BoardID {
    static let cart: BoardID = "cart"
    static let checkout: BoardID = "checkout"
}

final class CartBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = Void
    typealias OutputType = Order

    func activate(withGuaranteedInput _: Void) {
        let screen = CartViewController()
        screen.onCheckout = { [weak self] order in self?.sendOutput(order) }
        rootViewController.show(screen, sender: nil)
    }
}

final class CheckoutBoard: Board, GuaranteedBoard {
    typealias InputType = Order

    func activate(withGuaranteedInput order: Order) {
        rootViewController.show(CheckoutViewController(order: order), sender: nil)
    }
}
```

Neither board mentions the other. The app decides they are connected:

```swift
let producer = BoardProducer()
producer.registerBoard(.cart) { CartBoard(identifier: $0) }
producer.registerBoard(.checkout) { CheckoutBoard(identifier: $0) }

let motherboard = Motherboard(boardProducer: producer)
motherboard.registerFlowSteps(.cart ->> .checkout)
motherboard.putIntoContext(window)

motherboard.activation(.cart, with: Void.self).activate(with: ())
```

Reorder the flow and the boards do not change. Replace `CheckoutBoard` with an A/B variant and its
neighbours do not know. Delete the checkout feature and nothing else fails to compile.

## It has no opinion about your screens

This is the part teams underestimate.

Boardy orchestrates; it does not architect your view layer. A board builds a controller and wires
its callbacks — that is all. The controller keeps the business logic, and it can be MVC, MVVM, VIP,
Clean, or whatever the team already argues about. Boardy never asks.

Two consequences worth the price of adoption:

**You can adopt it one screen at a time.** A board can present a view controller written years ago.
There is no migration, no rewrite, no "Boardy way" of building a screen.

**Flow becomes testable without UI.** A flow is a registration and a handler, so you can drive a
path between features by sending values, with no simulator and no view controller in sight.

## The parts that earn their keep

Each of these exists because a large app needs it, not because the model would be prettier with it:

**Lazy production.** A motherboard with a producer stays empty until something is activated, so a
screen five steps into a flow costs nothing until someone reaches it.

**Module plugins.** A module registers only its own boards. The app assembly is the single place that
knows the full set, which is what lets you add or remove a whole feature without touching another
one.

**Gateway barriers.** "This screen requires sign-in" becomes a declaration attached to the
destination instead of an `if` repeated at every call site that navigates there. The activation is
held, the gate runs, and the queued work proceeds only if it passes.

**Task boards.** The steps that are not screens — fetch, validate, upload — compose exactly like the
ones that are, so a flow does not break in half whenever it touches the network.

## What Boardy is not

Boardy used to describe itself as microservices for mobile. That framing is retired, because it
promised things a single iOS binary cannot deliver: there is no process isolation, no independent
deployment, and no failure boundary between modules. What survives the analogy is the part that was
always the real idea — components that depend on nothing but a shared contract, and are therefore
interchangeable.

Two more limits, stated plainly:

**The transport is `Any?`.** Boardy gives you typed façades at the edges — declared input and output
types, typed flow handlers — and they catch real mistakes at the call site. Underneath, values move
untyped and are cast on arrival. This is not end-to-end static type safety and the library does not
claim it.

**It is iOS and UIKit, iOS 14 or newer.** Not multiplatform, and not a SwiftUI-first framework.

## Where it stands

Version 1.63.0. Every push runs hosted CI: build, the full test suite, podspec lint, and a
public-API check that fails on a removed or renamed declaration.

The lifecycle behavior is the part that was hardened most recently. Completing a board twice is a
no-op rather than a crash; a removed board is detached so a late callback cannot drive the flow
again; barrier registrations and stored destinations no longer outlive their owners. Those were real
defects with regression tests, and they are the reason the framework can now be described as
lifecycle-aware without overstating.

## Start here

- [`README.md`](../README.md) — installation and the API tour
- [`docs/UsageGuide-vi.md`](UsageGuide-vi.md) — usage guide (Vietnamese)
- [`docs/Boardy Modularization.md`](Boardy%20Modularization.md) — splitting an app into modules
- [`docs/Activation Barrier.md`](Activation%20Barrier.md) — gating an activation
- [`docs/ComponentKit.md`](ComponentKit.md) — task boards and the ready-made boards
