<p align="center">
  <img src="https://i.imgur.com/d6RaK5a.png"/>
</p>

# Boardy

[![Version](https://img.shields.io/cocoapods/v/Boardy.svg?style=flat)](https://cocoapods.org/pods/Boardy)
[![License](https://img.shields.io/cocoapods/l/Boardy.svg?style=flat)](https://cocoapods.org/pods/Boardy)
[![Platform](https://img.shields.io/cocoapods/p/Boardy.svg?style=flat)](https://cocoapods.org/pods/Boardy)

## Why Boardy?

**Microsystems** or **microservices** is an architecture that is particularly effective at developing large, complex, and constantly changing systems in terms of requirements.

In a mobile application development environment, it is difficult to properly implement microsystems due to technological barriers. While microsystems value independence, the components of a mobile application often operate in close cohesion. Or the fact that microsystems interact with each other dynamically and flexibly, the components of the mobile application appreciate the binding and type-safe data. However, microsystems design theories and principles can be applied in a custom way to be able to make mobile applications like microsystems. Suitable for applications with high complexity and expansion requirements.

**Two principles** when building microsystems architecture:

- **Eliminate and optimize** component **dependencies** so that it becomes **isolated**.  This makes it easy to pack a component as a package and **can be shipped anywhere** in the system.

- Use a **unique set of protocols** to communicate with all components in the system.  So a component can **interact with any other component**.  From the outside they are completely similar and **can be interchangeable** without changing core business.

**Boardy** helps to build mobile app microsystems like in a simple way. Inspired by computer motherboards. Boardy builds a system of microsystems based on Boards. Each Board corresponds to a microsystems contained within it is a component of the mobile application, which will perform a specific task. All boards are then integrated together into one motherboard to form complete systems. The components do not interact directly with each other, but through the standard Boardy protocol suite. The core business logic is protected from change and external impact. Just changing how boards can be integrated can create a new business so changes or scaling are made easy, ensuring both maintenance and development requirements at the same time.

<p align="center">
  <img src="https://i.imgur.com/K3P7G3f.jpg"/>
</p>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

+ iOS 10+
+ Xcode 11+
+ Swift 5.1+

## Installation

Boardy is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Boardy'
```

Install subspecs for more features:

```ruby
# Handle deep link using Boardy
pod 'Boardy/DeepLink'
```

```ruby
# Build a complex UI using Boardy
pod 'Boardy/Composable'
```

```ruby
# Utilities toolkit
pod 'Boardy/ComponentKit'
```

## Some useful components in `ComponentKit`

### ❖ **Use `TaskBoard` for a Business-Logic-Only micro-service**

`TaskBoard` is a *Board* which perform a logic task only such as request an `URLSession` then get response, query database, update shared values, etc. These jobs usually doesn't relate UI and could be executed in background. The result after that will be sent out to its `Motherboard` to continue flow.

`TaskBoard`'s initializer requires an `executor block` which performs the task, once the task has done, the executor should full fill the result by calling `completion` statement. By default, `TaskBoard` will `complete()` after all tasks finished and no more tasks activated, this will remove `TaskBoard` from `Motherboard`. Optionally, you can custom `successHandler`, `processingHandler` or `errorHandler` of `TaskBoard` via initializer's parameters.

```swift
enum LatestProductsFetchTaskBoardFactory {
    static func get(identifier: BoardID) -> ActivatableBoard {
        TaskBoard<LatestProductsFetchInput, LatestProductsFetchOutput>(identifier: identifier) { _, input, completion in
            let database = ...

            var query: Query = ...

            switch input {
            case let .limit(value):
                if value > 0 {
                    query = query.limit(to: value.intValue)
                }
            case let .lastUpdated(at: lastDate):
                let timestamp = Timestamp(date: lastDate)
                query = query.whereField(.updatedAt, isGreaterThan: timestamp)
            }

            query.getDocuments { snapshot, error in
                if let err = error {
                    completion(.failure(err))
                } else {
                    let decoder = ...
                    let products = decoder...
                    completion(.success(.done(products)))
                }
            }
        }
        processingHandler: { $0.showDefaultLoading($0.isProcessing) }
        errorHandler: { $0.showErrorAlert($1) }
    }
}

```

> `TaskBoard` could be activated many times and so each activation will perform separated executor so many output values (corresponding to the number of activations) will be sent to its `Motherboard`.

### ❖ **Use `BlockTaskBoard` for individual completable activation**

`BlockTaskBoard` is very similar `TaskBoard`, it's for business logic task only. The difference is:

> `BlockTaskBoard` accepts `BlockTaskParameter` instead of `Input` plain value. `BlockTaskParameter` bundles `input`, `onSuccess` handler, `onProgress` handler, `onError` handler.

By that way, an activation with `BlockTaskBoard` can handle result separating with other activations on same `BlockTaskBoard` corresponding to activation's input.

```swift
enum GetLocalProductBlockTaskBoardFactory {
    static func get(identifier: BoardID) -> ActivatableBoard {
        BlockTaskBoard<GetLocalProductInput, GetLocalProductOutput>(identifier: identifier) { board, input, completion in
            let database ...
            let products = database.getProducts()
            completion(.success(products))
        }
    }
}
```

```swift
func getProducts(by categoryID: String) {
    let parameter = GetLocalProductTaskParameter(input: categoryID)
        .onSuccess(target: self) { target, result in
            target.handle(result)
        }
    mainboard.ioGetLocalProduct().activation.activate(with: parameter)
}
```

### ❖ Use `ResultTaskBoard` for single activation with no side effects

`ResultTaskBoard` is also similar `TaskBoard`. But `ResultTaskBoard` has no side effects for handling progress and errors. All output values will be bundled in `BoardResult` and send to its `Motherboard` for further processing. And the activations on this Board is one by one.

### ❖ Use `FlowBoard` when you would like to create a Board with flow registrations only

When you would like to have a place to combine some Boards into a single business flow, instead of creating a custom Board, you can use `FlowBoard` conveniently. All you need to do is initialize with `registration closure` and `activation closure`.

### ❖ `BarrierBoard`

Sometime you need to wait an activation before performing a specific task. For example, when you press `Add to Cart` button, you need check if user logged in, the product will be added to cart, otherwise you need to navigate your user to `Login` screen before performing the action. That is when you should use `BarrierBoard` to wait user logins to complete flow. The below `AuthUser` Board is an instance of `BarrierBoard`:

```swift
func addToCart(items: [CartItem]) {
    /// Use BlockTaskBoard GetCurrentUser to check if user logged in, otherwise require logging in before adding cart items
    let inlineParameter = GetCurrentUserParameter().onSuccess(target: self) { this, user in
        if let user = user {
            this.performAddingCartItems(items)
        } else {
            /// Use AuthUser barrier to wait logging in before adding cart items, once barrier overcome the action will be performed
            this.motherboard.ioAuthUser().activation.activate(with: .wait { [unowned this] user in
                this.performAddingCartItems(items)
            })

            /// Login required
            this.motherboard.ioAuthenticate().activation.activate()
        }
    }
    /// Check current user with inline parameter
    motherboard.ioCurrentUser().activation.activate(with: inlineParameter)
}
```

```swift
func registerFlows() {
    /// Listen Authenticate flow to mark AuthUser barrier as overcome or cancel
    motherboard.ioAuthenticate().flow.addTarget(motherboard) { mainboard, result in
        switch result {
        case let .authenticated(user):
            mainboard.ioAuthUser().activation.activate(with: .overcome(user))
        case .userClosed:
            mainboard.ioAuthUser().activation.activate(with: .cancel)
        }
    }
}
```
> Use `BarrierBoard` helps you to avoid declaring temporary variable to hold user state, also make micro-services interaction seamless.

## Install template to develop feature

* Clone [module template](https://github.com/congncif/module-template.git) repo
* Run `./install-template.sh`
* Restart **Xcode**


## Add a new feature

Right click in **Xcode** to add *New File...* then choose **`Boardy`** template, enter `name` and press *Next*, choose file location and *Create*.

New feature component will be created, contains a **Board**, an **IOInterface**, a **View Controller or Viewless Controller** with **Builder** pattern.

**Boardy 1.19+** introduces [`IOInterface`](Boardy%20Modularization.md) to communicate between microservices  *(you can generate a custom public `IOInterface` by using above templates)*. This helps microservices ensure consistent `Input` `Output` values, ***type-safe interaction***.

> Note: You need to check and update correct Input & Output Type you would like to use for Your Component in `YourInOut.swift` *(by default the Input Ouput is Optional Any)*.

***☞ If you are using [DadFoundation](https://github.com/ifsolution/father-foundation) & [DadSDK](https://github.com/ifsolution/father-sdk) for module integration***

> `DadFoundation` defines `ModulePlugin`, **ModulePlugin** is place where all of module components will be initialized and it will be integrated into `MainComponent` via `DadSDK`.
>
> `DadSDK` provide the methods to integrate (`install`) all modules into main app and launch them in some contexts.
>
> `DadFoundation` & `DadSDK` are for building plugin architecture of `MainComponent`, help `MainComponent` become clean and easy to scale.

From **Boardy 1.27+**, `DadFoundation` & `DadSDK` become the subspec of `Boardy` - [`ModulePlugin`](Boardy%20Modularization.md#moduleplugin). So you just add below subspec to use them instead of adding external pods.
```ruby
pod "Boardy/ModulePlugin"
```

*You might need to add a `BoardRegistration` for `Your Board` to right place in `Integration/YourModulePlugin.swift`. The place depends on your flow structure. A `Motherboard` manages a business flow, a `continuousBoard` manages a child flow.*

***☞ Otherwise, you need to add registration to BoardProducer to provide YourBoard constructor***

*`BoardProducer` is factory which helps `Motherboard` lazy initialize a child Board on the first activation. This is useful when the `Motherboard` doesn't need initialize all of its Boards at once that might cause some performace issues in case too many children.*

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
    motherboard.installIntoRoot(viewController)
    rootViewController.show(viewController)
        
    eventBus.connect(target: component.controller) { controller, data in
        controller.bindSomething(data)
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

## Reference

* [Microsystems for mobile app](https://congnc-if.medium.com/microsystems-for-mobile-app-c51708299439)
* [Boardy Modularization](Boardy%20Modularization.md)
* [HelloBoardy - A demo for Boardy: Part I+II - Basic, Part III - Boardy Modularization](https://github.com/congncif/hello-boardy/tree/master/Part-III)

## Author

congncif, congnc.if@gmail.com

## License

Boardy is available under the MIT license. See the LICENSE file for more info.
