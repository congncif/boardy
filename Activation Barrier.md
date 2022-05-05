# Activation Barrier

The `ActivatableBoard` now can configure another Board as a barrier activation flow. Before the board activates, the Motherboard will check to ensure it passes the barrier successfully.Otherwise the activation will be cancelled.

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