# Boardy

## Triển khai Microsystems những điểm cần chú ý

### Khi nào cần tạo Board?
Khi cần đóng gói một business logic (Component) như một microsytem (Board). 

### Kiến trúc của Component

Trong hệ thống Microservices (Microsystems), các Component có nhiệm vụ thực hiện tác vụ mà nó đảm nhiệm và uỷ thác các tín hiệu tương tác ra bên ngoài (Board). Do đó, nó có thể được xây dựng bằng bất kỳ kiến trúc nào (chỉ cần đảm bảo business logic được thực thi). Nó có thể có cấu trúc layer phức tạp (VIPER, RIBs, VIP, ..), có thể đơn giản (MVVM, MVP, MVC,...) hoặc cũng có thể chỉ đơn giản là một class hoặc thậm chí chỉ là một function.

### Vòng đời của Board & Component

***Vòng đời của một Board gắn liền với Motherboard của nó hoặc cho đến khi phương thức `complete()` được gọi.***

Hệ thống các Board có nhiệm vụ cấu trúc bộ khung cho các microsystems, tương tác giứa các system với nhau, nó không nên bao gồm nhiệm vụ quản lý lifecycle của các component mà nó sản xuất ra.

Vì vậy, để quản lý tốt lifecycle của các component, chúng ta vẫn dựa vào OS platform, mặc định là dựa trên lifecycle của UIKit components. Trong trường hợp Component không có cơ chế quản lý lifecycle (component chỉ là một class/ function):
- Nếu không cần quản lý (component không trực tiếp chiếm dữ liệu cần giải phóng vd như công cụ kiểm tra, điều hướng logic, background job, ...) nó có thể gắn trực tiếp vào Board mà không cần lo lắng.

```swift
final class RootBoard: ContinuousBoard, GuaranteedBoard {
    typealias InputType = [UIApplication.LaunchOptionsKey: Any]?

    private let builder: AuthCheckingBuilder
    
    private lazy var authChecker: AuthChecking = {
        builder.build()
    }()

    init(identifier: BoardID, authCheckingBuilder: AuthCheckingBuilder) {
        self.builder = authCheckingBuilder
        super.init(identifier: identifier)
    }

    func activate(withGuaranteedInput input: InputType) {
        if authChecker.checkUserAuthenticated() {
            motherboard.activateBoard(.dashboard)
        } else {
            motherboard.activateBoard(.login)
        }
    }
}
```

- Nếu cần quản lý (component chứa dữ liệu và reference) cần xây dựng cơ chế huỷ / giải phóng component sau khi thực hiện xong tác vụ.
```swift
final class RootBoard: ContinuousBoard, GuaranteedBoard {
    typealias InputType = [UIApplication.LaunchOptionsKey: Any]?

    private let builder: FeatureBuilder
    
    private var featureInstance: FeatureController?

    init(identifier: BoardID, builder: FeatureBuilder) {
        self.builder = builder
        super.init(identifier: identifier)
    }

    func activate(withGuaranteedInput input: InputType) {
        let feature = builder.build(withDelegate: self)
        feature.start(input)

        featureInstance = feature // store reference only
    }
}

extension RootBoard: FeatureDelegate {
    func featureDidFinish() {
        featureInstance = nil
    }
}
```

hoặc pair với một object nào đó có lifecycle (nếu tương thích).

```swift
final class SomeBoard: Board, GuaranteedBoard {
    private let builder: FeatureBuilder

    init(identifier: BoardID, builder: FeatureBuilder) {
        self.builder = builder
        super.init(identifier: identifier)
    }

    func activate(withGuaranteedInput input: InputType) {
        let feature = builder.build(withDelegate: self)
        feature.pairWith(object: rootViewController)
        feature.start(input)
    }
}
```

- Trong trường hợp tác vụ đã hoàn thành muốn giải phóng/ kết thúc một Board, sử dụng phương thức `complete()` để remove board đó khỏi `Motherboard` của nó.

```swift
final class SomeBoard: Board, GuaranteedBoard {
    private let builder: FeatureBuilder

    private lazy var feature = builder.build(withDelegate: self)

    init(identifier: BoardID, builder: FeatureBuilder) {
        self.builder = builder
        super.init(identifier: identifier)
    }

    func activate(withGuaranteedInput input: InputType) {
        feature.start(input)
    }
}

extension SomeBoard: FeatureDelegate {
    func missionCompleted() {
        complete()
    }
}
```

## Tương tác giữa các Component trong Micosystems

Mặc dù có thể tạo ra nhiều các Motherboard nối tiếp nhau, tuy nhiên cấu trúc phẳng được khuyến khích. Chỉ tạo thêm Motherboard trong trường hợp muốn đóng gói một luồng nhỏ nào đó.

Các Board trong cùng một Motherboard có thể tương tác với nhau, tuy nhiên để đảm bảo tính độc lập chúng không tương tác trực tiếp mà thông qua Motherboard.

### Motherboard Flow

Một Board sử dụng phương thức `sendToMotherboard(data:)` để gửi một message đến Motherboard của nó. Dữ liệu (data) này được đóng gói cùng với `identifier` của Board. Motherboard khi đó có thể lắng nghe được tín hiệu này để thực hiện một tác vụ nào đó thông qua `BoardFlow`.

```swift
let dashboardCallbackFlow = BoardActivateFlow(matchedIdentifiers: [.dashboard]) { [weak self] input in
    self?.doSomething(input)
}
motherboard.registerFlows([dashboardCallbackFlow])
```

Nếu các tín hiệu tới Motherboard là duy nhất và Input/Ouput của các Board trong flow là khớp với nhau, có thể dễ dàng vẽ các flow trên Motherboard bằng các identity của chúng.
```swift
motherboard.registerFlowSteps(.dashboard ->>> .nextFeature ->>> .anotherFeature)
```

Ngoài phương thức mặc định để gửi dữ liệu bất kì tới Motherboard, một Board có thể sử dụng các phương thức tuỳ chọn sau cho các mục đích cụ thể:

* `nextToBoard(.dashboard)` để nói với Motherboard rằng hãy đưa tôi đến Board với identity `dashboard`.
* `sendAction(.returnHome)` để nói với Motherboard rằng tôi muốn trở về Home. Một Motherboard nào đó trong chuỗi có thể handle action này để thực hiện việc quay trở lại.
```swift
motherboard.registerGeneralFlow { [weak self] (action: BoardAction) in
     switch action {
     case .returnHome:
          self?.rootViewController.returnHere()
     }
}
```
* `interactWithOtherBoard(command: NewFeatureCommand.refresh(value: "someValue"))` để nói với Motherboard rằng tôi muốn tương tác với một `NewFeature` và ở đây là `refresh NewFeature với someValue`. (flow tương tác sẽ được trình bày chi tiết sau)

### Tương tác giữa các Board

Các Board trong cùng một Motherboard có thể tương tác với nhau, thông qua phương thức `interactWithOtherBoard(command:)`, trong đó `Command` sẽ chỉ định rõ `target Board identifier` và dữ liệu cần gửi đi (nếu có).

```swift
enum NewFeatureCommand: BoardCommandModel {
    case refresh(value: String)

    var identifier: BoardID { .nextFeature }

    var data: Any? {
        switch self {
        case let .refresh(value: text):
            return text
        }
    }
}
```

Board nhận tương tác cần conform protocol `GuaranteedInteractableBoard`, theo đó cần chỉ định loại Command mà nó chấp nhận `typealias Command = NewFeatureCommand` và implement phương thức `func interact(guaranteedCommand: Command)` để thực hiện tác vụ tương ứng.

```swift
final class NewFeatureBoard: Board, GuaranteedBoard, GuaranteedInteractableBoard {
    typealias Command = NewFeatureCommand
    typealias InputType = String
    
    func activate(withGuaranteedInput input: String) {
        // activate code here
    }
    
    func interact(guaranteedCommand: NewFeatureCommand) {
        switch guaranteedCommand {
        case let .refresh(value: text):
            perfromRefresh(value: text)
        }
    }
}

```


> Các component không tương tác trực tiếp với nhau, chỉ tương tác thông qua Board của chúng.

### Tương tác giữa VIP component và Board của nó

Business logic của VIP component sẽ xoay quanh các thành phần chính View - Interactor - Presenter và Data Access Layeer, nó giao tiếp với bên ngoài thông qua 2 protocol:

* `<FeatureName>Delegate` để gửi các message ra bên ngoài.
* `<FeatureName>Controllable` để nhận các message / input từ bên ngoài gọi vào.

Các protocol này được Board sử dụng để tương tác với Component.

Trong khi `Delegate` protocol khá minh bạch, `Controllable` protocol thì cần thêm một Event Source (dùng Event Source - Stream vì chúng ta đang sử dụng RxSwift), bởi vì Board thường không trực tiếp quản lý lifecycle của Component, khi cần gửi thông điệp đến Component, nó sẽ gửi tới Event Source và component sẽ lắng nghe event source changes để thực hiện tác vụ tương ứng.

```swift
final class NewFeatureBoard: Board, GuaranteedBoard, GuaranteedInteractableBoard {
    typealias Command = NewFeatureCommand
    typealias InputType = String

    private let valueStream = PublishRelay<String>()

    func activate(withGuaranteedInput input: String) {
        let component = builder.build(withDelegate: self)
        
        let controller = component.controller
        let disposeBag = component.userInterface.freshDisposeBag
        valueStream.subscribe(oneNext: { [weak controller] text in
            controller?.refresh(withValue: text)
        }).disposed(by: disposeBag)
        ...
    }

    func interact(guaranteedCommand: NewFeatureCommand) {
        switch guaranteedCommand {
        case let .refresh(value: text):
            valueStream.accept(value)
        }
    }
}
```

> Lưu ý: Để đảm bảo tính minh bạch và `controllable` như đúng tên gọi, prefer việc sử dụng POP, không pass Observable around.
