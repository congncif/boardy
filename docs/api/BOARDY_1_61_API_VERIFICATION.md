# Boardy Public API Verification Report

## Toolchain

```text
Xcode 26.4.1
Build version 17E202
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swift-api-digester=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-api-digester
host-architecture=arm64
target=arm64-apple-ios14.0-simulator
sdk=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator26.4.sdk
```

## Inputs

| Artifact | SHA-256 |
| --- | --- |
| Baseline interface: `docs/api/Boardy-1.60.1.swiftinterface` | `a29d4bb97a6214d477c3fa739366616d911393a2d557c5d4d62c69c834454bb9` |
| Baseline API graph: `docs/api/Boardy-1.60.1.interface.api.json` | `4a756df2debb2be8e071ed389914121c97474687d7aa1436b6d3e7967b26a1f1` |
| Candidate interface: `docs/api/Boardy-1.61.0.swiftinterface` | `b0f928bad0f503418d5ae5e55495002216f606a4815aad75b42a3ca04906d543` |
| Candidate API graph: `docs/api/Boardy-1.61.0.api.json` | `40264ea232b5c105931fdb8e20d8ee3a95758860a9672d934a0ace310d0e4064` |

## API digester diagnosis

No source/API break diagnosed.

```text

/* Generic Signature Changes */

/* RawRepresentable Changes */

/* Removed Decls */

/* Moved Decls */

/* Renamed Decls */

/* Type Changes */

/* Decl Attribute changes */

/* Fixed-layout Type Changes */

/* Protocol Conformance Change */

/* Protocol Requirement Change */

/* Class Inheritance Change */

/* Others */
```

## Textual public-interface diff

```diff
--- docs/api/Boardy-1.60.1.swiftinterface	2026-07-14 14:02:28
+++ docs/api/Boardy-1.61.0.swiftinterface	2026-07-14 18:07:03
@@ -1,8 +1,7 @@
 // swift-interface-format-version: 1.0
 // swift-compiler-version: Apple Swift version 6.3.1 effective-5.10 (swiftlang-6.3.1.1.2 clang-2100.0.123.102)
-// swift-module-flags: -target arm64-apple-ios12.0-simulator -enable-objc-interop -enable-library-evolution -swift-version 5 -Onone -enable-experimental-feature DebugDescriptionMacro -enable-bare-slash-regex -module-name Boardy
-// swift-module-flags-ignorable: -no-verify-emitted-module-interface -formal-cxx-interoperability-mode=off -interface-compiler-version 6.3.1
-@_exported import Boardy
+// swift-module-flags: -target arm64-apple-ios14.0-simulator -enable-objc-interop -enable-library-evolution -swift-version 5 -module-name Boardy
+// swift-module-flags-ignorable:  -formal-cxx-interoperability-mode=off -interface-compiler-version 6.3.1
 import Foundation
 import Swift
 import UIComposable
@@ -10,243 +9,21 @@
 import _Concurrency
 import _StringProcessing
 import _SwiftConcurrencyShims
-public protocol ActivatableBoard : Boardy.BoardRegistrationsConvertible, Boardy.IdentifiableBoard, Boardy.OriginalBoard {
-  func activationBarrier(withOption option: Any?) -> Boardy.ActivationBarrier?
-  func activate(withOption option: Any?)
-  func shouldBypassGatewayBarrier() -> Swift.Bool
+@_functionBuilder public enum BoardRegistrationBuilder {
+  public static func buildArray(_ components: [any Boardy.BoardRegistrationsConvertible]) -> [Boardy.BoardRegistration]
+  public static func buildBlock(_ components: any Boardy.BoardRegistrationsConvertible...) -> [Boardy.BoardRegistration]
+  public static func buildEither(first component: any Boardy.BoardRegistrationsConvertible) -> any Boardy.BoardRegistrationsConvertible
+  public static func buildEither(second component: any Boardy.BoardRegistrationsConvertible) -> any Boardy.BoardRegistrationsConvertible
+  public static func buildIf(_ value: (any Boardy.BoardRegistrationsConvertible)?) -> any Boardy.BoardRegistrationsConvertible
+  public static func buildOptional(_ component: (any Boardy.BoardRegistrationsConvertible)?) -> any Boardy.BoardRegistrationsConvertible
+  public static func buildExpression(_ component: (any Boardy.BoardRegistrationsConvertible)?) -> any Boardy.BoardRegistrationsConvertible
 }
-extension Boardy.ActivatableBoard {
-  public func asBoardRegistrations() -> [Boardy.BoardRegistration]
-  public func shouldBypassGatewayBarrier() -> Swift.Bool
+extension Boardy.Motherboard {
+  convenience public init(identifier: Boardy.BoardID = .random(), externalProducer: any Boardy.ActivatableBoardProducer = NoBoardProducer(), @Boardy.BoardRegistrationBuilder registrationsBuilder: (_ producer: any Boardy.ActivatableBoardProducer) -> [Boardy.BoardRegistration])
 }
-extension Boardy.ActivatableBoard {
-  public func activate()
-  public func activationBarrier(withOption _: Any?) -> Boardy.ActivationBarrier?
-}
-public typealias NormalBoard = Boardy.ActivatableBoard & Boardy.InstallableBoard
-public struct ActivationBarrier {
-  public let identifier: Boardy.BoardID
-  public let scope: Boardy.ActivationBarrierScope
-  public let option: Boardy.ActivationBarrierOption
-}
-public enum ActivationBarrierScope {
-  case mainboard
-  case application
-  public static func == (a: Boardy.ActivationBarrierScope, b: Boardy.ActivationBarrierScope) -> Swift.Bool
-  public func hash(into hasher: inout Swift.Hasher)
-  public var hashValue: Swift.Int {
-    get
-  }
-}
-extension Boardy.ActivationBarrierScope {
-  @available(*, deprecated, renamed: "mainboard", message: "Use .mainboard instead")
-  public static var inMain: Boardy.ActivationBarrierScope {
-    get
-  }
-  @available(*, deprecated, renamed: "application", message: "Use .application instead")
-  public static var global: Boardy.ActivationBarrierScope {
-    get
-  }
-}
-public enum ActivationBarrierOption {
-  case void
-  case unique(Swift.AnyHashable)
-  case unidentified(Any?)
-}
-extension Boardy.ActivationBarrier {
-  public var barrierIdentifier: Boardy.BoardID {
-    get
-  }
-}
-public protocol ActivatableBoardProducer {
-  func produceBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  func produceGatewayBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  func matchBoard(withIdentifier identifier: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-}
-extension Boardy.ActivatableBoardProducer {
-  public func matchBoard(withIdentifier _: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  public func produceGatewayBoard(identifier _: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-}
-@available(*, deprecated, renamed: "ActivatableBoardProducer", message: "The protocol was renamed to ActivatableBoardProducer to fix typo")
-public typealias ActivableBoardProducer = Boardy.ActivatableBoardProducer
-final public class AdapterBoard<Destination, In, Out> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard, Boardy.InteractableBoard, Boardy.BoardDelegate where Destination : Boardy.GuaranteedBoard, Destination : Boardy.GuaranteedOutputSendingBoard {
-  public typealias InputType = In
-  public typealias OutputType = Out
-  final public let destination: Destination
-  public init(destination: Destination, inputMapper: @escaping (In) -> Destination.InputType, outputMapper: @escaping (Destination.OutputType) -> Out)
-  final public func setInputMapper(_ mapper: @escaping (In) -> Destination.InputType) -> Self
-  final public func setOutputMapper(_ mapper: @escaping (Destination.OutputType) -> Out) -> Self
-  final public func activationBarrier(withGuaranteedInput input: In) -> Boardy.ActivationBarrier?
-  final public func activate(withGuaranteedInput input: Boardy.AdapterBoard<Destination, In, Out>.InputType)
-  final public func interact(command: Any?)
-  final public func board(_: any Boardy.IdentifiableBoard, didSendData data: Any?)
-  final public func shouldBypassGatewayBarrier() -> Swift.Bool
-  @objc deinit
-}
-extension Boardy.AdapterBoard where In == Destination.InputType {
-  convenience public init(destination: Destination, outputMapper: @escaping (Destination.OutputType) -> Out)
-}
-extension Boardy.AdapterBoard where Out == Destination.OutputType {
-  convenience public init(destination: Destination, inputMapper: @escaping (In) -> Destination.InputType)
-}
-extension Boardy.AdapterBoard where In == Destination.InputType, Out == Destination.OutputType {
-  convenience public init(destination: Destination)
-}
-public struct AlertAction {
-  public init(title: Swift.String, style: Boardy.AlertAction.Style = .default, shouldBePreferred: Swift.Bool = false, handler: (() -> Swift.Void)?)
-  public init<Target>(title: Swift.String, style: Boardy.AlertAction.Style = .default, shouldBePreferred: Swift.Bool = false, target: Target, handler: ((Target) -> Swift.Void)?) where Target : AnyObject
-  public enum Style {
-    case `default`
-    case cancel
-    case destructive
-    public static func == (a: Boardy.AlertAction.Style, b: Boardy.AlertAction.Style) -> Swift.Bool
-    public func hash(into hasher: inout Swift.Hasher)
-    public var hashValue: Swift.Int {
-      get
-    }
-  }
-}
-public struct Alert {
-  public init(title: Swift.String? = nil, message: Swift.String?, style: Boardy.Alert.Style = .alert, actions: [Boardy.AlertAction])
-  public enum Style {
-    case alert
-    case actionSheet
-    public static func == (a: Boardy.Alert.Style, b: Boardy.Alert.Style) -> Swift.Bool
-    public func hash(into hasher: inout Swift.Hasher)
-    public var hashValue: Swift.Int {
-      get
-    }
-  }
-}
-extension Boardy.MotherboardType {
-  public func activateAlert(_ alert: Boardy.Alert)
-}
-public protocol DetachableObject : AnyObject {
-  func detachObject(_ object: Swift.AnyObject)
-}
-public protocol AttachableObject : Boardy.DetachableObject {
-  func attach(to object: Swift.AnyObject)
-  func attachObject(_ object: Swift.AnyObject)
-  func attachedObjects() -> [Swift.AnyObject]
-  func detachAllObjects()
-}
-extension Boardy.AttachableObject {
-  public func attach(to object: Swift.AnyObject)
-  public func attachObject(_ object: Swift.AnyObject)
-  public func attachedObjects() -> [Swift.AnyObject]
-  public func attachedObjects<ObjectType>(_: ObjectType.Type = ObjectType.self) -> [ObjectType]
-  public func firstAttachedObject<ObjectType>(_: ObjectType.Type = ObjectType.self) -> ObjectType?
-  public func lastAttachedObject<ObjectType>(_: ObjectType.Type = ObjectType.self) -> ObjectType?
-  public func detachObject(_ object: Swift.AnyObject)
-  public func detachObjects<ObjectType>(_: ObjectType.Type, where condition: (ObjectType) -> Swift.Bool = { _ in true })
-  public func detachObjects(where condition: (Swift.AnyObject) -> Swift.Bool)
-  public func detachAllObjects()
-}
-@_inheritsConvenienceInitializers final public class BarrierBoard<Input> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard {
-  public typealias InputType = Boardy.BarrierBoard<Input>.Action
-  public typealias OutputType = Input
-  public typealias Process = (Input) -> Swift.Void
-  public enum Action {
-    case wait(Boardy.BarrierBoard<Input>.Process)
-    case overcome(Boardy.BarrierBoard<Input>.OutputType)
-    case cancel
-  }
-  final public func activate(withGuaranteedInput input: Boardy.BarrierBoard<Input>.InputType)
-  final public func shouldBypassGatewayBarrier() -> Swift.Bool
-  override public init(identifier: Boardy.BoardID)
-  @objc deinit
-}
-final public class BlockTaskParameter<Input, Output> {
-  public init(input: Input)
-  final public func onSuccess(_ handler: Boardy.BlockTaskParameter<Input, Output>.SuccessHandler?) -> Self
-  final public func onSuccess(_ handler: ((Output) -> Swift.Void)?) -> Self
-  final public func onSuccess<Target>(target: Target, action: ((Target, Output) -> Swift.Void)?) -> Self
-  final public func onProcessing(_ handler: Boardy.BlockTaskParameter<Input, Output>.ProcessingHandler?) -> Self
-  final public func onProcessing(_ handler: ((Swift.Bool) -> Swift.Void)?) -> Self
-  final public func onProcessing<Target>(target: Target, action: ((Target, Swift.Bool) -> Swift.Void)?) -> Self
-  final public func onError(_ handler: Boardy.BlockTaskParameter<Input, Output>.ErrorHandler?) -> Self
-  final public func onError(_ handler: ((any Swift.Error) -> Swift.Void)?) -> Self
-  final public func onError<Target>(target: Target, action: ((Target, any Swift.Error) -> Swift.Void)?) -> Self
-  final public func onCompletion(_ handler: Boardy.BlockTaskParameter<Input, Output>.CompletionHandler?) -> Self
-  final public func onCompletion(_ handler: ((Boardy.TaskCompletionStatus) -> Swift.Void)?) -> Self
-  final public func onCompletion<Target>(target: Target, action: ((Target, Boardy.TaskCompletionStatus) -> Swift.Void)?) -> Self
-  final public let input: Input
-  final public var successHandler: Boardy.BlockTaskParameter<Input, Output>.SuccessHandler? {
-    get
-  }
-  final public var processingHandler: Boardy.BlockTaskParameter<Input, Output>.ProcessingHandler? {
-    get
-  }
-  final public var errorHandler: Boardy.BlockTaskParameter<Input, Output>.ErrorHandler? {
-    get
-  }
-  final public var completionHandler: Boardy.BlockTaskParameter<Input, Output>.CompletionHandler? {
-    get
-  }
-  public typealias SuccessHandler = (any Boardy.ActivatableBoard, Output) -> Swift.Void
-  public typealias ProcessingHandler = (any Boardy.ActivatableBoard, Swift.Bool) -> Swift.Void
-  public typealias ErrorHandler = (any Boardy.ActivatableBoard, any Swift.Error) -> Swift.Void
-  public typealias CompletionHandler = (any Boardy.ActivatableBoard, Boardy.TaskCompletionStatus) -> Swift.Void
-  @objc deinit
-}
-extension Boardy.BlockTaskParameter {
-  final public func appendingSuccessHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.SuccessHandler) -> Self
-  final public func appendingErrorHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.ErrorHandler) -> Self
-  final public func appendingCompletionHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.CompletionHandler) -> Self
-  final public func appendingProcessingHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.ProcessingHandler) -> Self
-}
-public enum TaskCompletionStatus {
-  case done
-  case cancelled
-  public static func == (a: Boardy.TaskCompletionStatus, b: Boardy.TaskCompletionStatus) -> Swift.Bool
-  public func hash(into hasher: inout Swift.Hasher)
-  public var hashValue: Swift.Int {
-    get
-  }
-}
-extension Boardy.BlockTaskParameter where Input : Swift.ExpressibleByNilLiteral {
-  convenience public init()
-}
-extension Boardy.BlockTaskParameter where Input == () {
-  convenience public init()
-}
-extension Boardy.BlockTaskBoard {
-  convenience public init(identifier: Boardy.BoardID, executingType: Boardy.ExecutingType = .default, execute work: @escaping (Boardy.BlockTaskBoard<Input, Output>, Input, @escaping Boardy.BlockTaskBoard<Input, Output>.ExecutorCompletion) -> Swift.Void)
-}
-public enum ExecutingType {
-  case `default`
-  case latest
-  case only
-  case onlyResult
-  case queue
-  case concurrent(max: Swift.Int)
-  public static var concurrent: Boardy.ExecutingType {
-    get
-  }
-}
-final public class BlockTaskBoard<Input, Output> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard {
-  public typealias InputType = Boardy.BlockTaskParameter<Input, Output>
-  public typealias OutputType = Output
-  public typealias ExecutorCompletion = (Swift.Result<Output, any Swift.Error>) -> Swift.Void
-  public typealias Executor = (Boardy.BlockTaskBoard<Input, Output>, Input, @escaping Boardy.BlockTaskBoard<Input, Output>.ExecutorCompletion) -> Boardy.BlockTaskCanceler
-  public init(identifier: Boardy.BoardID, executingType: Boardy.ExecutingType, allowBypassGatewayBarrier: Swift.Bool = true, executor: @escaping Boardy.BlockTaskBoard<Input, Output>.Executor)
-  @objc deinit
-  final public var inputAdapters: [(Any?) -> Boardy.BlockTaskParameter<Input, Output>?] {
-    get
-  }
-  final public func shouldBypassGatewayBarrier() -> Swift.Bool
-  final public func activate(withGuaranteedInput input: Boardy.BlockTaskBoard<Input, Output>.InputType)
-}
-extension Boardy.BlockTaskCanceler {
-  public static var none: Boardy.BlockTaskCanceler {
-    get
-  }
-  public static func `default`(handler: @escaping () -> Swift.Void) -> Boardy.BlockTaskCanceler
+extension Boardy.BoardProducer {
+  convenience public init(externalProducer: any Boardy.ActivatableBoardProducer = NoBoardProducer(), @Boardy.BoardRegistrationBuilder registrationsBuilder: (_ producer: any Boardy.ActivatableBoardProducer) -> [Boardy.BoardRegistration])
 }
-public struct BlockTaskCanceler {
-  public init(handler: @escaping () -> Swift.Void)
-  public func cancel()
-}
 open class Board : Boardy.IdentifiableBoard, Boardy.OriginalBoard {
   final public let identifier: Boardy.BoardID
   weak public var delegate: (any Boardy.BoardDelegate)?
@@ -273,140 +50,62 @@
 }
 extension Boardy.Board : Boardy.WindowInstallableBoard {
 }
-extension ObjectiveC.NSObject : Boardy.AttachableObject {
+open class BusCable<Input> {
+  public typealias Handler = (Input) -> Swift.Void
+  public init(transportHandler: @escaping Boardy.BusCable<Input>.Handler)
+  open func transport(input: Input)
+  open var isValid: Swift.Bool {
+    get
+  }
+  open func invalidate()
+  @objc deinit
 }
-extension Boardy.Board : Boardy.AttachableObject {
+final public class TargetBusCable<Target, Input> : Boardy.BusCable<Input> {
+  public init(target: Target, handler: @escaping (Target, Input) -> Swift.Void)
+  override final public var isValid: Swift.Bool {
+    get
+  }
+  override final public func invalidate()
+  @objc deinit
 }
-extension Boardy.ModernContinuableBoard {
-  @discardableResult
-  public func attachContinuousMotherboard(to context: any Boardy.AttachableObject, configurationBuilder: (any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void = { _ in }) -> any Boardy.FlowManageable & Boardy.MotherboardType
-  @discardableResult
-  public func attachContinuousMotherboard<Mainboard>(to context: any Boardy.AttachableObject, build: (any Boardy.ActivatableBoardProducer) -> Mainboard) -> Mainboard where Mainboard : Boardy.FlowManageable, Mainboard : Boardy.MotherboardType
-}
-extension Boardy.ActivatableBoardProducer {
-  public func produceComposableMotherboard(identifier: Boardy.BoardID, from parent: (any Boardy.IdentifiableBoard)? = nil, elementsBuilder: (any Boardy.ActivatableBoardProducer) -> [any Boardy.ActivatableBoard] = { _ in [] }) -> any Boardy.ComposableMotherboardType & Boardy.FlowManageable
-}
-extension Boardy.ActivatableBoardProducer {
-  public func produceContinuousMotherboard(identifier: Boardy.BoardID, from parent: (any Boardy.IdentifiableBoard)? = nil, elementsBuilder: (any Boardy.ActivatableBoardProducer) -> [any Boardy.ActivatableBoard] = { _ in [] }) -> any Boardy.FlowManageable & Boardy.MotherboardType
-}
-public struct BoardActivateFlow : Boardy.BoardFlow {
-  public let identifier: Swift.String
-  public init(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, outputNextHandler: @escaping (any Boardy.BoardOutputModel) -> Swift.Void)
-  public init(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, nextHandler: @escaping (Any?) -> Swift.Void)
-  public init<Output>(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, dedicatedNextHandler: @escaping (Output?) -> Swift.Void)
-  public init<Output>(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, guaranteedNextHandler: @escaping (Output) -> Swift.Void)
-  public init(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], outputNextHandler: @escaping (any Boardy.BoardOutputModel) -> Swift.Void)
-  public init(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], nextHandler: @escaping (Any?) -> Swift.Void)
-  public init<Output>(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], dedicatedNextHandler: @escaping (Output?) -> Swift.Void)
-  public init<Output>(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], guaranteedNextHandler: @escaping (Output) -> Swift.Void)
-  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
-  public func doNext(with output: any Boardy.BoardOutputModel)
-}
-final public class BoardContainer : Boardy.BoardDynamicProducer {
-  public init(externalProducer: (any Boardy.ActivatableBoardProducer)? = nil)
-  final public func registerBoard(_ identifier: Boardy.BoardID, factory: @escaping Boardy.BoardConstructor)
-  final public func registerBoards(_ identifiers: [Boardy.BoardID], factory: @escaping Boardy.BoardConstructor)
-  final public func registerBoards(_ identifiers: Boardy.BoardID..., factory: @escaping Boardy.BoardConstructor)
-  final public func registerGatewayBoard(_ identifier: Boardy.BoardID, factory: @escaping (Boardy.BoardID) -> any Boardy.ActivatableBoard)
-  final public func produceBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  final public func produceGatewayBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  final public func matchBoard(withIdentifier identifier: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+final public class Bus<Input> {
+  public init()
+  final public func connect(_ cable: Boardy.BusCable<Input>)
+  final public func transport(input: Input)
   @objc deinit
 }
-public protocol BoardFlow {
-  var identifier: Swift.String { get }
-  func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
-  func doNext(with output: any Boardy.BoardOutputModel)
+extension Boardy.Bus {
+  final public func connect<Target>(target: Target, handler: @escaping (Target, Input) -> Swift.Void)
+  final public func connect<Target>(target: Target, handler: @escaping (Target) -> Swift.Void)
+  final public func deliver(handler: @escaping (Input) -> Swift.Void)
 }
-public protocol IDMatchBoardFlow : Boardy.BoardFlow {
-  var matchedBoardIDs: [Boardy.BoardID] { get }
+extension Boardy.Bus where Input == () {
+  final public func transport()
 }
-extension Boardy.IDMatchBoardFlow {
-  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
+extension Boardy.Bus where Input == Any? {
+  final public func transport()
 }
-public protocol DataMatchBoardFlow : Boardy.BoardFlow {
-  associatedtype Output
-  func doNext(withData data: Self.Output)
+extension Boardy.Bus where Input == Any {
+  final public func transport()
 }
-extension Boardy.DataMatchBoardFlow {
-  public func doNext(with output: any Boardy.BoardOutputModel)
-}
-public protocol GuaranteedBoardFlow : Boardy.DataMatchBoardFlow, Boardy.IDMatchBoardFlow {
-}
-public struct IDGenericBoardFlow<Out> : Boardy.GuaranteedBoardFlow {
-  public typealias Output = Out
-  public let identifier: Swift.String
-  public let matchedBoardIDs: [Boardy.BoardID]
-  public init(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: [Boardy.BoardID], nextHandler: @escaping (Out) -> Swift.Void)
-  public init(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: Boardy.BoardID..., nextHandler: @escaping (Out) -> Swift.Void)
-  public init<HandlerTarget>(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: [Boardy.BoardID], target: HandlerTarget, nextHandler: @escaping (HandlerTarget, Out) -> Swift.Void)
-  public init<BoardType, HandlerTarget>(identifier: Swift.String = UUID().uuidString, matchedBoardID: Boardy.BoardID, of _: BoardType.Type, target: HandlerTarget, nextHandler: @escaping (HandlerTarget, BoardType.OutputType) -> Swift.Void) where Out == BoardType.OutputType, BoardType : Boardy.GuaranteedOutputSendingBoard
-  public init<BoardType>(identifier: Swift.String = UUID().uuidString, matchedBoardID: Boardy.BoardID, of _: BoardType.Type, nextHandler: @escaping (BoardType.OutputType) -> Swift.Void) where Out == BoardType.OutputType, BoardType : Boardy.GuaranteedOutputSendingBoard
-  public init<HandlerTarget>(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: Boardy.BoardID..., target: HandlerTarget, nextHandler: @escaping (HandlerTarget, Out) -> Swift.Void)
-  public func doNext(withData data: Out)
-}
-public struct GenericBoardFlow<Out> : Boardy.DataMatchBoardFlow {
-  public typealias Output = Out
-  public var identifier: Swift.String
-  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
-  public func doNext(withData data: Out)
-  public init(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool = { _ in true }, nextHandler: @escaping (Out) -> Swift.Void)
-  public init<HandlerTarget>(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool = { _ in true }, target: HandlerTarget, nextHandler: @escaping (HandlerTarget, Out) -> Swift.Void)
-}
-public struct BoardID : Swift.LosslessStringConvertible, Swift.ExpressibleByStringLiteral, Swift.Hashable, Swift.RawRepresentable {
-  public typealias StringLiteralType = Swift.String
-  public let rawValue: Swift.String
-  public init(stringLiteral value: Boardy.BoardID.StringLiteralType)
-  public init(_ description: Swift.String)
-  public init(rawValue: Swift.String)
-  public var description: Swift.String {
+open class Motherboard : Boardy.Board, Boardy.BoardDelegate, Boardy.FlowMotherboard {
+  public var flows: [any Boardy.BoardFlow]
+  override public var debugDescription: Swift.String {
     get
   }
-  public static func random() -> Boardy.BoardID
-  public typealias ExtendedGraphemeClusterLiteralType = Boardy.BoardID.StringLiteralType
-  public typealias RawValue = Swift.String
-  public typealias UnicodeScalarLiteralType = Boardy.BoardID.StringLiteralType
-}
-extension Boardy.BoardID : Swift.Equatable {
-  public static func == (lhs: Boardy.BoardID, rhs: Boardy.BoardID) -> Swift.Bool
-}
-public func ~= (pattern: Boardy.BoardID, value: Swift.String) -> Swift.Bool
-extension Boardy.BoardID {
-  public func appending(_ tail: Swift.String, separator: Swift.String = ".") -> Boardy.BoardID
-}
-public protocol BoardInputModel {
-  var identifier: Boardy.BoardID { get }
-  var option: Any? { get }
-}
-public struct BoardInput<Input> : Boardy.BoardInputModel {
-  public let identifier: Boardy.BoardID
-  public let input: Input
-  public var option: Any? {
+  public init(identifier: Boardy.BoardID = .random(), boards: [any Boardy.ActivatableBoard] = [])
+  public init(identifier: Boardy.BoardID = .random(), boardProducer: any Boardy.ActivatableBoardProducer)
+  convenience public init(identifier: Boardy.BoardID = .random(), boardProducer: any Boardy.ActivatableBoardProducer, boards: [any Boardy.ActivatableBoard])
+  override open func putIntoContext(_ context: Swift.AnyObject)
+  @discardableResult
+  public func registerFlow(_ flow: any Boardy.BoardFlow) -> Self
+  public func resetFlows()
+  public func removeFlow(by identifier: Swift.String)
+  public var boardProducer: any Boardy.ActivatableBoardProducer {
     get
   }
-  public init(target: Boardy.BoardID, input: Input)
+  @objc deinit
 }
-extension Boardy.BoardInput {
-  public static func target<InputValue>(_ id: Boardy.BoardID, _ input: InputValue) -> Boardy.BoardInput<InputValue>
-}
-extension Boardy.BoardInput where Input == () {
-  public init(target: Boardy.BoardID)
-  public static func target(_ id: Boardy.BoardID) -> Boardy.BoardInput<Swift.Void>
-}
-extension Boardy.BoardInput where Input : Swift.ExpressibleByNilLiteral {
-  public init(target: Boardy.BoardID)
-  public static func target(_ id: Boardy.BoardID) -> Boardy.BoardInput<Input>
-}
-extension Boardy.BoardID {
-  public func with<Input>(input: Input) -> Boardy.BoardInput<Input>
-  public var withoutInput: Boardy.BoardInput<Swift.Void> {
-    get
-  }
-}
-public protocol BoardOutputModel {
-  var identifier: Boardy.BoardID { get }
-  var data: Any? { get }
-}
 public protocol BoardRegistrationsConvertible {
   func asBoardRegistrations() -> [Boardy.BoardRegistration]
 }
@@ -452,219 +151,30 @@
     get
   }
 }
-public typealias BoardConstructor = (Boardy.BoardID) -> any Boardy.ActivatableBoard
-public struct BoardRegistration : Swift.Hashable {
-  public init(_ identifier: Boardy.BoardID, constructor: @escaping (Boardy.BoardID) -> (any Boardy.ActivatableBoard)?)
-  public let identifier: Boardy.BoardID
-  public let constructor: (Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  public func hash(into hasher: inout Swift.Hasher)
-  public static func == (lhs: Boardy.BoardRegistration, rhs: Boardy.BoardRegistration) -> Swift.Bool
-  public var hashValue: Swift.Int {
-    get
-  }
-}
-@_functionBuilder public enum BoardRegistrationBuilder {
-  public static func buildArray(_ components: [any Boardy.BoardRegistrationsConvertible]) -> [Boardy.BoardRegistration]
-  public static func buildBlock(_ components: any Boardy.BoardRegistrationsConvertible...) -> [Boardy.BoardRegistration]
-  public static func buildEither(first component: any Boardy.BoardRegistrationsConvertible) -> any Boardy.BoardRegistrationsConvertible
-  public static func buildEither(second component: any Boardy.BoardRegistrationsConvertible) -> any Boardy.BoardRegistrationsConvertible
-  public static func buildIf(_ value: (any Boardy.BoardRegistrationsConvertible)?) -> any Boardy.BoardRegistrationsConvertible
-  public static func buildOptional(_ component: (any Boardy.BoardRegistrationsConvertible)?) -> any Boardy.BoardRegistrationsConvertible
-  public static func buildExpression(_ component: (any Boardy.BoardRegistrationsConvertible)?) -> any Boardy.BoardRegistrationsConvertible
-}
-extension Boardy.Motherboard {
-  convenience public init(identifier: Boardy.BoardID = .random(), externalProducer: any Boardy.ActivatableBoardProducer = NoBoardProducer(), @Boardy.BoardRegistrationBuilder registrationsBuilder: (_ producer: any Boardy.ActivatableBoardProducer) -> [Boardy.BoardRegistration])
-}
-extension Boardy.BoardProducer {
-  convenience public init(externalProducer: any Boardy.ActivatableBoardProducer = NoBoardProducer(), @Boardy.BoardRegistrationBuilder registrationsBuilder: (_ producer: any Boardy.ActivatableBoardProducer) -> [Boardy.BoardRegistration])
-}
-public protocol BoardDelegate : AnyObject {
-  func board(_ board: any Boardy.IdentifiableBoard, didSendData data: Any?)
-}
-public protocol OriginalBoard {
-  var context: Swift.AnyObject? { get }
-  func putIntoContext(_ context: Swift.AnyObject)
-}
-public protocol IdentifiableBoard : AnyObject, Swift.CustomDebugStringConvertible {
-  var delegate: (any Boardy.BoardDelegate)? { get set }
-  var identifier: Boardy.BoardID { get }
-}
-extension Boardy.IdentifiableBoard {
-  public func sendToMotherboard(data: Any? = nil)
-  public func nextToBoard(model: any Boardy.BoardInputModel)
-  public func nextToBoard<Input>(_ input: Boardy.BoardInput<Input>)
-  public func sendFlowAction(_ action: any Boardy.BoardFlowAction)
-  public func interactWithOtherBoard(command: any Boardy.BoardCommandModel)
-  public func interactWithOtherBoard<Input>(_ input: Boardy.BoardCommand<Input>)
-  public func complete(_ isDone: Swift.Bool = true)
-  public var debugDescription: Swift.String {
-    get
-  }
-}
-extension Boardy.IdentifiableBoard {
-  public func putToComposer(elementAction: UIComposable.UIElementAction)
-}
-extension UIComposable.UIElement {
-  public init(identifier: Boardy.BoardID, contentViewController: UIKit.UIViewController?, configuration: Any? = nil)
-}
-open class BusCable<Input> {
-  public typealias Handler = (Input) -> Swift.Void
-  public init(transportHandler: @escaping Boardy.BusCable<Input>.Handler)
-  open func transport(input: Input)
-  open var isValid: Swift.Bool {
-    get
-  }
-  open func invalidate()
+final public class BoardContainer : Boardy.BoardDynamicProducer {
+  public init(externalProducer: (any Boardy.ActivatableBoardProducer)? = nil)
+  final public func registerBoard(_ identifier: Boardy.BoardID, factory: @escaping Boardy.BoardConstructor)
+  final public func registerBoards(_ identifiers: [Boardy.BoardID], factory: @escaping Boardy.BoardConstructor)
+  final public func registerBoards(_ identifiers: Boardy.BoardID..., factory: @escaping Boardy.BoardConstructor)
+  final public func registerGatewayBoard(_ identifier: Boardy.BoardID, factory: @escaping (Boardy.BoardID) -> any Boardy.ActivatableBoard)
+  final public func produceBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  final public func produceGatewayBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  final public func matchBoard(withIdentifier identifier: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
   @objc deinit
 }
-final public class TargetBusCable<Target, Input> : Boardy.BusCable<Input> {
-  public init(target: Target, handler: @escaping (Target, Input) -> Swift.Void)
-  override final public var isValid: Swift.Bool {
-    get
-  }
-  override final public func invalidate()
+final public class NoBoard : Boardy.Board, Boardy.ActivatableBoard {
+  public init(identifier: Boardy.BoardID, message: Swift.String? = nil, handler: ((Any?) -> Swift.Void)? = nil)
+  final public func activate(withOption option: Any?)
+  final public func shouldBypassGatewayBarrier() -> Swift.Bool
   @objc deinit
 }
-final public class Bus<Input> {
+final public class NoBoardProducer : Boardy.ActivatableBoardProducer {
   public init()
-  final public func connect(_ cable: Boardy.BusCable<Input>)
-  final public func transport(input: Input)
+  final public func produceGatewayBoard(identifier _: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  final public func matchBoard(withIdentifier _: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  final public func produceBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
   @objc deinit
 }
-extension Boardy.Bus {
-  final public func connect<Target>(target: Target, handler: @escaping (Target, Input) -> Swift.Void)
-  final public func connect<Target>(target: Target, handler: @escaping (Target) -> Swift.Void)
-  final public func deliver(handler: @escaping (Input) -> Swift.Void)
-}
-extension Boardy.Bus where Input == () {
-  final public func transport()
-}
-extension Boardy.Bus where Input == Any? {
-  final public func transport()
-}
-extension Boardy.Bus where Input == Any {
-  final public func transport()
-}
-final public class ChainBoardFlow<Target> : Boardy.BoardFlow {
-  final public let identifier: Swift.String
-  public init(identifier: Swift.String = UUID().uuidString, manager: any Boardy.FlowManageable, target: Target, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool)
-  final public func handle<Output>(outputType _: Output.Type, handler: @escaping (Target, Output) -> Swift.Void) -> Self
-  @discardableResult
-  final public func eventuallyHandle<Output>(outputType _: Output.Type, handler: @escaping (Target, Output?) -> Swift.Void) -> any Boardy.FlowManageable
-  @discardableResult
-  final public func eventuallyHandle(skipSilentData: Swift.Bool = true, handler: @escaping (Target, Any?) -> Swift.Void) -> any Boardy.FlowManageable
-  @discardableResult
-  final public func eventuallySkipHandling() -> any Boardy.FlowManageable
-  final public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
-  final public func doNext(with output: any Boardy.BoardOutputModel)
-  @objc deinit
-}
-final public class ChainDataHandler<Target> where Target : AnyObject {
-  weak final public var target: Target?
-  public init(_ target: Target)
-  final public func with<Value>(dataType _: Value.Type, handler: @escaping (Target, Value) -> Swift.Void) -> Self
-  final public func fallback(handler: @escaping (Target, Any?) -> Swift.Void = { target, data in
-            print(
-                """
-                ⚠️ [\(String(describing: ChainDataHandler.self))] fallback handling:
-                🎯 Target: \(String(describing: target))
-                🌸 Data: \(String(describing: data))
-                """
-            )
-    }) -> Self
-  final public func handle(data: Any?)
-  @objc deinit
-}
-public protocol OutputSpecifications {
-  var identifier: Boardy.BoardID { get }
-  func validateOutput(_ data: Any?) -> Swift.Bool
-}
-public struct GeneralOutputSpecifications : Boardy.OutputSpecifications {
-  public init(identifier: Boardy.BoardID, validation: ((Any?) -> Swift.Bool)? = nil)
-  public let identifier: Boardy.BoardID
-  public let validation: (Any?) -> Swift.Bool
-  public func validateOutput(_ data: Any?) -> Swift.Bool
-}
-public struct GuaranteedOutputSpecifications<Value> : Boardy.OutputSpecifications {
-  public init(identifier: Boardy.BoardID, valueType: Value.Type)
-  public let identifier: Boardy.BoardID
-  public let valueType: Value.Type
-  public func validateOutput(_ data: Any?) -> Swift.Bool
-}
-public class OutputCombinedFlow : Boardy.BoardFlow {
-  public enum Strategy {
-    case batchOneByOne
-    case latestForever
-    public static func == (a: Boardy.OutputCombinedFlow.Strategy, b: Boardy.OutputCombinedFlow.Strategy) -> Swift.Bool
-    public func hash(into hasher: inout Swift.Hasher)
-    public var hashValue: Swift.Int {
-      get
-    }
-  }
-  final public let identifier: Swift.String
-  final public let specifications: [any Boardy.OutputSpecifications]
-  final public let strategy: Boardy.OutputCombinedFlow.Strategy
-  public var matchedIdentifiers: [Boardy.BoardID] {
-    get
-  }
-  public init(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.BoardID], strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, handler: @escaping ([Any]) -> Swift.Void)
-  public init(identifier: Swift.String = UUID().uuidString, specifications: [any Boardy.OutputSpecifications], strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping ([Any]) -> Swift.Void)
-  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
-  public func doNext(with output: any Boardy.BoardOutputModel)
-  @objc deinit
-}
-public class OutputCombinedCollectionFlow<Value> : Boardy.OutputCombinedFlow {
-  public init(identifier: Swift.String = UUID().uuidString, specs: [Boardy.GuaranteedOutputSpecifications<Value>], strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping ([Value]) -> Swift.Void)
-  @objc deinit
-}
-public class OutputCombined2Flow<V1, V2> : Boardy.OutputCombinedFlow {
-  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2) -> Swift.Void)
-  @objc deinit
-}
-public class OutputCombined3Flow<V1, V2, V3> : Boardy.OutputCombinedFlow {
-  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, spec3: Boardy.GuaranteedOutputSpecifications<V3>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2, V3) -> Swift.Void)
-  @objc deinit
-}
-public class OutputCombined4Flow<V1, V2, V3, V4> : Boardy.OutputCombinedFlow {
-  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, spec3: Boardy.GuaranteedOutputSpecifications<V3>, spec4: Boardy.GuaranteedOutputSpecifications<V4>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2, V3, V4) -> Swift.Void)
-  @objc deinit
-}
-public class OutputCombined5Flow<V1, V2, V3, V4, V5> : Boardy.OutputCombinedFlow {
-  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, spec3: Boardy.GuaranteedOutputSpecifications<V3>, spec4: Boardy.GuaranteedOutputSpecifications<V4>, spec5: Boardy.GuaranteedOutputSpecifications<V5>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2, V3, V4, V5) -> Swift.Void)
-  @objc deinit
-}
-extension Boardy.FlowManageable {
-  @discardableResult
-  public func registerCombinedFlow<Output>(_ specs: [Boardy.GuaranteedOutputSpecifications<Output>], strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping ([Output]) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<Target, Output>(_ specs: [Boardy.GuaranteedOutputSpecifications<Output>], strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, [Output]) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<O1, O2>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<Target, O1, O2>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<O1, O2, O3>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2, O3) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<Target, O1, O2, O3>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2, O3) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<O1, O2, O3, O4>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2, O3, O4) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<Target, O1, O2, O3, O4>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2, O3, O4) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<O1, O2, O3, O4, O5>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, _ outputSpecifications5: Boardy.GuaranteedOutputSpecifications<O5>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2, O3, O4, O5) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerCombinedFlow<Target, O1, O2, O3, O4, O5>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, _ outputSpecifications5: Boardy.GuaranteedOutputSpecifications<O5>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2, O3, O4, O5) -> Swift.Void) -> Self
-}
-public protocol ComposableMotherboardType : Boardy.MotherboardType {
-  func connect(to interface: any UIComposable.ComposableInterface)
-}
-public typealias FlowComposableMotherboard = Boardy.ComposableMotherboardType & Boardy.FlowManageable
-@_inheritsConvenienceInitializers open class ComposableMotherboard : Boardy.Motherboard, Boardy.ComposableMotherboardType {
-  public func connect(to interface: any UIComposable.ComposableInterface)
-  override public init(identifier: Boardy.BoardID = super, boards: [any Boardy.ActivatableBoard] = super)
-  override public init(identifier: Boardy.BoardID = super, boardProducer: any Boardy.ActivatableBoardProducer)
-  @objc deinit
-}
 public protocol ContinuableBoard : Boardy.IdentifiableBoard, Boardy.OriginalBoard {
   var motherboard: any Boardy.FlowManageable & Boardy.MotherboardType { get }
 }
@@ -696,58 +206,102 @@
   override open func putIntoContext(_ context: Swift.AnyObject)
   @objc deinit
 }
-public protocol AdaptableBoard {
-  associatedtype InputType
-  var inputAdapters: [(Any?) -> Self.InputType?] { get }
+extension Boardy.ActivatableBoardProducer {
+  public func produceContinuousMotherboard(identifier: Boardy.BoardID, from parent: (any Boardy.IdentifiableBoard)? = nil, elementsBuilder: (any Boardy.ActivatableBoardProducer) -> [any Boardy.ActivatableBoard] = { _ in [] }) -> any Boardy.FlowManageable & Boardy.MotherboardType
 }
-extension Boardy.AdaptableBoard {
-  public func convertOptionToInput(_ option: Any?) -> Self.InputType?
-  public var inputAdapters: [(Any?) -> Self.InputType?] {
+final public class ChainDataHandler<Target> where Target : AnyObject {
+  weak final public var target: Target?
+  public init(_ target: Target)
+  final public func with<Value>(dataType _: Value.Type, handler: @escaping (Target, Value) -> Swift.Void) -> Self
+  final public func fallback(handler: @escaping (Target, Any?) -> Swift.Void = { target, data in
+    }) -> Self
+  final public func handle(data: Any?)
+  @objc deinit
+}
+public protocol BoardOutputModel {
+  var identifier: Boardy.BoardID { get }
+  var data: Any? { get }
+}
+extension Boardy.MotherboardType {
+  public func activateBoard(identifier: Boardy.BoardID, withOption option: Any?)
+  public func activateBoard(model: any Boardy.BoardInputModel)
+  public func activateBoard(_ input: Boardy.BoardInput<some Any>)
+  public func deactivateBoard(identifier: Boardy.BoardID)
+}
+public protocol BoardInputModel {
+  var identifier: Boardy.BoardID { get }
+  var option: Any? { get }
+}
+public struct BoardInput<Input> : Boardy.BoardInputModel {
+  public let identifier: Boardy.BoardID
+  public let input: Input
+  public var option: Any? {
     get
   }
+  public init(target: Boardy.BoardID, input: Input)
 }
-public protocol DedicatedBoard : Boardy.ActivatableBoard, Boardy.AdaptableBoard {
-  func activationBarrier(withInput input: Self.InputType?) -> Boardy.ActivationBarrier?
-  func activate(withInput input: Self.InputType?)
+extension Boardy.BoardInput {
+  public static func target<InputValue>(_ id: Boardy.BoardID, _ input: InputValue) -> Boardy.BoardInput<InputValue>
 }
-extension Boardy.DedicatedBoard {
-  public func activate(withOption option: Any?)
-  public func activationBarrier(withOption option: Any?) -> Boardy.ActivationBarrier?
-  public func activationBarrier(withInput _: Self.InputType?) -> Boardy.ActivationBarrier?
+extension Boardy.BoardInput where Input == () {
+  public init(target: Boardy.BoardID)
+  public static func target(_ id: Boardy.BoardID) -> Boardy.BoardInput<Swift.Void>
 }
-public protocol GuaranteedBoard : Boardy.ActivatableBoard, Boardy.AdaptableBoard {
-  func activationBarrier(withGuaranteedInput input: Self.InputType) -> Boardy.ActivationBarrier?
-  func activate(withGuaranteedInput input: Self.InputType)
-  var silentInputWhiteList: [(_ input: Any?) -> Swift.Bool] { get }
+extension Boardy.BoardInput where Input : Swift.ExpressibleByNilLiteral {
+  public init(target: Boardy.BoardID)
+  public static func target(_ id: Boardy.BoardID) -> Boardy.BoardInput<Input>
 }
-extension Boardy.GuaranteedBoard {
-  public var silentInputWhiteList: [(_ input: Any?) -> Swift.Bool] {
+extension Boardy.BoardID {
+  public func with<Input>(input: Input) -> Boardy.BoardInput<Input>
+  public var withoutInput: Boardy.BoardInput<Swift.Void> {
     get
   }
-  public func activate(withOption option: Any?)
-  public func activationBarrier(withOption option: Any?) -> Boardy.ActivationBarrier?
-  public func activationBarrier(withGuaranteedInput _: Self.InputType) -> Boardy.ActivationBarrier?
 }
-extension Boardy.GuaranteedBoard where Self.InputType : Swift.Decodable {
-  public var inputAdapters: [(Any?) -> Self.InputType?] {
+final public class ChainBoardFlow<Target> : Boardy.BoardFlow {
+  final public let identifier: Swift.String
+  public init(identifier: Swift.String = UUID().uuidString, manager: any Boardy.FlowManageable, target: Target, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool)
+  final public func handle<Output>(outputType _: Output.Type, handler: @escaping (Target, Output) -> Swift.Void) -> Self
+  @discardableResult
+  final public func eventuallyHandle<Output>(outputType _: Output.Type, handler: @escaping (Target, Output?) -> Swift.Void) -> any Boardy.FlowManageable
+  @discardableResult
+  final public func eventuallyHandle(skipSilentData: Swift.Bool = true, handler: @escaping (Target, Any?) -> Swift.Void) -> any Boardy.FlowManageable
+  @discardableResult
+  final public func eventuallySkipHandling() -> any Boardy.FlowManageable
+  final public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
+  final public func doNext(with output: any Boardy.BoardOutputModel)
+  @objc deinit
+}
+public protocol InstallableBoard : Boardy.OriginalBoard {
+  var rootViewController: UIKit.UIViewController { get }
+  func installIntoRootViewController(_ rootViewController: UIKit.UIViewController)
+}
+extension Boardy.InstallableBoard {
+  public var rootViewController: UIKit.UIViewController {
     get
   }
+  public func installIntoRootViewController(_ rootViewController: UIKit.UIViewController)
+  public var navigationController: UIKit.UINavigationController {
+    get
+  }
+  public var tabBarController: UIKit.UITabBarController {
+    get
+  }
 }
-public protocol GuaranteedOutputSendingBoard : Boardy.IdentifiableBoard {
-  associatedtype OutputType
+public protocol WindowInstallableBoard : Boardy.OriginalBoard {
+  var window: UIKit.UIWindow { get }
+  func installIntoWindow(_ window: UIKit.UIWindow)
 }
-extension Boardy.GuaranteedOutputSendingBoard {
-  public func sendOutput(_ data: Self.OutputType)
+extension Boardy.WindowInstallableBoard {
+  public var window: UIKit.UIWindow {
+    get
+  }
+  public func installIntoWindow(_ window: UIKit.UIWindow)
 }
-extension Boardy.GuaranteedOutputSendingBoard where Self.OutputType : Swift.Encodable {
-  public func sendEncodedOutput(_ data: Self.OutputType)
+extension Boardy.InstallableBoard where Self : Boardy.WindowInstallableBoard {
+  public var rootViewController: UIKit.UIViewController {
+    get
+  }
 }
-public protocol GuaranteedActionSendingBoard : Boardy.IdentifiableBoard {
-  associatedtype FlowActionType : Boardy.BoardFlowAction
-}
-extension Boardy.GuaranteedActionSendingBoard {
-  public func broadcastAction(_ action: Self.FlowActionType)
-}
 public protocol BoardFlowAction {
 }
 public enum BoardFlowNoneAction : Boardy.BoardFlowAction {
@@ -797,87 +351,79 @@
   public func forwardActionFlow(to board: any Boardy.IdentifiableBoard)
   public func forwardActivationFlow(to board: any Boardy.IdentifiableBoard)
 }
-extension Boardy.FlowManageable {
-  @discardableResult
-  public func registerFlow<Target, Output>(matchedIdentifiers: Boardy.FlowStepID..., target: Target, uniqueOutputType: Output.Type = Output.self, nextHandler: @escaping (Target, Output) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerFlow<Output>(matchedIdentifiers: Boardy.FlowStepID..., bindToBus bus: Boardy.Bus<Output>) -> Self
-  @discardableResult
-  public func registerFlow<Output, OutBoard>(matchedIdentifiers: Boardy.FlowStepID..., uniqueOutputType _: Output.Type = Output.self, sendOutputThrough board: OutBoard) -> Self where Output == OutBoard.OutputType, OutBoard : Boardy.GuaranteedOutputSendingBoard
-  @discardableResult
-  public func registerGuaranteedFlow<Target, Output>(matchedIdentifiers: Boardy.FlowStepID..., target: Target, uniqueOutputType: Output.Type = Output.self, handler: @escaping (Target, Output) -> Swift.Void) -> Self
-  @discardableResult
-  public func registerGuaranteedFlow<Output>(matchedIdentifiers: Boardy.FlowStepID..., bindToBus bus: Boardy.Bus<Output>) -> Self
-  @discardableResult
-  public func registerGuaranteedFlow<Output, OutBoard>(matchedIdentifiers: Boardy.FlowStepID..., uniqueOutputType _: Output.Type = Output.self, sendOutputThrough board: OutBoard) -> Self where Output == OutBoard.OutputType, OutBoard : Boardy.GuaranteedOutputSendingBoard
-  public func registerChainFlow<Target>(matchedIdentifiers: Boardy.FlowStepID..., target: Target) -> Boardy.ChainBoardFlow<Target>
-  @discardableResult
-  public func registerCompletionFlow(matchedIdentifiers: Boardy.FlowStepID..., nextHandler: @escaping (_ isDone: Swift.Bool) -> Swift.Void) -> Self
+public struct BoardActivateFlow : Boardy.BoardFlow {
+  public let identifier: Swift.String
+  public init(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, outputNextHandler: @escaping (any Boardy.BoardOutputModel) -> Swift.Void)
+  public init(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, nextHandler: @escaping (Any?) -> Swift.Void)
+  public init<Output>(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, dedicatedNextHandler: @escaping (Output?) -> Swift.Void)
+  public init<Output>(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool, guaranteedNextHandler: @escaping (Output) -> Swift.Void)
+  public init(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], outputNextHandler: @escaping (any Boardy.BoardOutputModel) -> Swift.Void)
+  public init(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], nextHandler: @escaping (Any?) -> Swift.Void)
+  public init<Output>(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], dedicatedNextHandler: @escaping (Output?) -> Swift.Void)
+  public init<Output>(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.FlowStepID], guaranteedNextHandler: @escaping (Output) -> Swift.Void)
+  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
+  public func doNext(with output: any Boardy.BoardOutputModel)
 }
-public protocol FlowingBoard : Boardy.ActivatableBoard, Boardy.InstallableBoard {
-  var motherboard: any Boardy.FlowManageable & Boardy.MotherboardType { get }
+public protocol AdaptableBoard {
+  associatedtype InputType
+  var inputAdapters: [(Any?) -> Self.InputType?] { get }
 }
-open class FlowBoard<Input, Output, Command, Action> : Boardy.ModernContinuableBoard, Boardy.GuaranteedBoard, Boardy.FlowingBoard, Boardy.GuaranteedOutputSendingBoard, Boardy.GuaranteedActionSendingBoard, Boardy.GuaranteedCommandBoard where Action : Boardy.BoardFlowAction {
-  public typealias InputType = Input
-  public typealias OutputType = Output
-  public typealias CommandType = Command
-  public typealias FlowActionType = Action
-  public typealias FlowRegistration = (Boardy.FlowBoard<Input, Output, Command, Action>) -> Swift.Void
-  public typealias FlowActivation = (Boardy.FlowBoard<Input, Output, Command, Action>, Boardy.FlowBoard<Input, Output, Command, Action>.InputType) -> Swift.Void
-  public typealias FlowInteraction = (Boardy.FlowBoard<Input, Output, Command, Action>, Boardy.FlowBoard<Input, Output, Command, Action>.CommandType) -> Swift.Void
-  public init(identifier: Boardy.BoardID, producer: any Boardy.ActivatableBoardProducer, allowBypassGatewayBarrier: Swift.Bool = true, flowRegistration: @escaping Boardy.FlowBoard<Input, Output, Command, Action>.FlowRegistration, flowActivation: @escaping Boardy.FlowBoard<Input, Output, Command, Action>.FlowActivation, flowInteraction: @escaping Boardy.FlowBoard<Input, Output, Command, Action>.FlowInteraction = { board, command in
-                        print("""
-                        ⚠️ The FlowBoard received an interaction command but missing a handler!
-                            🏝 [\(String(describing: type(of: board)))] ➤ \(board.identifier.rawValue)
-                            🚦 [\(String(describing: type(of: command)))] ➤ \(command)
-                        """)
-                        if let motherboard = board.delegate as? IdentifiableBoard {
-                            print("    🌏 [\(String(describing: type(of: motherboard)))] ➤ \(motherboard.identifier.rawValue)")
-                        }
-                })
-  open func activate(withGuaranteedInput input: Boardy.FlowBoard<Input, Output, Command, Action>.InputType)
-  open func interact(guaranteedCommand: Boardy.FlowBoard<Input, Output, Command, Action>.CommandType)
-  open func registerFlows()
-  open func shouldBypassGatewayBarrier() -> Swift.Bool
-  @objc deinit
-}
-@_hasMissingDesignatedInitializers final public class GatewayBarrierRegistration {
-  public static func registerWithActivation(_ activation: @escaping (_ barrier: any Boardy.Completable & Boardy.ContinuableBoard, _ option: Any?) -> Swift.Void) -> Boardy.GatewayBarrierRegistration
-  final public func withFlowRegistration(_ flowRegistration: @escaping (_ barrier: any Boardy.Completable & Boardy.ContinuableBoard) -> Swift.Void) -> Self
-  public static var ​exempt: Boardy.GatewayBarrierRegistration {
+extension Boardy.AdaptableBoard {
+  public func convertOptionToInput(_ option: Any?) -> Self.InputType?
+  public var inputAdapters: [(Any?) -> Self.InputType?] {
     get
   }
-  @objc deinit
 }
-public typealias GatewayBarrierBoard = Boardy.Completable & Boardy.ContinuableBoard
-public protocol InstallableBoard : Boardy.OriginalBoard {
-  var rootViewController: UIKit.UIViewController { get }
-  func installIntoRootViewController(_ rootViewController: UIKit.UIViewController)
+public protocol DedicatedBoard : Boardy.ActivatableBoard, Boardy.AdaptableBoard {
+  func activationBarrier(withInput input: Self.InputType?) -> Boardy.ActivationBarrier?
+  func activate(withInput input: Self.InputType?)
 }
-extension Boardy.InstallableBoard {
-  public var rootViewController: UIKit.UIViewController {
+extension Boardy.DedicatedBoard {
+  public func activate(withOption option: Any?)
+  public func activationBarrier(withOption option: Any?) -> Boardy.ActivationBarrier?
+  public func activationBarrier(withInput _: Self.InputType?) -> Boardy.ActivationBarrier?
+}
+public protocol GuaranteedBoard : Boardy.ActivatableBoard, Boardy.AdaptableBoard {
+  func activationBarrier(withGuaranteedInput input: Self.InputType) -> Boardy.ActivationBarrier?
+  func activate(withGuaranteedInput input: Self.InputType)
+  var silentInputWhiteList: [(_ input: Any?) -> Swift.Bool] { get }
+}
+extension Boardy.GuaranteedBoard {
+  public var silentInputWhiteList: [(_ input: Any?) -> Swift.Bool] {
     get
   }
-  public func installIntoRootViewController(_ rootViewController: UIKit.UIViewController)
-  public var navigationController: UIKit.UINavigationController {
+  public func activate(withOption option: Any?)
+  public func activationBarrier(withOption option: Any?) -> Boardy.ActivationBarrier?
+  public func activationBarrier(withGuaranteedInput _: Self.InputType) -> Boardy.ActivationBarrier?
+}
+extension Boardy.GuaranteedBoard where Self.InputType : Swift.Decodable {
+  public var inputAdapters: [(Any?) -> Self.InputType?] {
     get
   }
-  public var tabBarController: UIKit.UITabBarController {
-    get
-  }
 }
-public protocol WindowInstallableBoard : Boardy.OriginalBoard {
-  var window: UIKit.UIWindow { get }
-  func installIntoWindow(_ window: UIKit.UIWindow)
+public protocol GuaranteedOutputSendingBoard : Boardy.IdentifiableBoard {
+  associatedtype OutputType
 }
-extension Boardy.WindowInstallableBoard {
-  public var window: UIKit.UIWindow {
-    get
-  }
-  public func installIntoWindow(_ window: UIKit.UIWindow)
+extension Boardy.GuaranteedOutputSendingBoard {
+  public func sendOutput(_ data: Self.OutputType)
 }
-extension Boardy.InstallableBoard where Self : Boardy.WindowInstallableBoard {
-  public var rootViewController: UIKit.UIViewController {
+extension Boardy.GuaranteedOutputSendingBoard where Self.OutputType : Swift.Encodable {
+  public func sendEncodedOutput(_ data: Self.OutputType)
+}
+public protocol GuaranteedActionSendingBoard : Boardy.IdentifiableBoard {
+  associatedtype FlowActionType : Boardy.BoardFlowAction
+}
+extension Boardy.GuaranteedActionSendingBoard {
+  public func broadcastAction(_ action: Self.FlowActionType)
+}
+public typealias BoardConstructor = (Boardy.BoardID) -> any Boardy.ActivatableBoard
+public struct BoardRegistration : Swift.Hashable {
+  public init(_ identifier: Boardy.BoardID, constructor: @escaping (Boardy.BoardID) -> (any Boardy.ActivatableBoard)?)
+  public let identifier: Boardy.BoardID
+  public let constructor: (Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  public func hash(into hasher: inout Swift.Hasher)
+  public static func == (lhs: Boardy.BoardRegistration, rhs: Boardy.BoardRegistration) -> Swift.Bool
+  public var hashValue: Swift.Int {
     get
   }
 }
@@ -919,7 +465,186 @@
 extension Boardy.BoardCommand where Input : Swift.ExpressibleByNilLiteral {
   public init(identifier: Boardy.BoardID)
   public static func target(_ id: Boardy.BoardID) -> Boardy.BoardCommand<Input>
+}
+public protocol BoardFlow {
+  var identifier: Swift.String { get }
+  func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
+  func doNext(with output: any Boardy.BoardOutputModel)
+}
+public protocol IDMatchBoardFlow : Boardy.BoardFlow {
+  var matchedBoardIDs: [Boardy.BoardID] { get }
+}
+extension Boardy.IDMatchBoardFlow {
+  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
+}
+public protocol DataMatchBoardFlow : Boardy.BoardFlow {
+  associatedtype Output
+  func doNext(withData data: Self.Output)
+}
+extension Boardy.DataMatchBoardFlow {
+  public func doNext(with output: any Boardy.BoardOutputModel)
+}
+public protocol GuaranteedBoardFlow : Boardy.DataMatchBoardFlow, Boardy.IDMatchBoardFlow {
+}
+public struct IDGenericBoardFlow<Out> : Boardy.GuaranteedBoardFlow {
+  public typealias Output = Out
+  public let identifier: Swift.String
+  public let matchedBoardIDs: [Boardy.BoardID]
+  public init(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: [Boardy.BoardID], nextHandler: @escaping (Out) -> Swift.Void)
+  public init(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: Boardy.BoardID..., nextHandler: @escaping (Out) -> Swift.Void)
+  public init<HandlerTarget>(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: [Boardy.BoardID], target: HandlerTarget, nextHandler: @escaping (HandlerTarget, Out) -> Swift.Void)
+  public init<BoardType, HandlerTarget>(identifier: Swift.String = UUID().uuidString, matchedBoardID: Boardy.BoardID, of _: BoardType.Type, target: HandlerTarget, nextHandler: @escaping (HandlerTarget, BoardType.OutputType) -> Swift.Void) where Out == BoardType.OutputType, BoardType : Boardy.GuaranteedOutputSendingBoard
+  public init<BoardType>(identifier: Swift.String = UUID().uuidString, matchedBoardID: Boardy.BoardID, of _: BoardType.Type, nextHandler: @escaping (BoardType.OutputType) -> Swift.Void) where Out == BoardType.OutputType, BoardType : Boardy.GuaranteedOutputSendingBoard
+  public init<HandlerTarget>(identifier: Swift.String = UUID().uuidString, matchedBoardIDs: Boardy.BoardID..., target: HandlerTarget, nextHandler: @escaping (HandlerTarget, Out) -> Swift.Void)
+  public func doNext(withData data: Out)
 }
+public struct GenericBoardFlow<Out> : Boardy.DataMatchBoardFlow {
+  public typealias Output = Out
+  public var identifier: Swift.String
+  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
+  public func doNext(withData data: Out)
+  public init(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool = { _ in true }, nextHandler: @escaping (Out) -> Swift.Void)
+  public init<HandlerTarget>(identifier: Swift.String = UUID().uuidString, matcher: @escaping (any Boardy.BoardOutputModel) -> Swift.Bool = { _ in true }, target: HandlerTarget, nextHandler: @escaping (HandlerTarget, Out) -> Swift.Void)
+}
+public protocol ActivatableBoardProducer {
+  func produceBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  func produceGatewayBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  func matchBoard(withIdentifier identifier: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+}
+extension Boardy.ActivatableBoardProducer {
+  public func matchBoard(withIdentifier _: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  public func produceGatewayBoard(identifier _: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+}
+@available(*, deprecated, renamed: "ActivatableBoardProducer", message: "The protocol was renamed to ActivatableBoardProducer to fix typo")
+public typealias ActivableBoardProducer = Boardy.ActivatableBoardProducer
+public protocol BoardDelegate : AnyObject {
+  func board(_ board: any Boardy.IdentifiableBoard, didSendData data: Any?)
+}
+public protocol OriginalBoard {
+  var context: Swift.AnyObject? { get }
+  func putIntoContext(_ context: Swift.AnyObject)
+}
+public protocol IdentifiableBoard : AnyObject, Swift.CustomDebugStringConvertible {
+  var delegate: (any Boardy.BoardDelegate)? { get set }
+  var identifier: Boardy.BoardID { get }
+}
+extension Boardy.IdentifiableBoard {
+  public func sendToMotherboard(data: Any? = nil)
+  public func nextToBoard(model: any Boardy.BoardInputModel)
+  public func nextToBoard<Input>(_ input: Boardy.BoardInput<Input>)
+  public func sendFlowAction(_ action: any Boardy.BoardFlowAction)
+  public func interactWithOtherBoard(command: any Boardy.BoardCommandModel)
+  public func interactWithOtherBoard<Input>(_ input: Boardy.BoardCommand<Input>)
+  public func complete(_ isDone: Swift.Bool = true)
+  public var debugDescription: Swift.String {
+    get
+  }
+}
+public struct BoardID : Swift.LosslessStringConvertible, Swift.ExpressibleByStringLiteral, Swift.Hashable, Swift.RawRepresentable {
+  public typealias StringLiteralType = Swift.String
+  public let rawValue: Swift.String
+  public init(stringLiteral value: Boardy.BoardID.StringLiteralType)
+  public init(_ description: Swift.String)
+  public init(rawValue: Swift.String)
+  public var description: Swift.String {
+    get
+  }
+  public static func random() -> Boardy.BoardID
+  public typealias ExtendedGraphemeClusterLiteralType = Boardy.BoardID.StringLiteralType
+  public typealias RawValue = Swift.String
+  public typealias UnicodeScalarLiteralType = Boardy.BoardID.StringLiteralType
+}
+extension Boardy.BoardID : Swift.Equatable {
+  public static func == (lhs: Boardy.BoardID, rhs: Boardy.BoardID) -> Swift.Bool
+}
+public func ~= (pattern: Boardy.BoardID, value: Swift.String) -> Swift.Bool
+extension Boardy.BoardID {
+  public func appending(_ tail: Swift.String, separator: Swift.String = ".") -> Boardy.BoardID
+}
+public protocol MotherboardType : Boardy.IdentifiableBoard, Boardy.OriginalBoard {
+  var boards: [any Boardy.ActivatableBoard] { get }
+  func activateBoard(identifier: Boardy.BoardID, withOption option: Any?)
+  func addBoard(_ board: any Boardy.ActivatableBoard)
+  func removeBoard(withIdentifier identifier: Boardy.BoardID)
+  func getBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  func getGatewayBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+  func clearActiveBoards()
+}
+extension Boardy.MotherboardType {
+  public func removeBoard(_ board: any Boardy.ActivatableBoard)
+  public func installBoard(_ board: any Boardy.ActivatableBoard)
+  public func extended(boards: [any Boardy.ActivatableBoard]) -> Self
+  public func installedBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
+}
+extension Boardy.FlowManageable {
+  @discardableResult
+  public func registerFlow<Target, Output>(matchedIdentifiers: Boardy.FlowStepID..., target: Target, uniqueOutputType: Output.Type = Output.self, nextHandler: @escaping (Target, Output) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerFlow<Output>(matchedIdentifiers: Boardy.FlowStepID..., bindToBus bus: Boardy.Bus<Output>) -> Self
+  @discardableResult
+  public func registerFlow<Output, OutBoard>(matchedIdentifiers: Boardy.FlowStepID..., uniqueOutputType _: Output.Type = Output.self, sendOutputThrough board: OutBoard) -> Self where Output == OutBoard.OutputType, OutBoard : Boardy.GuaranteedOutputSendingBoard
+  @discardableResult
+  public func registerGuaranteedFlow<Target, Output>(matchedIdentifiers: Boardy.FlowStepID..., target: Target, uniqueOutputType: Output.Type = Output.self, handler: @escaping (Target, Output) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerGuaranteedFlow<Output>(matchedIdentifiers: Boardy.FlowStepID..., bindToBus bus: Boardy.Bus<Output>) -> Self
+  @discardableResult
+  public func registerGuaranteedFlow<Output, OutBoard>(matchedIdentifiers: Boardy.FlowStepID..., uniqueOutputType _: Output.Type = Output.self, sendOutputThrough board: OutBoard) -> Self where Output == OutBoard.OutputType, OutBoard : Boardy.GuaranteedOutputSendingBoard
+  public func registerChainFlow<Target>(matchedIdentifiers: Boardy.FlowStepID..., target: Target) -> Boardy.ChainBoardFlow<Target>
+  @discardableResult
+  public func registerCompletionFlow(matchedIdentifiers: Boardy.FlowStepID..., nextHandler: @escaping (_ isDone: Swift.Bool) -> Swift.Void) -> Self
+}
+extension Boardy.MotherboardType {
+  public func interactWithBoard(command: any Boardy.BoardCommandModel)
+  public func interactWithBoard<Input>(_ input: Boardy.BoardCommand<Input>)
+}
+public protocol ActivatableBoard : Boardy.BoardRegistrationsConvertible, Boardy.IdentifiableBoard, Boardy.OriginalBoard {
+  func activationBarrier(withOption option: Any?) -> Boardy.ActivationBarrier?
+  func activate(withOption option: Any?)
+  func shouldBypassGatewayBarrier() -> Swift.Bool
+}
+extension Boardy.ActivatableBoard {
+  public func asBoardRegistrations() -> [Boardy.BoardRegistration]
+  public func shouldBypassGatewayBarrier() -> Swift.Bool
+}
+extension Boardy.ActivatableBoard {
+  public func activate()
+  public func activationBarrier(withOption _: Any?) -> Boardy.ActivationBarrier?
+}
+public typealias NormalBoard = Boardy.ActivatableBoard & Boardy.InstallableBoard
+public struct ActivationBarrier {
+  public let identifier: Boardy.BoardID
+  public let scope: Boardy.ActivationBarrierScope
+  public let option: Boardy.ActivationBarrierOption
+}
+public enum ActivationBarrierScope {
+  case mainboard
+  case application
+  public static func == (a: Boardy.ActivationBarrierScope, b: Boardy.ActivationBarrierScope) -> Swift.Bool
+  public func hash(into hasher: inout Swift.Hasher)
+  public var hashValue: Swift.Int {
+    get
+  }
+}
+extension Boardy.ActivationBarrierScope {
+  @available(*, deprecated, renamed: "mainboard", message: "Use .mainboard instead")
+  public static var inMain: Boardy.ActivationBarrierScope {
+    get
+  }
+  @available(*, deprecated, renamed: "application", message: "Use .application instead")
+  public static var global: Boardy.ActivationBarrierScope {
+    get
+  }
+}
+public enum ActivationBarrierOption {
+  case void
+  case unique(Swift.AnyHashable)
+  case unidentified(Any?)
+}
+extension Boardy.ActivationBarrier {
+  public var barrierIdentifier: Boardy.BoardID {
+    get
+  }
+}
 public protocol Completable {
   func complete(_ isDone: Swift.Bool)
 }
@@ -1047,26 +772,85 @@
   public func interaction<Input>(_ destinationID: Boardy.BoardID, with _: Input.Type) -> Boardy.MainboardInteraction<Input>
   public func interaction(_ destinationID: Boardy.BoardID) -> Boardy.MainboardInteraction<Any?>
 }
-public struct BlockTaskBoardActivation<In, Out> : Boardy.BoardActivating {
-  public typealias Input = Boardy.BlockTaskParameter<In, Out>
-  public func activate(with input: Boardy.BlockTaskParameter<In, Out>)
-  public func activate(with input: In)
+public protocol OutputSpecifications {
+  var identifier: Boardy.BoardID { get }
+  func validateOutput(_ data: Any?) -> Swift.Bool
 }
-public struct BlockTaskMainboardActivation<In, Out> : Boardy.BoardActivating {
-  public typealias Input = Boardy.BlockTaskParameter<In, Out>
-  public func activate(with input: Boardy.BlockTaskMainboardActivation<In, Out>.Input)
-  public func activate(with input: In)
+public struct GeneralOutputSpecifications : Boardy.OutputSpecifications {
+  public init(identifier: Boardy.BoardID, validation: ((Any?) -> Swift.Bool)? = nil)
+  public let identifier: Boardy.BoardID
+  public let validation: (Any?) -> Swift.Bool
+  public func validateOutput(_ data: Any?) -> Swift.Bool
 }
-extension Boardy.ActivatableBoard {
-  public func blockActivation<Input, Output>(_ destinationID: Boardy.BoardID, with _: Boardy.BlockTaskParameter<Input, Output>.Type) -> Boardy.BlockTaskBoardActivation<Input, Output>
+public struct GuaranteedOutputSpecifications<Value> : Boardy.OutputSpecifications {
+  public init(identifier: Boardy.BoardID, valueType: Value.Type)
+  public let identifier: Boardy.BoardID
+  public let valueType: Value.Type
+  public func validateOutput(_ data: Any?) -> Swift.Bool
 }
-extension Boardy.MotherboardType {
-  public func blockActivation<Input, Output>(_ destinationID: Boardy.BoardID, with _: Boardy.BlockTaskParameter<Input, Output>.Type) -> Boardy.BlockTaskMainboardActivation<Input, Output>
-}
-extension Boardy.MainboardGenericDestination {
-  final public var blockActivation: Boardy.BlockTaskMainboardActivation<Input, Output> {
+public class OutputCombinedFlow : Boardy.BoardFlow {
+  public enum Strategy {
+    case batchOneByOne
+    case latestForever
+    public static func == (a: Boardy.OutputCombinedFlow.Strategy, b: Boardy.OutputCombinedFlow.Strategy) -> Swift.Bool
+    public func hash(into hasher: inout Swift.Hasher)
+    public var hashValue: Swift.Int {
+      get
+    }
+  }
+  final public let identifier: Swift.String
+  final public let specifications: [any Boardy.OutputSpecifications]
+  final public let strategy: Boardy.OutputCombinedFlow.Strategy
+  public var matchedIdentifiers: [Boardy.BoardID] {
     get
   }
+  public init(identifier: Swift.String = UUID().uuidString, matchedIdentifiers: [Boardy.BoardID], strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, handler: @escaping ([Any]) -> Swift.Void)
+  public init(identifier: Swift.String = UUID().uuidString, specifications: [any Boardy.OutputSpecifications], strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping ([Any]) -> Swift.Void)
+  public func match(with output: any Boardy.BoardOutputModel) -> Swift.Bool
+  public func doNext(with output: any Boardy.BoardOutputModel)
+  @objc deinit
+}
+public class OutputCombinedCollectionFlow<Value> : Boardy.OutputCombinedFlow {
+  public init(identifier: Swift.String = UUID().uuidString, specs: [Boardy.GuaranteedOutputSpecifications<Value>], strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping ([Value]) -> Swift.Void)
+  @objc deinit
+}
+public class OutputCombined2Flow<V1, V2> : Boardy.OutputCombinedFlow {
+  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2) -> Swift.Void)
+  @objc deinit
+}
+public class OutputCombined3Flow<V1, V2, V3> : Boardy.OutputCombinedFlow {
+  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, spec3: Boardy.GuaranteedOutputSpecifications<V3>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2, V3) -> Swift.Void)
+  @objc deinit
+}
+public class OutputCombined4Flow<V1, V2, V3, V4> : Boardy.OutputCombinedFlow {
+  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, spec3: Boardy.GuaranteedOutputSpecifications<V3>, spec4: Boardy.GuaranteedOutputSpecifications<V4>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2, V3, V4) -> Swift.Void)
+  @objc deinit
+}
+public class OutputCombined5Flow<V1, V2, V3, V4, V5> : Boardy.OutputCombinedFlow {
+  public init(identifier: Swift.String = UUID().uuidString, spec1: Boardy.GuaranteedOutputSpecifications<V1>, spec2: Boardy.GuaranteedOutputSpecifications<V2>, spec3: Boardy.GuaranteedOutputSpecifications<V3>, spec4: Boardy.GuaranteedOutputSpecifications<V4>, spec5: Boardy.GuaranteedOutputSpecifications<V5>, strategy: Boardy.OutputCombinedFlow.Strategy, handler: @escaping (V1, V2, V3, V4, V5) -> Swift.Void)
+  @objc deinit
+}
+extension Boardy.FlowManageable {
+  @discardableResult
+  public func registerCombinedFlow<Output>(_ specs: [Boardy.GuaranteedOutputSpecifications<Output>], strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping ([Output]) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<Target, Output>(_ specs: [Boardy.GuaranteedOutputSpecifications<Output>], strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, [Output]) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<O1, O2>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<Target, O1, O2>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<O1, O2, O3>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2, O3) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<Target, O1, O2, O3>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2, O3) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<O1, O2, O3, O4>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2, O3, O4) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<Target, O1, O2, O3, O4>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2, O3, O4) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<O1, O2, O3, O4, O5>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, _ outputSpecifications5: Boardy.GuaranteedOutputSpecifications<O5>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, nextHandler: @escaping (O1, O2, O3, O4, O5) -> Swift.Void) -> Self
+  @discardableResult
+  public func registerCombinedFlow<Target, O1, O2, O3, O4, O5>(_ outputSpecifications1: Boardy.GuaranteedOutputSpecifications<O1>, _ outputSpecifications2: Boardy.GuaranteedOutputSpecifications<O2>, _ outputSpecifications3: Boardy.GuaranteedOutputSpecifications<O3>, _ outputSpecifications4: Boardy.GuaranteedOutputSpecifications<O4>, _ outputSpecifications5: Boardy.GuaranteedOutputSpecifications<O5>, strategy: Boardy.OutputCombinedFlow.Strategy = .batchOneByOne, target: Target, action: @escaping (Target, O1, O2, O3, O4, O5) -> Swift.Void) -> Self
 }
 public class MainboardDestination {
   public init(destinationID: Boardy.BoardID, mainboard: any Boardy.FlowManageable & Boardy.MotherboardType)
@@ -1129,15 +913,25 @@
     get
   }
 }
-public protocol LauncherPlugin {
-  func prepareForLaunching(withOptions options: Boardy.MainOptions) -> Boardy.ModuleComponent
+extension Boardy.IdentifiableBoard {
+  public func putToComposer(elementAction: UIComposable.UIElementAction)
 }
-public struct ModuleComponent {
-  public init(modulePlugins: [any Boardy.ModulePlugin], urlOpenerPlugins: [any Boardy.URLOpenerPlugin] = [], launchSettings: @escaping (_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void = { _ in })
-  public let modulePlugins: [any Boardy.ModulePlugin]
-  public let urlOpenerPlugins: [any Boardy.URLOpenerPlugin]
-  public let launchSettings: (_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void
+extension UIComposable.UIElement {
+  public init(identifier: Boardy.BoardID, contentViewController: UIKit.UIViewController?, configuration: Any? = nil)
 }
+extension Boardy.ActivatableBoardProducer {
+  public func produceComposableMotherboard(identifier: Boardy.BoardID, from parent: (any Boardy.IdentifiableBoard)? = nil, elementsBuilder: (any Boardy.ActivatableBoardProducer) -> [any Boardy.ActivatableBoard] = { _ in [] }) -> any Boardy.ComposableMotherboardType & Boardy.FlowManageable
+}
+public protocol ComposableMotherboardType : Boardy.MotherboardType {
+  func connect(to interface: any UIComposable.ComposableInterface)
+}
+public typealias FlowComposableMotherboard = Boardy.ComposableMotherboardType & Boardy.FlowManageable
+@_inheritsConvenienceInitializers open class ComposableMotherboard : Boardy.Motherboard, Boardy.ComposableMotherboardType {
+  public func connect(to interface: any UIComposable.ComposableInterface)
+  override public init(identifier: Boardy.BoardID = super, boards: [any Boardy.ActivatableBoard] = super)
+  override public init(identifier: Boardy.BoardID = super, boardProducer: any Boardy.ActivatableBoardProducer)
+  @objc deinit
+}
 extension Boardy.ModernContinuableBoard {
   @discardableResult
   public func mountComposableMotherboard(to interface: any UIComposable.ComposableInterface & Swift.AnyObject, configurationBuilder: (any Boardy.ComposableMotherboardType & Boardy.FlowManageable) -> Swift.Void = { _ in }) -> any Boardy.ComposableMotherboardType & Boardy.FlowManageable
@@ -1149,7 +943,287 @@
   public func attachComposableMotherboard(to interface: any Boardy.AttachableObject & UIComposable.ComposableInterface, configurationBuilder: (any Boardy.ComposableMotherboardType & Boardy.FlowManageable) -> Swift.Void = { _ in }) -> any Boardy.ComposableMotherboardType & Boardy.FlowManageable
   @discardableResult
   public func attachComposableMotherboard<Mainboard>(to interface: any Boardy.AttachableObject & UIComposable.ComposableInterface, build: (any Boardy.ActivatableBoardProducer) -> Mainboard) -> Mainboard where Mainboard : Boardy.ComposableMotherboardType, Mainboard : Boardy.FlowManageable
+}
+extension Boardy.MotherboardType {
+  public func activateAllBoards(withOptions options: [Boardy.BoardID : Any] = [:], defaultOption: Any? = nil)
+  public func activateAllBoards(models: [any Boardy.BoardInputModel], defaultOption: Any? = nil)
+  public func activateAllBoards<Input>(withInputs inputs: [Boardy.BoardInput<Input>] = [], defaultInput: Input)
+  public func activateAllBoards<Input>(withInputs inputs: [Boardy.BoardInput<Input>])
+}
+final public class BlockTaskParameter<Input, Output> {
+  public init(input: Input)
+  final public func onSuccess(_ handler: Boardy.BlockTaskParameter<Input, Output>.SuccessHandler?) -> Self
+  final public func onSuccess(_ handler: ((Output) -> Swift.Void)?) -> Self
+  final public func onSuccess<Target>(target: Target, action: ((Target, Output) -> Swift.Void)?) -> Self
+  final public func onProcessing(_ handler: Boardy.BlockTaskParameter<Input, Output>.ProcessingHandler?) -> Self
+  final public func onProcessing(_ handler: ((Swift.Bool) -> Swift.Void)?) -> Self
+  final public func onProcessing<Target>(target: Target, action: ((Target, Swift.Bool) -> Swift.Void)?) -> Self
+  final public func onError(_ handler: Boardy.BlockTaskParameter<Input, Output>.ErrorHandler?) -> Self
+  final public func onError(_ handler: ((any Swift.Error) -> Swift.Void)?) -> Self
+  final public func onError<Target>(target: Target, action: ((Target, any Swift.Error) -> Swift.Void)?) -> Self
+  final public func onCompletion(_ handler: Boardy.BlockTaskParameter<Input, Output>.CompletionHandler?) -> Self
+  final public func onCompletion(_ handler: ((Boardy.TaskCompletionStatus) -> Swift.Void)?) -> Self
+  final public func onCompletion<Target>(target: Target, action: ((Target, Boardy.TaskCompletionStatus) -> Swift.Void)?) -> Self
+  final public let input: Input
+  final public var successHandler: Boardy.BlockTaskParameter<Input, Output>.SuccessHandler? {
+    get
+  }
+  final public var processingHandler: Boardy.BlockTaskParameter<Input, Output>.ProcessingHandler? {
+    get
+  }
+  final public var errorHandler: Boardy.BlockTaskParameter<Input, Output>.ErrorHandler? {
+    get
+  }
+  final public var completionHandler: Boardy.BlockTaskParameter<Input, Output>.CompletionHandler? {
+    get
+  }
+  public typealias SuccessHandler = (any Boardy.ActivatableBoard, Output) -> Swift.Void
+  public typealias ProcessingHandler = (any Boardy.ActivatableBoard, Swift.Bool) -> Swift.Void
+  public typealias ErrorHandler = (any Boardy.ActivatableBoard, any Swift.Error) -> Swift.Void
+  public typealias CompletionHandler = (any Boardy.ActivatableBoard, Boardy.TaskCompletionStatus) -> Swift.Void
+  @objc deinit
+}
+extension Boardy.BlockTaskParameter {
+  final public func appendingSuccessHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.SuccessHandler) -> Self
+  final public func appendingErrorHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.ErrorHandler) -> Self
+  final public func appendingCompletionHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.CompletionHandler) -> Self
+  final public func appendingProcessingHandler(_ handler: @escaping Boardy.BlockTaskParameter<Input, Output>.ProcessingHandler) -> Self
+}
+public enum TaskCompletionStatus {
+  case done
+  case cancelled
+  public static func == (a: Boardy.TaskCompletionStatus, b: Boardy.TaskCompletionStatus) -> Swift.Bool
+  public func hash(into hasher: inout Swift.Hasher)
+  public var hashValue: Swift.Int {
+    get
+  }
+}
+extension Boardy.BlockTaskParameter where Input : Swift.ExpressibleByNilLiteral {
+  convenience public init()
+}
+extension Boardy.BlockTaskParameter where Input == () {
+  convenience public init()
+}
+extension Boardy.BlockTaskBoard {
+  convenience public init(identifier: Boardy.BoardID, executingType: Boardy.ExecutingType = .default, execute work: @escaping (Boardy.BlockTaskBoard<Input, Output>, Input, @escaping Boardy.BlockTaskBoard<Input, Output>.ExecutorCompletion) -> Swift.Void)
+}
+public enum ExecutingType {
+  case `default`
+  case latest
+  case only
+  case onlyResult
+  case queue
+  case concurrent(max: Swift.Int)
+  public static var concurrent: Boardy.ExecutingType {
+    get
+  }
+}
+final public class BlockTaskBoard<Input, Output> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard {
+  public typealias InputType = Boardy.BlockTaskParameter<Input, Output>
+  public typealias OutputType = Output
+  public typealias ExecutorCompletion = (Swift.Result<Output, any Swift.Error>) -> Swift.Void
+  public typealias Executor = (Boardy.BlockTaskBoard<Input, Output>, Input, @escaping Boardy.BlockTaskBoard<Input, Output>.ExecutorCompletion) -> Boardy.BlockTaskCanceler
+  public init(identifier: Boardy.BoardID, executingType: Boardy.ExecutingType, allowBypassGatewayBarrier: Swift.Bool = true, executor: @escaping Boardy.BlockTaskBoard<Input, Output>.Executor)
+  @objc deinit
+  final public var inputAdapters: [(Any?) -> Boardy.BlockTaskParameter<Input, Output>?] {
+    get
+  }
+  final public func shouldBypassGatewayBarrier() -> Swift.Bool
+  final public func activate(withGuaranteedInput input: Boardy.BlockTaskBoard<Input, Output>.InputType)
+}
+extension Boardy.BlockTaskCanceler {
+  public static var none: Boardy.BlockTaskCanceler {
+    get
+  }
+  public static func `default`(handler: @escaping () -> Swift.Void) -> Boardy.BlockTaskCanceler
+}
+public struct BlockTaskCanceler {
+  public init(handler: @escaping () -> Swift.Void)
+  public func cancel()
+}
+public protocol FlowingBoard : Boardy.ActivatableBoard, Boardy.InstallableBoard {
+  var motherboard: any Boardy.FlowManageable & Boardy.MotherboardType { get }
+}
+open class FlowBoard<Input, Output, Command, Action> : Boardy.ModernContinuableBoard, Boardy.GuaranteedBoard, Boardy.FlowingBoard, Boardy.GuaranteedOutputSendingBoard, Boardy.GuaranteedActionSendingBoard, Boardy.GuaranteedCommandBoard where Action : Boardy.BoardFlowAction {
+  public typealias InputType = Input
+  public typealias OutputType = Output
+  public typealias CommandType = Command
+  public typealias FlowActionType = Action
+  public typealias FlowRegistration = (Boardy.FlowBoard<Input, Output, Command, Action>) -> Swift.Void
+  public typealias FlowActivation = (Boardy.FlowBoard<Input, Output, Command, Action>, Boardy.FlowBoard<Input, Output, Command, Action>.InputType) -> Swift.Void
+  public typealias FlowInteraction = (Boardy.FlowBoard<Input, Output, Command, Action>, Boardy.FlowBoard<Input, Output, Command, Action>.CommandType) -> Swift.Void
+  public init(identifier: Boardy.BoardID, producer: any Boardy.ActivatableBoardProducer, allowBypassGatewayBarrier: Swift.Bool = true, flowRegistration: @escaping Boardy.FlowBoard<Input, Output, Command, Action>.FlowRegistration, flowActivation: @escaping Boardy.FlowBoard<Input, Output, Command, Action>.FlowActivation, flowInteraction: @escaping Boardy.FlowBoard<Input, Output, Command, Action>.FlowInteraction = { board, command in
+                })
+  open func activate(withGuaranteedInput input: Boardy.FlowBoard<Input, Output, Command, Action>.InputType)
+  open func interact(guaranteedCommand: Boardy.FlowBoard<Input, Output, Command, Action>.CommandType)
+  open func registerFlows()
+  open func shouldBypassGatewayBarrier() -> Swift.Bool
+  @objc deinit
+}
+final public class AdapterBoard<Destination, In, Out> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard, Boardy.InteractableBoard, Boardy.BoardDelegate where Destination : Boardy.GuaranteedBoard, Destination : Boardy.GuaranteedOutputSendingBoard {
+  public typealias InputType = In
+  public typealias OutputType = Out
+  final public let destination: Destination
+  public init(destination: Destination, inputMapper: @escaping (In) -> Destination.InputType, outputMapper: @escaping (Destination.OutputType) -> Out)
+  final public func setInputMapper(_ mapper: @escaping (In) -> Destination.InputType) -> Self
+  final public func setOutputMapper(_ mapper: @escaping (Destination.OutputType) -> Out) -> Self
+  final public func activationBarrier(withGuaranteedInput input: In) -> Boardy.ActivationBarrier?
+  final public func activate(withGuaranteedInput input: Boardy.AdapterBoard<Destination, In, Out>.InputType)
+  final public func interact(command: Any?)
+  final public func board(_: any Boardy.IdentifiableBoard, didSendData data: Any?)
+  final public func shouldBypassGatewayBarrier() -> Swift.Bool
+  @objc deinit
+}
+extension Boardy.AdapterBoard where In == Destination.InputType {
+  convenience public init(destination: Destination, outputMapper: @escaping (Destination.OutputType) -> Out)
+}
+extension Boardy.AdapterBoard where Out == Destination.OutputType {
+  convenience public init(destination: Destination, inputMapper: @escaping (In) -> Destination.InputType)
+}
+extension Boardy.AdapterBoard where In == Destination.InputType, Out == Destination.OutputType {
+  convenience public init(destination: Destination)
+}
+public struct BlockTaskBoardActivation<In, Out> : Boardy.BoardActivating {
+  public typealias Input = Boardy.BlockTaskParameter<In, Out>
+  public func activate(with input: Boardy.BlockTaskParameter<In, Out>)
+  public func activate(with input: In)
+}
+public struct BlockTaskMainboardActivation<In, Out> : Boardy.BoardActivating {
+  public typealias Input = Boardy.BlockTaskParameter<In, Out>
+  public func activate(with input: Boardy.BlockTaskMainboardActivation<In, Out>.Input)
+  public func activate(with input: In)
+}
+extension Boardy.ActivatableBoard {
+  public func blockActivation<Input, Output>(_ destinationID: Boardy.BoardID, with _: Boardy.BlockTaskParameter<Input, Output>.Type) -> Boardy.BlockTaskBoardActivation<Input, Output>
+}
+extension Boardy.MotherboardType {
+  public func blockActivation<Input, Output>(_ destinationID: Boardy.BoardID, with _: Boardy.BlockTaskParameter<Input, Output>.Type) -> Boardy.BlockTaskMainboardActivation<Input, Output>
+}
+extension Boardy.MainboardGenericDestination {
+  final public var blockActivation: Boardy.BlockTaskMainboardActivation<Input, Output> {
+    get
+  }
+}
+public protocol TaskingBoard : Boardy.ActivatableBoard, Boardy.InstallableBoard {
+  var isCompleted: Swift.Bool { get }
+  var isProcessing: Swift.Bool { get }
+}
+open class TaskBoard<Input, Output> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.TaskingBoard, Boardy.GuaranteedOutputSendingBoard {
+  public typealias ExecutorCompletion = (Swift.Result<Output, any Swift.Error>) -> Swift.Void
+  public typealias Executor = (any Boardy.TaskingBoard, Input, @escaping Boardy.TaskBoard<Input, Output>.ExecutorCompletion) -> Swift.Void
+  public typealias SuccessHandler = (Boardy.TaskBoard<Input, Output>, Output) -> Swift.Void
+  public typealias ProcessingHandler = (Boardy.TaskBoard<Input, Output>) -> Swift.Void
+  public typealias ErrorHandler = (Boardy.TaskBoard<Input, Output>, any Swift.Error) -> Swift.Void
+  public typealias CompletionHandler = (Boardy.TaskBoard<Input, Output>) -> Swift.Void
+  public typealias InputType = Input
+  public typealias OutputType = Output
+  public var isCompleted: Swift.Bool {
+    get
+  }
+  public var isProcessing: Swift.Bool {
+    get
+  }
+  public init(identifier: Boardy.BoardID, allowBypassGatewayBarrier: Swift.Bool = true, executor: @escaping Boardy.TaskBoard<Input, Output>.Executor, successHandler: @escaping Boardy.TaskBoard<Input, Output>.SuccessHandler = { _, _ in }, processingHandler: @escaping Boardy.TaskBoard<Input, Output>.ProcessingHandler = { _ in }, errorHandler: @escaping Boardy.TaskBoard<Input, Output>.ErrorHandler = { board, error in
+                    guard board.context != nil else { return }
+
+
+                    var topViewController = board.rootViewController
+                    while let viewController = topViewController.presentedViewController {
+                        topViewController = viewController
+                    }
+
+                    DispatchQueue.main.async { [weak topViewController] in
+                        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
+                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
+                        topViewController?.present(alert, animated: true)
+                    }
+                }, completionHandler: @escaping Boardy.TaskBoard<Input, Output>.CompletionHandler = { _ in })
+  public func shouldBypassGatewayBarrier() -> Swift.Bool
+  public func activate(withGuaranteedInput input: Input)
+  @objc deinit
+  open func handleSuccess(_ output: Output)
+  open func handleProgress()
+  open func handleError(_ error: any Swift.Error)
+  open func willComplete()
 }
+public enum BoardResult<Success, Failure> {
+  case progress(fractionCompleted: Swift.Double)
+  case success(Success)
+  case failure(Failure)
+  case cancel
+  public static var progress: Boardy.BoardResult<Success, Failure> {
+    get
+  }
+  public var inProgress: Swift.Bool {
+    get
+  }
+}
+final public class ResultTaskBoard<Input, Success, Failure> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard {
+  public typealias InputType = Input
+  public typealias OutputType = Boardy.BoardResult<Success, Failure>
+  public typealias ExecutorCallback = (Boardy.BoardResult<Success, Failure>) -> Swift.Void
+  public typealias Executor = (Input, @escaping Boardy.ResultTaskBoard<Input, Success, Failure>.ExecutorCallback) -> Swift.Void
+  public init(identifier: Boardy.BoardID, allowBypassGatewayBarrier: Swift.Bool = true, executor: @escaping Boardy.ResultTaskBoard<Input, Success, Failure>.Executor)
+  final public func shouldBypassGatewayBarrier() -> Swift.Bool
+  final public func activate(withGuaranteedInput input: Input)
+  @objc deinit
+}
+public struct AlertAction {
+  public init(title: Swift.String, style: Boardy.AlertAction.Style = .default, shouldBePreferred: Swift.Bool = false, handler: (() -> Swift.Void)?)
+  public init<Target>(title: Swift.String, style: Boardy.AlertAction.Style = .default, shouldBePreferred: Swift.Bool = false, target: Target, handler: ((Target) -> Swift.Void)?) where Target : AnyObject
+  public enum Style {
+    case `default`
+    case cancel
+    case destructive
+    public static func == (a: Boardy.AlertAction.Style, b: Boardy.AlertAction.Style) -> Swift.Bool
+    public func hash(into hasher: inout Swift.Hasher)
+    public var hashValue: Swift.Int {
+      get
+    }
+  }
+}
+public struct Alert {
+  public init(title: Swift.String? = nil, message: Swift.String?, style: Boardy.Alert.Style = .alert, actions: [Boardy.AlertAction])
+  public enum Style {
+    case alert
+    case actionSheet
+    public static func == (a: Boardy.Alert.Style, b: Boardy.Alert.Style) -> Swift.Bool
+    public func hash(into hasher: inout Swift.Hasher)
+    public var hashValue: Swift.Int {
+      get
+    }
+  }
+}
+extension Boardy.MotherboardType {
+  public func activateAlert(_ alert: Boardy.Alert)
+}
+@_inheritsConvenienceInitializers final public class BarrierBoard<Input> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard {
+  public typealias InputType = Boardy.BarrierBoard<Input>.Action
+  public typealias OutputType = Input
+  public typealias Process = (Input) -> Swift.Void
+  public enum Action {
+    case wait(Boardy.BarrierBoard<Input>.Process)
+    case overcome(Boardy.BarrierBoard<Input>.OutputType)
+    case cancel
+  }
+  final public func activate(withGuaranteedInput input: Boardy.BarrierBoard<Input>.InputType)
+  final public func shouldBypassGatewayBarrier() -> Swift.Bool
+  override public init(identifier: Boardy.BoardID)
+  @objc deinit
+}
+@_hasMissingDesignatedInitializers final public class GatewayBarrierRegistration {
+  public static func registerWithActivation(_ activation: @escaping (_ barrier: any Boardy.Completable & Boardy.ContinuableBoard, _ option: Any?) -> Swift.Void) -> Boardy.GatewayBarrierRegistration
+  final public func withFlowRegistration(_ flowRegistration: @escaping (_ barrier: any Boardy.Completable & Boardy.ContinuableBoard) -> Swift.Void) -> Self
+  public static var exempt: Boardy.GatewayBarrierRegistration {
+    get
+  }
+  @available(*, deprecated, renamed: "exempt")
+  public static var ​exempt: Boardy.GatewayBarrierRegistration {
+    get
+  }
+  @objc deinit
+}
+public typealias GatewayBarrierBoard = Boardy.Completable & Boardy.ContinuableBoard
 extension Boardy.MainOptions.Key {
   public static let environment: Boardy.MainOptions.Key
 }
@@ -1211,6 +1285,77 @@
   public func apply(for main: any Boardy.MainComponent)
   public func pluginDidLoad(with _: any Boardy.SharedValueComponent)
 }
+public protocol URLOpenerPlugin : Boardy.URLOpenerPluginConvertible {
+  var name: Swift.String { get }
+  func canOpenURL(_ url: Foundation.URL) -> Swift.Bool
+  func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, open url: Foundation.URL)
+}
+extension Boardy.URLOpenerPlugin {
+  public var name: Swift.String {
+    get
+  }
+}
+public protocol URLOpenerPluginConvertible {
+  var urlOpenerPlugins: [any Boardy.URLOpenerPlugin] { get }
+}
+extension Boardy.URLOpenerPlugin {
+  public var urlOpenerPlugins: [any Boardy.URLOpenerPlugin] {
+    get
+  }
+}
+public protocol URLOpenerPathMatchingPlugin : Boardy.URLOpenerPlugin {
+  var matchingPath: Swift.String { get }
+  func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openURLWithParameters parameters: [Swift.String : Swift.String])
+}
+extension Boardy.URLOpenerPathMatchingPlugin {
+  public func canOpenURL(_ url: Foundation.URL) -> Swift.Bool
+  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, open url: Foundation.URL)
+}
+public struct BlockURLOpenerPathMatchingPlugin : Boardy.URLOpenerPathMatchingPlugin {
+  public init(name: Swift.String? = nil, matchingPath: Swift.String, handler: @escaping (any Boardy.FlowManageable & Boardy.MotherboardType, [Swift.String : Swift.String]) -> Swift.Void)
+  public let matchingPath: Swift.String
+  public var name: Swift.String {
+    get
+  }
+  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openURLWithParameters parameters: [Swift.String : Swift.String])
+}
+public enum URLOpeningOption<Parameter> {
+  case yes(Parameter)
+  case no
+}
+public protocol GuaranteedURLOpenerPlugin : Boardy.URLOpenerPlugin {
+  associatedtype Parameter
+  func willOpen(url: Foundation.URL) -> Boardy.URLOpeningOption<Self.Parameter>
+  func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openWith parameter: Self.Parameter)
+}
+extension Boardy.GuaranteedURLOpenerPlugin {
+  public func canOpenURL(_ url: Foundation.URL) -> Swift.Bool
+  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, open url: Foundation.URL)
+}
+public struct BlockURLOpenerPlugin<Parameter> : Boardy.GuaranteedURLOpenerPlugin {
+  public var name: Swift.String {
+    get
+  }
+  public init(name: Swift.String? = nil, condition: @escaping (Foundation.URL) -> Boardy.URLOpeningOption<Parameter>, handler: @escaping (any Boardy.FlowManageable & Boardy.MotherboardType, Parameter) -> Swift.Void)
+  public func willOpen(url: Foundation.URL) -> Boardy.URLOpeningOption<Parameter>
+  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openWith parameter: Parameter)
+}
+extension Swift.Array : Boardy.URLOpenerPluginConvertible where Element == any Boardy.URLOpenerPlugin {
+  public var urlOpenerPlugins: [any Boardy.URLOpenerPlugin] {
+    get
+  }
+}
+@_functionBuilder public enum URLOpenerPluginBuilder {
+  public static func buildBlock(_ components: any Boardy.URLOpenerPluginConvertible...) -> [any Boardy.URLOpenerPlugin]
+  public static func buildArray(_ components: [any Boardy.URLOpenerPluginConvertible]) -> [any Boardy.URLOpenerPlugin]
+  public static func buildEither(first component: any Boardy.URLOpenerPluginConvertible) -> any Boardy.URLOpenerPluginConvertible
+  public static func buildEither(second component: any Boardy.URLOpenerPluginConvertible) -> any Boardy.URLOpenerPluginConvertible
+  public static func buildOptional(_ component: (any Boardy.URLOpenerPluginConvertible)?) -> any Boardy.URLOpenerPluginConvertible
+  public static func buildExpression(_ expression: (any Boardy.URLOpenerPluginConvertible)?) -> any Boardy.URLOpenerPluginConvertible
+}
+extension Boardy.PluginLauncher {
+  final public func install(@Boardy.URLOpenerPluginBuilder urlOpenerPluginsBuilder: () -> [any Boardy.URLOpenerPlugin]) -> Self
+}
 extension Swift.Array : Boardy.ModulePluginConvertible where Element == any Boardy.ModulePlugin {
   public var modulePlugins: [any Boardy.ModulePlugin] {
     get
@@ -1227,68 +1372,27 @@
 extension Boardy.LauncherComponent {
   final public func install(@Boardy.ModulePluginBuilder pluginsBuilder: () -> [any Boardy.ModulePlugin]) -> Self
 }
-open class Motherboard : Boardy.Board, Boardy.BoardDelegate, Boardy.FlowMotherboard {
-  public var flows: [any Boardy.BoardFlow]
-  override public var debugDescription: Swift.String {
+open class ServiceMap {
+  final public let mainboard: any Boardy.FlowManageable & Boardy.MotherboardType
+  required public init(mainboard: any Boardy.FlowManageable & Boardy.MotherboardType)
+  @objc deinit
+}
+extension Boardy.MotherboardType where Self : Boardy.FlowManageable {
+  public var serviceMap: Boardy.ServiceMap {
     get
   }
-  public init(identifier: Boardy.BoardID = .random(), boards: [any Boardy.ActivatableBoard] = [])
-  public init(identifier: Boardy.BoardID = .random(), boardProducer: any Boardy.ActivatableBoardProducer)
-  convenience public init(identifier: Boardy.BoardID = .random(), boardProducer: any Boardy.ActivatableBoardProducer, boards: [any Boardy.ActivatableBoard])
-  override open func putIntoContext(_ context: Swift.AnyObject)
-  @discardableResult
-  public func registerFlow(_ flow: any Boardy.BoardFlow) -> Self
-  public func resetFlows()
-  public func removeFlow(by identifier: Swift.String)
-  public var boardProducer: any Boardy.ActivatableBoardProducer {
+}
+extension Boardy.IdentifiableBoard {
+  public var serviceMap: Boardy.ServiceMap {
     get
   }
-  @objc deinit
 }
-public protocol MotherboardType : Boardy.IdentifiableBoard, Boardy.OriginalBoard {
-  var boards: [any Boardy.ActivatableBoard] { get }
-  func activateBoard(identifier: Boardy.BoardID, withOption option: Any?)
-  func addBoard(_ board: any Boardy.ActivatableBoard)
-  func removeBoard(withIdentifier identifier: Boardy.BoardID)
-  func getBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  func getGatewayBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  func clearActiveBoards()
+extension Boardy.ServiceMap {
+  public func link<MapType>(_: MapType.Type = MapType.self) -> MapType where MapType : Boardy.ServiceMap
 }
-extension Boardy.MotherboardType {
-  public func removeBoard(_ board: any Boardy.ActivatableBoard)
-  public func installBoard(_ board: any Boardy.ActivatableBoard)
-  public func extended(boards: [any Boardy.ActivatableBoard]) -> Self
-  public func installedBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-}
-extension Boardy.MotherboardType {
-  public func activateBoard(identifier: Boardy.BoardID, withOption option: Any?)
-  public func activateBoard(model: any Boardy.BoardInputModel)
-  public func activateBoard(_ input: Boardy.BoardInput<some Any>)
-  public func deactivateBoard(identifier: Boardy.BoardID)
-}
-extension Boardy.MotherboardType {
-  public func interactWithBoard(command: any Boardy.BoardCommandModel)
-  public func interactWithBoard<Input>(_ input: Boardy.BoardCommand<Input>)
-}
-extension Boardy.MotherboardType {
-  public func activateAllBoards(withOptions options: [Boardy.BoardID : Any] = [:], defaultOption: Any? = nil)
-  public func activateAllBoards(models: [any Boardy.BoardInputModel], defaultOption: Any? = nil)
-  public func activateAllBoards<Input>(withInputs inputs: [Boardy.BoardInput<Input>] = [], defaultInput: Input)
-  public func activateAllBoards<Input>(withInputs inputs: [Boardy.BoardInput<Input>])
+extension Boardy.PluginLauncher {
+  final public func attachLaunch(in context: any Boardy.AttachableObject, action: (_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void = { _ in })
 }
-final public class NoBoard : Boardy.Board, Boardy.ActivatableBoard {
-  public init(identifier: Boardy.BoardID, message: Swift.String? = nil, handler: ((Any?) -> Swift.Void)? = nil)
-  final public func activate(withOption option: Any?)
-  final public func shouldBypassGatewayBarrier() -> Swift.Bool
-  @objc deinit
-}
-final public class NoBoardProducer : Boardy.ActivatableBoardProducer {
-  public init()
-  final public func produceGatewayBoard(identifier _: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  final public func matchBoard(withIdentifier _: Boardy.BoardID, to anotherIdentifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  final public func produceBoard(identifier: Boardy.BoardID) -> (any Boardy.ActivatableBoard)?
-  @objc deinit
-}
 @_hasMissingDesignatedInitializers final public class LauncherComponent {
   final public let options: Boardy.MainOptions
   final public var sharedEncodedData: Foundation.Data?
@@ -1352,91 +1456,15 @@
     get
   }
 }
-extension Boardy.PluginLauncher {
-  final public func attachLaunch(in context: any Boardy.AttachableObject, action: (_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void = { _ in })
+public protocol LauncherPlugin {
+  func prepareForLaunching(withOptions options: Boardy.MainOptions) -> Boardy.ModuleComponent
 }
-public enum BoardResult<Success, Failure> {
-  case progress(fractionCompleted: Swift.Double)
-  case success(Success)
-  case failure(Failure)
-  case cancel
-  public static var progress: Boardy.BoardResult<Success, Failure> {
-    get
-  }
-  public var inProgress: Swift.Bool {
-    get
-  }
+public struct ModuleComponent {
+  public init(modulePlugins: [any Boardy.ModulePlugin], urlOpenerPlugins: [any Boardy.URLOpenerPlugin] = [], launchSettings: @escaping (_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void = { _ in })
+  public let modulePlugins: [any Boardy.ModulePlugin]
+  public let urlOpenerPlugins: [any Boardy.URLOpenerPlugin]
+  public let launchSettings: (_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void
 }
-final public class ResultTaskBoard<Input, Success, Failure> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.GuaranteedOutputSendingBoard {
-  public typealias InputType = Input
-  public typealias OutputType = Boardy.BoardResult<Success, Failure>
-  public typealias ExecutorCallback = (Boardy.BoardResult<Success, Failure>) -> Swift.Void
-  public typealias Executor = (Input, @escaping Boardy.ResultTaskBoard<Input, Success, Failure>.ExecutorCallback) -> Swift.Void
-  public init(identifier: Boardy.BoardID, allowBypassGatewayBarrier: Swift.Bool = true, executor: @escaping Boardy.ResultTaskBoard<Input, Success, Failure>.Executor)
-  final public func shouldBypassGatewayBarrier() -> Swift.Bool
-  final public func activate(withGuaranteedInput input: Input)
-  @objc deinit
-}
-open class ServiceMap {
-  final public let mainboard: any Boardy.FlowManageable & Boardy.MotherboardType
-  required public init(mainboard: any Boardy.FlowManageable & Boardy.MotherboardType)
-  @objc deinit
-}
-extension Boardy.MotherboardType where Self : Boardy.FlowManageable {
-  public var serviceMap: Boardy.ServiceMap {
-    get
-  }
-}
-extension Boardy.IdentifiableBoard {
-  public var serviceMap: Boardy.ServiceMap {
-    get
-  }
-}
-extension Boardy.ServiceMap {
-  public func link<MapType>(_: MapType.Type = MapType.self) -> MapType where MapType : Boardy.ServiceMap
-}
-public protocol TaskingBoard : Boardy.ActivatableBoard, Boardy.InstallableBoard {
-  var isCompleted: Swift.Bool { get }
-  var isProcessing: Swift.Bool { get }
-}
-open class TaskBoard<Input, Output> : Boardy.Board, Boardy.GuaranteedBoard, Boardy.TaskingBoard, Boardy.GuaranteedOutputSendingBoard {
-  public typealias ExecutorCompletion = (Swift.Result<Output, any Swift.Error>) -> Swift.Void
-  public typealias Executor = (any Boardy.TaskingBoard, Input, @escaping Boardy.TaskBoard<Input, Output>.ExecutorCompletion) -> Swift.Void
-  public typealias SuccessHandler = (Boardy.TaskBoard<Input, Output>, Output) -> Swift.Void
-  public typealias ProcessingHandler = (Boardy.TaskBoard<Input, Output>) -> Swift.Void
-  public typealias ErrorHandler = (Boardy.TaskBoard<Input, Output>, any Swift.Error) -> Swift.Void
-  public typealias CompletionHandler = (Boardy.TaskBoard<Input, Output>) -> Swift.Void
-  public typealias InputType = Input
-  public typealias OutputType = Output
-  public var isCompleted: Swift.Bool {
-    get
-  }
-  public var isProcessing: Swift.Bool {
-    get
-  }
-  public init(identifier: Boardy.BoardID, allowBypassGatewayBarrier: Swift.Bool = true, executor: @escaping Boardy.TaskBoard<Input, Output>.Executor, successHandler: @escaping Boardy.TaskBoard<Input, Output>.SuccessHandler = { _, _ in }, processingHandler: @escaping Boardy.TaskBoard<Input, Output>.ProcessingHandler = { _ in }, errorHandler: @escaping Boardy.TaskBoard<Input, Output>.ErrorHandler = { board, error in
-                    guard board.context != nil else { return }
-
-
-                    var topViewController = board.rootViewController
-                    while let viewController = topViewController.presentedViewController {
-                        topViewController = viewController
-                    }
-
-                    DispatchQueue.main.async { [weak topViewController] in
-                        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
-                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
-                        topViewController?.present(alert, animated: true)
-                    }
-                }, completionHandler: @escaping Boardy.TaskBoard<Input, Output>.CompletionHandler = { _ in })
-  public func shouldBypassGatewayBarrier() -> Swift.Bool
-  public func activate(withGuaranteedInput input: Input)
-  @objc deinit
-  open func handleSuccess(_ output: Output)
-  open func handleProgress()
-  open func handleError(_ error: any Swift.Error)
-  open func willComplete()
-}
 extension Foundation.URL {
   public var boardy: Boardy.BoardyURLExtensions {
     get
@@ -1453,86 +1481,46 @@
     get
   }
 }
-public protocol URLOpenerPlugin : Boardy.URLOpenerPluginConvertible {
-  var name: Swift.String { get }
-  func canOpenURL(_ url: Foundation.URL) -> Swift.Bool
-  func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, open url: Foundation.URL)
+public protocol DetachableObject : AnyObject {
+  func detachObject(_ object: Swift.AnyObject)
 }
-extension Boardy.URLOpenerPlugin {
-  public var name: Swift.String {
-    get
-  }
+public protocol AttachableObject : Boardy.DetachableObject {
+  func attach(to object: Swift.AnyObject)
+  func attachObject(_ object: Swift.AnyObject)
+  func attachedObjects() -> [Swift.AnyObject]
+  func detachAllObjects()
 }
-public protocol URLOpenerPluginConvertible {
-  var urlOpenerPlugins: [any Boardy.URLOpenerPlugin] { get }
+extension Boardy.AttachableObject {
+  public func attach(to object: Swift.AnyObject)
+  public func attachObject(_ object: Swift.AnyObject)
+  public func attachedObjects() -> [Swift.AnyObject]
+  public func attachedObjects<ObjectType>(_: ObjectType.Type = ObjectType.self) -> [ObjectType]
+  public func firstAttachedObject<ObjectType>(_: ObjectType.Type = ObjectType.self) -> ObjectType?
+  public func lastAttachedObject<ObjectType>(_: ObjectType.Type = ObjectType.self) -> ObjectType?
+  public func detachObject(_ object: Swift.AnyObject)
+  public func detachObjects<ObjectType>(_: ObjectType.Type, where condition: (ObjectType) -> Swift.Bool = { _ in true })
+  public func detachObjects(where condition: (Swift.AnyObject) -> Swift.Bool)
+  public func detachAllObjects()
 }
-extension Boardy.URLOpenerPlugin {
-  public var urlOpenerPlugins: [any Boardy.URLOpenerPlugin] {
-    get
-  }
+extension ObjectiveC.NSObject : Boardy.AttachableObject {
 }
-public protocol URLOpenerPathMatchingPlugin : Boardy.URLOpenerPlugin {
-  var matchingPath: Swift.String { get }
-  func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openURLWithParameters parameters: [Swift.String : Swift.String])
+extension Boardy.Board : Boardy.AttachableObject {
 }
-extension Boardy.URLOpenerPathMatchingPlugin {
-  public func canOpenURL(_ url: Foundation.URL) -> Swift.Bool
-  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, open url: Foundation.URL)
+extension Boardy.ModernContinuableBoard {
+  @discardableResult
+  public func attachContinuousMotherboard(to context: any Boardy.AttachableObject, configurationBuilder: (any Boardy.FlowManageable & Boardy.MotherboardType) -> Swift.Void = { _ in }) -> any Boardy.FlowManageable & Boardy.MotherboardType
+  @discardableResult
+  public func attachContinuousMotherboard<Mainboard>(to context: any Boardy.AttachableObject, build: (any Boardy.ActivatableBoardProducer) -> Mainboard) -> Mainboard where Mainboard : Boardy.FlowManageable, Mainboard : Boardy.MotherboardType
 }
-public struct BlockURLOpenerPathMatchingPlugin : Boardy.URLOpenerPathMatchingPlugin {
-  public init(name: Swift.String? = nil, matchingPath: Swift.String, handler: @escaping (any Boardy.FlowManageable & Boardy.MotherboardType, [Swift.String : Swift.String]) -> Swift.Void)
-  public let matchingPath: Swift.String
-  public var name: Swift.String {
-    get
-  }
-  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openURLWithParameters parameters: [Swift.String : Swift.String])
-}
-public enum URLOpeningOption<Parameter> {
-  case yes(Parameter)
-  case no
-}
-public protocol GuaranteedURLOpenerPlugin : Boardy.URLOpenerPlugin {
-  associatedtype Parameter
-  func willOpen(url: Foundation.URL) -> Boardy.URLOpeningOption<Self.Parameter>
-  func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openWith parameter: Self.Parameter)
-}
-extension Boardy.GuaranteedURLOpenerPlugin {
-  public func canOpenURL(_ url: Foundation.URL) -> Swift.Bool
-  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, open url: Foundation.URL)
-}
-public struct BlockURLOpenerPlugin<Parameter> : Boardy.GuaranteedURLOpenerPlugin {
-  public var name: Swift.String {
-    get
-  }
-  public init(name: Swift.String? = nil, condition: @escaping (Foundation.URL) -> Boardy.URLOpeningOption<Parameter>, handler: @escaping (any Boardy.FlowManageable & Boardy.MotherboardType, Parameter) -> Swift.Void)
-  public func willOpen(url: Foundation.URL) -> Boardy.URLOpeningOption<Parameter>
-  public func mainboard(_ mainboard: any Boardy.FlowManageable & Boardy.MotherboardType, openWith parameter: Parameter)
-}
-extension Swift.Array : Boardy.URLOpenerPluginConvertible where Element == any Boardy.URLOpenerPlugin {
-  public var urlOpenerPlugins: [any Boardy.URLOpenerPlugin] {
-    get
-  }
-}
-@_functionBuilder public enum URLOpenerPluginBuilder {
-  public static func buildBlock(_ components: any Boardy.URLOpenerPluginConvertible...) -> [any Boardy.URLOpenerPlugin]
-  public static func buildArray(_ components: [any Boardy.URLOpenerPluginConvertible]) -> [any Boardy.URLOpenerPlugin]
-  public static func buildEither(first component: any Boardy.URLOpenerPluginConvertible) -> any Boardy.URLOpenerPluginConvertible
-  public static func buildEither(second component: any Boardy.URLOpenerPluginConvertible) -> any Boardy.URLOpenerPluginConvertible
-  public static func buildOptional(_ component: (any Boardy.URLOpenerPluginConvertible)?) -> any Boardy.URLOpenerPluginConvertible
-  public static func buildExpression(_ expression: (any Boardy.URLOpenerPluginConvertible)?) -> any Boardy.URLOpenerPluginConvertible
-}
-extension Boardy.PluginLauncher {
-  final public func install(@Boardy.URLOpenerPluginBuilder urlOpenerPluginsBuilder: () -> [any Boardy.URLOpenerPlugin]) -> Self
-}
 extension Boardy.ActivationBarrierScope : Swift.Equatable {}
 extension Boardy.ActivationBarrierScope : Swift.Hashable {}
+extension Boardy.OutputCombinedFlow.Strategy : Swift.Equatable {}
+extension Boardy.OutputCombinedFlow.Strategy : Swift.Hashable {}
+extension Boardy.TaskCompletionStatus : Swift.Equatable {}
+extension Boardy.TaskCompletionStatus : Swift.Hashable {}
 extension Boardy.AlertAction.Style : Swift.Equatable {}
 extension Boardy.AlertAction.Style : Swift.Hashable {}
 extension Boardy.Alert.Style : Swift.Equatable {}
 extension Boardy.Alert.Style : Swift.Hashable {}
-extension Boardy.TaskCompletionStatus : Swift.Equatable {}
-extension Boardy.TaskCompletionStatus : Swift.Hashable {}
-extension Boardy.OutputCombinedFlow.Strategy : Swift.Equatable {}
-extension Boardy.OutputCombinedFlow.Strategy : Swift.Hashable {}
 extension Boardy.URLOpeningValidationStatus : Swift.Equatable {}
 extension Boardy.URLOpeningValidationStatus : Swift.Hashable {}
```

## Global-actor annotation check

No newly added qualified or unqualified global-actor annotation was found on an existing declaration.

## Result

PASS
