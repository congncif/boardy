<p align="center">
  <img src="https://i.imgur.com/d6RaK5a.png"/>
</p>

# Boardy

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)](https://developer.apple.com/ios/)  
[![Swift](https://img.shields.io/badge/swift-5.9-orange)](https://swift.org)  
[![License](https://img.shields.io/badge/license-MIT-blue)](./LICENSE) 

**A lifecycle-aware orchestration layer for modular iOS apps. Your screens keep their own architecture.**

## Why Boardy?

Every app answers one question over and over: *what happens after this screen?* In a large app that
becomes the most expensive code you own, because it is the only code that knows about more than one
feature at a time — a view controller importing the next feature, a coordinator that grew into a
state container, a module importing its sibling to hand something over.

Boardy gives that decision its own layer. A **Board** is one step — show a screen, run a task, make a
choice — and **it never names the step that follows it**. A **Motherboard** holds a set of boards and
the flows between them; a **flow** is the rule that says *when this board emits this, do that*.

That is the whole mental model, and it is deliberately small enough to explain in five minutes.

What it buys you:

- **Reordering a flow does not touch a board.** Replace a screen with a variant, or delete a feature,
  without its neighbours failing to compile.
- **Your view architecture is untouched.** A board builds a controller and wires its callbacks; the
  controller keeps the business logic and can be MVC, MVVM, VIP or Clean. Boardy never asks. Adoption
  is screen by screen, with no rewrite.
- **Flow becomes testable without UI.** A flow is a registration and a handler, so a path between
  features can be driven by sending values — no simulator, no view controller.
- **Features assemble instead of coupling.** A module registers only its own boards; the app assembly
  is the single place that knows the full set.

Boardy no longer describes itself as microservices for mobile. That framing promised things a single
iOS binary cannot deliver — process isolation, independent deployment, failure boundaries between
modules. What survives it is the part that was always the real idea: components that depend on
nothing but a shared contract, and are therefore interchangeable.

> 📖 **[Introducing Boardy](docs/Introducing%20Boardy.md)**
>
> Reorder a flow and no board changes. Swap a screen for an A/B variant and its neighbours never
> learn about it. Delete a feature and nothing else fails to compile. That holds because a board
> receives an input, reports what came out, and **never names the step that follows it** — and it
> costs you nothing architecturally, because Boardy has no opinion about how your screens are built.
>
> The longer version has a two-board example you can paste, the parts that earn their keep in a large
> app, and an honest list of what the library does not do.

> [!IMPORTANT]
> A Board should ideally be stateless. It should not retain context-related state internally. Its lifecycle is automatically managed by its Motherboard, so in most cases you don’t need to worry about its creation or disposal. If you opt to use a Board as a stateful component (not recommended), be sure to call `complete()` when it's no longer needed to release resources.

## Installation

Boardy 1.63.1 targets iOS 14+ and Swift 5 language mode.

### Swift Package Manager (recommended)

```swift
dependencies: [
    .package(url: "https://github.com/congncif/boardy.git", from: "1.63.1")
]
```

Import the umbrella module with `import Boardy`. The package includes the Composable surface through
the exact `UIComposableCore` 1.1.0 dependency and does not pull in the legacy DiffUI/Rx products.

### CocoaPods

```ruby
pod 'Boardy'
```

The trunk serves 1.63.0. 1.63.1 is a Git tag only; it changes no code a pod consumer runs, so
there is nothing on the trunk to wait for. Note that 1.62.0 was never published there either, so a
pod consumer moves from 1.61.0 straight to 1.63.0 — the changelog for both applies.

A dependency without a version bound inherits whatever floor the resolved version carries; 1.61.0
raised it from iOS 12 to iOS 14. An app that must stay below iOS 14 pins `~> 1.60`. See
[`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md).

## Execution and type-safety contract

Boardy keeps a synchronous, caller-controlled executor. No MainActor annotation, release main-thread
precondition or automatic queue hop is introduced; UIKit callers remain responsible for main-thread
use. DEBUG builds assert that Motherboard storage mutations happen on the main thread. Board *output*
carries no such restriction — it arrives on whichever executor the work finished on, and
`BlockTaskBoard` preserves its legacy terminal executor and observable callback order.

Typed façades improve call-site safety, but the central runtime transport remains `Any?`; this is not
end-to-end static type safety.

See [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md), [`docs/MIGRATING_TO_1.61.md`](docs/MIGRATING_TO_1.61.md),
[`docs/API_STABILITY_1X.md`](docs/API_STABILITY_1X.md), [`RELEASING.md`](RELEASING.md),
[`SECURITY.md`](SECURITY.md) and [`SUPPORT.md`](SUPPORT.md) for the full contract.

---

### 🧩 Core Concepts

- **Board**: One self-contained step in a flow. It is activated by calling its `activate` method, and it never names the step that follows it.
- **Motherboard**: The central *orchestrator* that activates boards and manages their workflow. It supports **Gateway Barriers** to perform pre-checks before activating a board.

Boards and Motherboards can be installed into any **root context** (an `AnyObject`, usually a `UIViewController` or `UIWindow` in UIKit). Once installed, they can access that context for UI presentation or interactions.

---

### ✨ Creating a Board

For example, if you're implementing a payment flow, you can create a `PaymentBoard`.

#### Install the Xcode template first

Most snippets in this README use symbols the template generates — `ioPayment()`, `.pubShoppingCart`,
`serviceMap.modDashboard`, `builder`. They are real, but they come from *your* module rather than
from `Boardy`, so pasting them into a project without the template will not compile.

```bash
sh tools/install-template.sh          # Xcode templates, pinned revision
sh tools/init-module.sh YourModule    # scaffold a new module
```

Both scripts clone a pinned revision of [`module-template`](https://github.com/congncif/module-template)
and [`module-structure-template`](https://github.com/ifsolution/module-structure-template). The
template scaffolds a board, wires its dependencies, and generates the `IOInterface` described below.

Boardy works without the template — everything it emits is ordinary code over the public API. The
template exists so you do not write that code by hand for every module.

A board encapsulates a self-contained business unit. It defines:
- **Input**: data required for activation.
- **Output**: messages/events sent to the outside world, forwarded via the Motherboard (acting as a message broker).

Here’s an overview of a simple `PaymentBoard`:

```swift
final class PaymentBoard: ModernContinuableBoard, GuaranteedBoard, GuaranteedOutputSendingBoard, GuaranteedActionSendingBoard, GuaranteedCommandBoard {
    typealias InputType = PaymentInput
    typealias OutputType = PaymentOutput
    typealias FlowActionType = PaymentAction
    typealias CommandType = PaymentCommand

    func activate(withGuaranteedInput input: InputType) {
        let component = builder.build(withDelegate: self, input: input)
        let viewController = component.userInterface
        
        motherboard.putIntoContext(viewController)

        rootViewController.show(viewController)        
    }
}
```

This board can display a `PaymentConfirm` form to the user. Once the transaction is processed, it emits a result:

```swift
enum PaymentOutput {
    case success(transactionID: String)
    case failure(error: Error)
    case userCancelled
}
```

The Motherboard can listen and chain further boards:

```swift
motherboard.ioPayment().flow.addTarget(motherboard) { target, output in
    switch output {
    case let .success(transactionID: id):
        target.ioTransactionDetails().activation.activate(with: id)
    case ...
    }
}
```

> **Note on type safety**: values travel between boards as `Any?` and are cast on arrival, so this is
> not end-to-end static type safety. What matters is where the risk actually lives — not in the cast,
> but in two hand-written ends drifting apart, one sending a type the other stopped expecting.
>
> `IOInterface` closes that. A module declares its `Input`, `Output`, `Command` and `Action` once, and
> the template generates the identifier constant, the destination typealias binding all four types,
> and the `ioXxx()` accessor from that one declaration. Both ends come from the same source, so they
> cannot disagree, and the call site is checked by the compiler:
>
> ```swift
> motherboard.ioLogin().activation.activate(with: LoginInput(username: name))
> ```
>
> The cast still happens underneath. Nobody chose the type twice, which is what made it dangerous.

---

### 🔍 Inside a Board

A **Board** serves as the glue between business flows in the system. It is stateless by design, delegating all logic to **Controllers** via **Event Buses** and **Delegate protocols**.

- Controllers can be built with any architecture (MVC, VIP, Clean Architecture).
- Since boards are composable, controllers should be lightweight.
- Clean or Hexagonal Architecture is recommended for clarity and maintainability.
- The Xcode template supports:
  - **MVC**
  - **VIP** (a simplified Clean Architecture with unidirectional data flow)
  - **SwiftUI Full UI Board** templates for UIKit-SwiftUI integration

When a Controller finishes its job, it sends events to the Board via delegate:

```swift
protocol PaymentControlDelegate: AnyObject {
    func paymentDidSuccess(transactionID: String)
    func paymentDidFail(error: Error)
    func paymentDidCancel()
}

extension PaymentBoard: PaymentDelegate {
    func paymentDidSuccess(transactionID: String) {
        sendOutput(.success(transactionID: transactionID))
    }

    func paymentDidFail(error: Error) {
        sendOutput(.failure(error: error))
    }

    func paymentDidCancel() {
        sendOutput(.userCancelled)
    }
}
```

A Board can also receive **commands** from external sources using `EventBus`:

```swift
private let outsideDataBus = Bus<String>()

func activate(withGuaranteedInput input: InputType) {
    ...
    outsideDataBus.connect(target: controller) { target, data in
        target.updateWithOutsideData(data)
    }
}

func interact(guaranteedCommand: CommandType) {
    outsideDataBus.transport(input: guaranteedCommand.data)
}
```

---

### 🧠 Motherboard: The Flow Manager

Think of **Motherboard** as the manager of all child Boards:
- Decides which board to activate or remove.
- Chains board flows for complex tasks (e.g. `ShoppingCart → Ordering → Payment`).
- Acts as a **Flow Manager** for your app:

```swift
motherboard.registerFlowSteps(.pubShoppingCart ->> .pubOrdering ->> .pubPayment)
```

---

### ♻️ ContinuousBoard: Workflow Encapsulation

A **ContinuousBoard** wraps an internal Motherboard to manage sub-flows. It behaves like a micro-orchestrator and can be installed into the Mainboard as a single board.

In the example below, `PaymentBoard` is a ContinuousBoard composed of:
- `PaymentConfirmBoard`
- `VouchersPickerBoard`
- `PaymentVerificationBoard`
- `PaymentProcessBoard`

From the Mainboard, activating `PaymentBoard` starts the entire payment flow:

```swift
mainboard.ioPayment().activation.activate()
```

---

### 🔧 Registration & Initialization

#### ✅ Static Registration

```swift
let motherboard = Motherboard(boards: [shoppingCartBoard, orderingBoard, paymentBoard])
```

#### 🔄 Dynamic Registration with BoardProducer

```swift
let motherboard = Motherboard(boardProducer: BoardProducer(registrationsBuilder: { producer in
    BoardRegistration(.modShoppingCart) { identifier in
        ShoppingCartBoard(identifier: identifier, boardProducer: producer)
    }

    BoardRegistration(.modOrdering) { identifier in
        OrderingBoard(identifier: identifier, boardProducer: producer)
    }

    BoardRegistration(.modPayment) { identifier in
        PaymentBoard(identifier: identifier, boardProducer: producer)
    }
}))
```

---

### 🧱 Builder Pattern

The **Builder Pattern** is used to construct controllers with dependencies for **Full UI Boards**. This is highly encouraged when initializing complex modules.

---

### 📦 Modularization with Plugins

Boardy encourages modular app design. Each module (e.g. *Authentication*, *Shopping*, *Payment*) can be bundled as a **Plugin**, registering all its boards internally.

Use a **PluginLauncher** to install plugins and initialize the app:

```swift
PluginLauncher.with(options: .default)
    .install(launcherPlugin: AuthenticationLauncherPlugin())
    .install(launcherPlugin: DashboardLauncherPlugin())
    .install(launcherPlugin: ProductManagementLauncherPlugin())
    .install(launcherPlugin: ShoppingLauncherPlugin())
    .install(launcherPlugin: PaymentLauncherPlugin())
    .initialize()
    .launch(in: window!) { motherboard in
        motherboard.serviceMap.modDashboard.ioDashboard.activation.activate()
    }
```

> Adding new features? Just drop in another plugin — it's designed for maximum **extensibility**.

---

## Author

congncif, congnc.if@gmail.com

### 📃 License

Boardy is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
