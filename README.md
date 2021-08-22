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

## Some useful components in Kit

### **Use `TaskBoard` for a Business-Logic-Only micro-service**

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

> `TaskBoard` could be activated many times, by the way, each activation will perform separated executor so many output values (corresponding to the number of activations) will be sent to its `Motherboard`.

### **Use `BlockTaskBoard` for single completable activation**

`BlockTaskBoard` is very similar `TaskBoard`, it's for business logic task only. The difference is:

> `BlockTaskBoard` accepts `BlockTaskParameter` instead of `Input` plain value. `BlockTaskParameter` bundles `input`, `onSuccess` handler, `onProgress` handler, `onError` handler.

By that way, an activation with `BlockTaskBoard` can handle result separating with other other activations on same `BlockTaskBoard` corresponding to activation's input.

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

## Reference

* [Microsystems for mobile app](https://congnc-if.medium.com/microsystems-for-mobile-app-c51708299439)

## Author

congncif, congnc.if@gmail.com

## License

Boardy is available under the MIT license. See the LICENSE file for more info.
