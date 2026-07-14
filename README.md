<p align="center">
  <img src="https://i.imgur.com/d6RaK5a.png"/>
</p>

# Boardy

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)](https://developer.apple.com/ios/)  
[![Swift](https://img.shields.io/badge/swift-5.9-orange)](https://swift.org)  
[![License](https://img.shields.io/badge/license-MIT-blue)](./LICENSE) 

## Why Boardy?

**Microservices** is an architecture especially effective for building large, complex, and fast-evolving systems.

In mobile application development, implementing true microservices is challenging due to technical limitations. While microservices emphasize independence, mobile app components often work in high cohesion. Furthermore, while microservices favor flexible, dynamic interactions, mobile apps benefit from type-safe, well-defined contracts. However, by adapting key design principles of microservices, we can architect mobile apps with similar scalability and modularity.

### Two principles that guide microservice-inspired design:

- **Minimize and isolate dependencies**: This allows each component to be self-contained and **deployable anywhere** in the system.
- **Unify communication protocols**: All components interact via a common interface, making them **interchangeable** without modifying core business logic.

**Boardy** embraces these ideas to help you build mobile microservice-like systems with ease. Inspired by the design of computer motherboards, Boardy models systems as a collection of **Boards** — each representing a self-contained business unit. Boards communicate only through a consistent protocol layer, and are coordinated by a central **Motherboard**.

This architecture provides:
- Encapsulation of core logic
- Strong type safety
- Plug-and-play extensibility
- Easy reconfiguration and scalability

> [!IMPORTANT]  
> A Board should ideally be stateless. It should not retain context-related state internally. Its lifecycle is automatically managed by its Motherboard, so in most cases you don’t need to worry about its creation or disposal. If you opt to use a Board as a stateful component (not recommended), be sure to call `complete()` when it's no longer needed to release resources.

**Boardy** is a lightweight orchestration framework inspired by microservices architecture, tailored for modular, flow-driven applications in iOS.

## Candidate installation (1.61.0)

Boardy 1.61.0 is currently prepared for maintainer review; it has not been tagged or published yet.
The candidate targets iOS 14+ and Swift 5 language mode on Xcode 26.4.1.

### Swift Package Manager (recommended)

```swift
dependencies: [
    .package(url: "https://github.com/congncif/boardy.git", exact: "1.61.0")
]
```

Import the umbrella module with `import Boardy`. The package includes the Composable surface through
the exact `UIComposableCore` 1.1.0 dependency and does not pull in the legacy DiffUI/Rx products.

### CocoaPods transition

The podspec and Example project are prepared for iOS 14, but CocoaPods publication and CocoaPods
test/lint verification are intentionally deferred in this review cycle. Existing iOS 12/13
consumers should remain on their current release line until they explicitly migrate.

## Execution and type-safety contract

Boardy keeps the existing synchronous, caller-controlled executor. No MainActor annotation,
main-thread precondition or automatic queue hop is introduced in 1.61.0; UIKit callers remain
responsible for main-thread use. `BlockTaskBoard` preserves its legacy terminal executor and
observable callback order. Typed façades improve call-site safety, but the central runtime transport
remains `Any?`; this is not end-to-end static type safety.

See [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md), [`docs/MIGRATING_TO_1.61.md`](docs/MIGRATING_TO_1.61.md),
[`docs/API_STABILITY_1X.md`](docs/API_STABILITY_1X.md), [`RELEASING.md`](RELEASING.md),
[`SECURITY.md`](SECURITY.md) and [`SUPPORT.md`](SUPPORT.md) before adopting the candidate.

---

### 🧩 Core Concepts

- **Board**: A self-contained *microservice-like unit*. It can be activated by calling its `activate` method.
- **Motherboard**: The central *orchestrator* that activates boards and manages their workflow. It supports **Gateway Barriers** to perform pre-checks before activating a board.

Boards and Motherboards can be installed into any **root context** (an `AnyObject`, usually a `UIViewController` or `UIWindow` in UIKit). Once installed, they can access that context for UI presentation or interactions.

---

### ✨ Creating a Board

For example, if you're implementing a payment flow, you can create a `PaymentBoard`.

Use the **Xcode template** to scaffold a new board with minimal effort. Boardy handles dependency wiring and generates useful boilerplate code.

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

> **Note**: `IOInterface` (generated by Boardy templates) enforces type-safe communication. While uncommon in server-side microservices, type safety significantly improves developer experience in mobile apps, where type casting can otherwise become a nightmare.

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
