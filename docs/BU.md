## Add a new feature

Right click in **Xcode** to add *New File...* then choose **`Boardy`** template, enter `name` and press *Next*, choose file location and *Create*.

New feature component will be created, contains a **Board**, an **IOInterface**, a **View Controller or Viewless Controller** with **Builder** pattern.

**Boardy 1.19+** introduces [`IOInterface`](Boardy%20Modularization.md) to communicate between microservices  *(you can generate a custom public `IOInterface` by using above templates)*. This helps microservices ensure consistent `Input` `Output` values, ***type-safe interaction***.

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
