//
//  ProducerTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 10/1/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

private class StubBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

class ProducerTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoxedProducer() throws {
        var producer: BoardProducer? = BoardProducer(registrations: [])

        let boxedProducer = BoardDynamicProducerBox(producer: producer)
        XCTAssertNotNil(boxedProducer.producer)

        boxedProducer.registerBoard("add-one") { id in
            StubBoard(identifier: id)
        }

        let regBoard = producer?.produceBoard(identifier: "add-one")
        XCTAssertNotNil(regBoard)

        producer = nil
        XCTAssertNil(boxedProducer.producer)
    }

    // MARK: - Duplicate registration

    /// Pins the historical defaults so a later refactor cannot quietly converge them.
    /// `BoardProducer` keeps the first factory; `BoardContainer` keeps the last.
    func testDefaultDuplicateRegistrationKeepsTheHistoricalWinner() {
        let producer = BoardProducer()
        producer.registerBoard("dup") { _ in StubBoard(identifier: "first") }
        producer.registerBoard("dup") { _ in StubBoard(identifier: "second") }
        XCTAssertEqual(producer.produceBoard(identifier: "dup")?.identifier, "first")

        let container = BoardContainer()
        container.registerBoard("dup") { _ in StubBoard(identifier: "first") }
        container.registerBoard("dup") { _ in StubBoard(identifier: "second") }
        XCTAssertEqual(container.produceBoard(identifier: "dup")?.identifier, "second")
    }

    /// Stating the intent explicitly must give the same result from either producer.
    func testExplicitDuplicateRegistrationAgreesAcrossProducers() {
        for makeProducer: () -> BoardDynamicProducer in [{ BoardProducer() }, { BoardContainer() }] {
            let replacing = makeProducer()
            replacing.registerBoard("dup", replacingExisting: false) { _ in StubBoard(identifier: "first") }
            replacing.registerBoard("dup", replacingExisting: true) { _ in StubBoard(identifier: "second") }
            XCTAssertEqual(replacing.produceBoard(identifier: "dup")?.identifier, "second")

            let keeping = makeProducer()
            keeping.registerBoard("dup", replacingExisting: false) { _ in StubBoard(identifier: "first") }
            keeping.registerBoard("dup", replacingExisting: false) { _ in StubBoard(identifier: "second") }
            XCTAssertEqual(keeping.produceBoard(identifier: "dup")?.identifier, "first")
        }
    }

    /// `registrations` is a `Set` keyed on identifier, so lookup must return the stored element
    /// rather than whatever probe was used to find it.
    func testRegistrationLookupReturnsTheStoredFactory() {
        let producer = BoardProducer()
        producer.registerBoard("a") { _ in StubBoard(identifier: "board-a") }
        producer.registerBoard("b") { _ in StubBoard(identifier: "board-b") }

        XCTAssertEqual(producer.produceBoard(identifier: "a")?.identifier, "board-a")
        XCTAssertEqual(producer.produceBoard(identifier: "b")?.identifier, "board-b")

        // An unregistered identifier falls through to the external producer, which by default is
        // `NoBoardProducer` — it answers with a `NoBoard` rather than nil.
        XCTAssertTrue(producer.produceBoard(identifier: "missing") is NoBoard)

        producer.remove(registration: BoardRegistration("a") { _ in nil })
        XCTAssertTrue(producer.produceBoard(identifier: "a") is NoBoard)
        XCTAssertEqual(producer.produceBoard(identifier: "b")?.identifier, "board-b")
    }
}
