# 🔐 Activation & Gateway Barriers

Boardy supports flexible activation control using **Activation Barriers** and **Gateway Barriers**. These features allow you to enforce preconditions—such as user authentication—before activating a given board.

## 🚧 Activation Barrier

An `ActivatableBoard` can define a barrier board that must complete successfully before it can be activated. This allows you to gate access to a flow, such as requiring authentication before continuing.

The following code will activate `Authentication Board` before activating `SomeBoard`. If `Authentication Board` `complete(true)`, the `SomeBoard` will be activated, otherwise `complete(false)`, `SomeBoard` won't be activated.

```swift
final class SomeBoard: Board, GuaranteedBoard {
    typealias InputType = String


    func activationBarrier(withGuaranteedInput input: String) -> ActivationBarrier? {
        ioAuthenticaion().activation.barrier()
    }

    func activate(withGuaranteedInput input: String) {
        /// activate code here
    }
}
```

If the `AuthenticationBoard` completes with `complete(true)`, then `SomeBoard` will proceed. Otherwise, activation is canceled.

Each barrier is identified by a unique identifier within the Motherboard. The identifier is derived from the `barrierIdentifier` and optional `ActivationBarrierOption`.

### Barrier Scoping

* `.mainboard` (default): The barrier lives on the current Mainboard.
* `.application`: The barrier is shared across the entire app, uniquely identified at the app level.

> ⚠️ The barrier board must call complete(true|false) to resolve the flow. Failing to do so may leave your app in an unresolved state.

### Flow comparison:

* Without Activation Barrier: `OtherBoard ->> SomeBoard`
* With Activation Barrier: `OtherBoard ->> AuthenticationBoard ->> SomeBoard`

## 🛡️ Gateway Barrier

A **Gateway Barrier** applies a global or module-wide rule for pre-activation checks. You can configure them via the `ActivatableBoardProducer`.
Thinking of the **Motherboard** as a **Gateway**, before a Board is activated, the Motherboard can check if any Gateway Barriers are configured. If so, the Board is **only** activated when the Barrier is **completed** - `complete(isDone: true)`.

**Gateway Barriers** and **Activation Barriers** function similarly in that they both set conditions for activating a Board. However, they differ in scope. Activation Barriers are associated with a specific Board, while Gateway Barriers can be applied to an entire app or module through the **ActivatableBoardProducer**.

Register a Gateway Barrier for entire app
Example: Require authentication for most boards except onboarding.

```swift
PluginLauncher.with(options: .default)
    .install(launcherPlugin: ...)
    .install(gatewayBarrier: .registerWithActivation { barrier, _ in
        barrier.motherboard.serviceMap.modAuthentication.ioAuth.activation.activate()
    }.withFlowRegistration { barrier in
        barrier.motherboard.serviceMap.modAuthentication.ioAuth.flow.addTarget(barrier) { target, isAuthenticated in
            target.complete(isAuthenticated)
        }
    })
    .install(gatewayBarrier: .​exempt, for: .pubAuth)
    .install(gatewayBarrier: .​exempt, for: .pubWelcome)
    .initialize()
    .launch(in: window!) { mainboard in
        mainboard.serviceMap
            .modDashboard.ioWelcome
            .activation.activate()
    }
```

This setup ensures all boards must pass the `AuthBoard` unless explicitly `exempted`.

### ⛳ Bypassing Gateway Barriers

You can allow specific boards to bypass the global gateway rule using either:

* .exempt registration (as shown above)
* Board-level opt-out via:

```swift
func shouldBypassGatewayBarrier() -> Bool {
    true
}
```

This is helpful for boards like `AuthBoard` or `WelcomeBoard` that must remain accessible without triggering their own barriers.
