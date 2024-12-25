# Activation Barrier

The `ActivatableBoard` now can configure another Board as a barrier activation flow. Before the board activates, the Motherboard will check to ensure it passes the barrier successfully. Otherwise the activation will be cancelled.

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

Each `Barrier` is unique by identifier in a `Motherboard`. The identifier of `Barrier` is determined by `barrierIdentifier` (Eg: `Authentication ID`) and `ActivationBarrierOption`. *See more in the source code.*

The `Barrier` lifecycle is controlled by `scope`. The `default` scope is `.inMain`, the Activation Barrier is created and lives on the current Mainboard. With scope `.global`, Activation Barrier is unique by identifier in whole the application.

**Important**: The board in Barrier (eg. `Authentication`) must be a completable board, it must call `complete(true)` hoặc `complete(false)` to finish its job. If don't the barrier cannot be passed and your application will be stuck at that barrier.

***The activation Workflow when activate `SomeBoard` from `OtherBoard`:***

- Without Activation Barrier: **`OtherBoard ->> SomeBoard`**
- With Activation Barrier configuration is **`AuthenticationBoard`: `OtherBoard ->> AuthenticationBoard ->> SomeBoard`**

# Gateway Barrier

Thinking of the **Motherboard** as a **Gateway**, before a Board is activated, the Motherboard can check if any Gateway Barriers are configured. If so, the Board is **only** activated when the Barrier is **completed** - `complete(isDone: true)`.

**Gateway Barriers** and **Activation Barriers** function similarly in that they both set conditions for activating a Board. However, they differ in scope. Activation Barriers are associated with a specific Board, while Gateway Barriers can be applied to an entire app or module through the **ActivatableBoardProducer**.

### Register a Gateway Barrier for entire app

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

Before activating any Board, the app mandates the activation of the **AuthBoard** for authentication.

### Bypass GatewayBarrier

In the above example, the Gateway Barrier is configured for the entire app. This means that all Boards must complete the **Auth** process to be activated. However, there are **exceptions**. The **Welcome Board**, which displays a welcome screen for onboarding users, does not require a login. Additionally, we need to be careful not to create an infinite loop by having the **Auth Board** require itself. To accommodate these exceptions, there are two approaches: 

* Using a special `exempt` Gateway Barrier to bypass the general rule *(like the above example)*
* Enable bypass GatetewayBarrier in **AuthBoard** and **WelcomeBoard**.

```swift
func shouldBypassGatewayBarrier() -> Bool {
    true
}
```
