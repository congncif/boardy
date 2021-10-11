# Component Kit

## Install

```ruby
# Utilities toolkit
pod 'Boardy/ComponentKit'
```

## Some useful components in `ComponentKit`

### ❖ **Use `TaskBoard` for a Business-Logic-Only micro-service**

`TaskBoard` is a *Board* which perform a logic task only such as request an `URLSession` then get response, query database, update shared values, etc. These jobs usually doesn't relate UI and could be executed in background. The result after that will be sent out to its `Motherboard` to continue flow.

`TaskBoard`'s initializer requires an `executor block` which performs the task, once the task has done, the executor should full fill the result by calling `completion` statement. By default, `TaskBoard` will `complete()` after all tasks finished and no more tasks activated, this will remove `TaskBoard` from `Motherboard`. Optionally, you can custom `successHandler`, `processingHandler` or `errorHandler` of `TaskBoard` via initializer's parameters.

> From **Boardy 1.36**, only one task is executed at a time. If have more than one task at a time, please use `BlockTaskBoard` instead.

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