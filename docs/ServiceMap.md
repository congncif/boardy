# Service Map

One of the difficulties of microservices systems is the ability to visualize the components.

The code below describes calls to public boards

```swift
// Activate a order details board from module ShoppingOrder
func openOrderDetails() {
    mainboard.ioOrderDetails().activation.activate(with: orderID)
}

// Activate shopping cart board from module ShoppingCart
func openShoppingCart() {
    mainboard.ioCart().activation.activate()
}
```
* One of Maintainer's problems is that if you just look at the code above, you cannot imagine **where public boards** like `OrderDetails` and `Cart` are located, and **which module** they are under the management of.
* **Code completion** also does not work effectively when the public board activate func is easily *confused with functions of other internal and public boards*

<p align="center">
  <img src="https://i.imgur.com/FFOKyzW.png"/>
</p>

**Boardy 1.54** introduces **ServiceMap** to help visualize public boards calling.

```swift
func openQuestionsServices() {
    mainboard.serviceMap
        .modQuestionsServices.default
        .activation.activate()
}
```
The code above describes calls to `QuestionsServices` default board via `serviceMap` of `Motherboard`, the board is under module `QuestionsServices`. 

This is very clear and transparent. It makes it easy for maintainers to find and change code if needed.

## Installation

* To use **ServiceMap**, you need to update **Boardy** to version `1.54` or later.

* Install the the latest [module-template](https://github.com/congncif/module-template) which is compatible with Boardy `1.54` or later.

## Setting up
* Create **ServiceMap** for a module via **Xcode template**
<p align="center">
  <img src="https://i.imgur.com/nVr59Pe.png"/>
</p>

*The result is similar the following code*
```swift
public final class QuestionsServicesServiceMap: ServiceMap {}

public extension ServiceMap {
    var modQuestionsServices: QuestionsServicesServiceMap { link() }
}
```

* Create an extension of module **ServiceMap** for a public board, check on option **Use ServiceMap** of **Public Board** in the **IO Interface**.

<p align="center">
  <img src="https://i.imgur.com/bnnpaCU.png"/>
</p>

*The result is similar the following code*

```swift
public extension QuestionsServicesServiceMap {
    var ioProductList: ProductListMainDestination {
        mainboard.ioProductList()
    }
}
```

## Usage

Use **ServiceMap** to call `ioProductList()`
```swift
func openProductList() {
    mainboard.serviceMap
        .modQuestionsServices.ioProductList
        .activation.activate()
}
```