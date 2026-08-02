//
//  AttachableTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 1/28/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

class MainObject: AttachableObject {
    deinit {
        print("deinit")
    }
}

class SomeObject: AttachableObject {}

class OtherObject: AttachableObject {}

final class ConcurrentMainObject: AttachableObject, @unchecked Sendable {}

final class ConcurrentAttachedObject: AttachableObject, @unchecked Sendable {}

class AttachableTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        AttachableStaticStorage.removeAll()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {}

    func testAttachObject() throws {
        let some = SomeObject()
        let mainObject = MainObject()

        mainObject.attachObject(some)

        let attachedObjects = mainObject.attachedObjects()
        XCTAssertFalse(attachedObjects.isEmpty)

        let firstAttached: SomeObject? = mainObject.firstAttachedObject()

        XCTAssertNotNil(firstAttached)
        XCTAssertTrue(some === firstAttached)

        let lastAttached = mainObject.lastAttachedObject(SomeObject.self)

        XCTAssertNotNil(lastAttached)
        XCTAssertTrue(some === lastAttached)
    }

    func testAttachTo() {
        let some = SomeObject()
        let mainObject = MainObject()

        some.attach(to: mainObject)

        let attachedObjects = mainObject.attachedObjects()
        XCTAssertFalse(attachedObjects.isEmpty)

        let firstAttached: SomeObject? = mainObject.firstAttachedObject()

        XCTAssertNotNil(firstAttached)
        XCTAssertTrue(some === firstAttached)
    }

    func testMultipleAttach() {
        let some = SomeObject()
        let other = OtherObject()
        let mainObject = MainObject()

        mainObject.attachObject(some)
        mainObject.attachObject(other)

        let attachedObjects = mainObject.attachedObjects()
        XCTAssertEqual(attachedObjects.count, 2)
    }

    func testConcurrentAttachPreservesEveryObject() {
        let mainObject = ConcurrentMainObject()
        let objects = (0 ..< 100).map { _ in ConcurrentAttachedObject() }

        DispatchQueue.concurrentPerform(iterations: objects.count) { index in
            mainObject.attachObject(objects[index])
        }

        XCTAssertEqual(mainObject.attachedObjects(ConcurrentAttachedObject.self).count, objects.count)
    }

    func testRemoveAllClearsLockedStorage() {
        let mainObject = MainObject()
        mainObject.attachObject(SomeObject())
        XCTAssertFalse(mainObject.attachedObjects().isEmpty)

        AttachableStaticStorage.removeAll()

        XCTAssertTrue(mainObject.attachedObjects().isEmpty)
    }
}
