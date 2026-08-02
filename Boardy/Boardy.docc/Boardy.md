# ``Boardy``

Compose an iOS app out of small, replaceable units of flow.

## Overview

Boardy separates *what happens next* from *what a screen does*. A ``Board`` is one step — show a
screen, run a task, make a decision — and it never names the step that follows it. A
``Motherboard`` holds a set of boards and the flows between them, and decides the routing.

That split is the whole idea. A board can be moved, reused or replaced without touching the boards
around it, because none of them refer to each other.

```swift
final class CheckoutBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = Cart
    typealias OutputType = Receipt

    func activate(withGuaranteedInput cart: Cart) {
        let screen = CheckoutViewController(cart: cart)
        screen.onPaid = { [weak self] receipt in self?.sendOutput(receipt) }
        rootViewController.show(screen, sender: nil)
    }
}

let motherboard = Motherboard(boardProducer: producer)
motherboard.registerFlowSteps(.cart ->> .checkout ->> .receipt)
motherboard.putIntoContext(window)
```

Business logic does not belong in a board. Build a controller — MVC, VIP, Clean, whatever the team
uses — and let the board wire it up. The board is glue.

## What to know before writing one

**Boards are meant to be stateless.** A board is produced when its identifier is first activated
and released when it completes. Keeping state across activations means owning the lifecycle
yourself, and it stops the board being safely reusable.

**Everything is addressed by ``BoardID``.** Declare identifiers once as constants; a typo produces
a ``NoBoard`` placeholder rather than a compile error.

**Threading is caller-controlled.** The framework adds no queue hops. Installing boards and
registering flows must happen on the main thread — DEBUG builds assert it — but a board's *output*
may arrive on whatever executor its work finished on, and that is a supported contract, not an
accident.

## Topics

### The two core types

- ``Board``
- ``Motherboard``
- ``BoardID``

### Declaring what a board accepts and emits

- ``GuaranteedBoard``
- ``DedicatedBoard``
- ``GuaranteedOutputSendingBoard``
- ``ActivatableBoard``

### Connecting boards

- ``FlowManageable``
- ``BoardFlow``
- ``Bus``
- ``BusCable``

### Creating boards on demand

- ``BoardProducer``
- ``BoardContainer``
- ``BoardDynamicProducer``
- ``BoardRegistration``
- ``NoBoard``

### Work that is not a screen

- ``TaskBoard``
- ``ResultTaskBoard``
- ``BlockTaskBoard``
- ``BarrierBoard``

### Gating an activation

- ``ActivationBarrier``
- ``GatewayBarrierRegistration``

### Nesting a sub-flow

- ``ModernContinuableBoard``
- ``ContinuableBoard``
- ``ContinuousBoard``

### Assembling an app from modules

- ``PluginLauncher``
- ``LauncherPlugin``
- ``ServiceMap``
