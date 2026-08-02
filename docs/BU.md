## Add a new feature

Right click in **Xcode** to add *New File...* then choose **`Boardy`** template, enter `name` and press *Next*, choose file location and *Create*.

New feature component will be created, contains a **Board**, an **IOInterface**, a **View Controller or Viewless Controller** with **Builder** pattern.

**Boardy 1.19+** introduces [`IOInterface`](Boardy%20Modularization.md) as the public surface a Business Unit exposes *(you can generate a custom public `IOInterface` by using above templates)*. It pins a module's `Input` and `Output` types in one place so callers get a typed contract instead of guessing at `Any?`.

> Note: You need to check and update correct Input & Output Type you would like to use for Your Component in `YourInOut.swift` *(by default the Input Ouput is Optional Any)*.

From **Boardy 1.27+**, came with [`ModulePlugin`](Boardy%20Modularization.md#moduleplugin). So you just add below subspec:
```ruby
pod "Boardy/ModulePlugin"
```

*You might need to add a `BoardRegistration` for `Your Board` to right place in `Integration/YourModulePlugin.swift`. The place depends on your flow structure. A `Motherboard` manages a business flow, a `continuousBoard` manages a child flow.*

***☞ Otherwise, you need to add registration to BoardProducer to provide YourBoard constructor***

*`BoardProducer` is factory which helps `Motherboard` lazy initialize a child Board on the first activation. This is useful when the `Motherboard` doesn't need initialize all of its Boards at once that might cause some performance issues in case too many children.*

```swift
BoardRegistration(.yourFeature) { identifier in
    YourBoard(identifier: identifier, builder: YourBuilder())
}
```

### **You use the `Board` to communicate with other feature components:**

* To activate `OtherFeature` as child flow, use `activation` in `IOInterface`:
```swift
func openOtherFeature() {
    motherboard.ioOtherFeature().activation.activate()
}
```
* To handle callback from `Other Feature`, register a flow, use `flow` handler in `IOInterface`:
```swift
func registerFlows() {
    motherboard.ioOtherFeature().flow.addTarget(self) { target, output in
        target.handleOutput(output)
    }
}
```
* To send a output data to `Motherboard`, use `sendOutput` method:
```swift
func yourFeatureDidComplete() {
    self.sendOutput("Output data")
}
```
* To interact with *Internal Controller*, use **Event Bus**:
```swift
...
// Declare bus with data type String for example
private let eventBus = Bus<String>()
...

// Bind the bus to Controller to get data
func activate(withGuaranteedInput input: InputType) {
    let component = builder.build(withDelegate: self)
    let viewController = component.userInterface
    motherboard.putIntoContext(viewController)
    rootViewController.show(viewController)
        
    eventBus.connect(target: component.controller) { controller, data in
        controller.updateSomething(data)
    }
}

// Transport data to bus, for example from OtherFeature callback
func registerFlows() {
    motherboard.ioOtherFeature().flow.bind(to: eventBus)
}

// Or send a custom event
func sendCustomEvent(value: String) {
    eventBus.transport(value)
}
```

## Choosing a board producer

Two producers implement `BoardDynamicProducer`, and they are not interchangeable. Pick by what you
need, not by which name you saw first.

| | `BoardProducer` | `BoardContainer` |
|---|---|---|
| Duplicate `registerBoard` | keeps the **first** factory | keeps the **last** factory |
| Register many identifiers at once | — | `registerBoards(_:factory:)` |
| Inspect what is registered | `registrations`, `gatewayRegistrations` | not exposed |
| Duplicate `registerGatewayBoard` | keeps the first | keeps the first |

The opposite defaults for boards are historical and are preserved for compatibility. Note that
`BoardContainer` disagrees with *itself*: its gateway path keeps the first registration while its
board path replaces.

When a duplicate registration is deliberate — swapping an A/B variant, overriding a module default
in a test — do not rely on either default:

```swift
producer.registerBoard(.checkout, replacingExisting: true) { id in
    CheckoutBoardVariantB(identifier: id)
}
```

Both producers honour that call identically. DEBUG builds log whenever a plain `registerBoard`
overwrites or discards an existing registration, so an accidental collision is visible rather than
silent.
