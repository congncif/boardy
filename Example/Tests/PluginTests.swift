//
//  PluginTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 10/1/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

private final class PluginLifetimeBoard: Board, ActivatableBoard {
    func activate(withOption _: Any?) {}
}

private final class PluginLifetimeComponent: MainComponent {
    let options: MainOptions = .default
    let producer: BoardDynamicProducer

    init(producer: BoardDynamicProducer) {
        self.producer = producer
    }
}

private final class ModuleBuilderPluginSpy: ModuleBuilderPlugin {
    let identifier: BoardID = "plugin-lifetime"
    private(set) var buildCallCount = 0

    func internalContinuousRegistrations(
        sharedComponent _: any SharedValueComponent,
        producer _: any ActivatableBoardProducer
    ) -> [BoardRegistration] {
        []
    }

    func build(
        with identifier: BoardID,
        sharedComponent _: any SharedValueComponent,
        internalContinuousProducer _: any ActivatableBoardProducer
    ) -> any ActivatableBoard {
        buildCallCount += 1
        return PluginLifetimeBoard(identifier: identifier)
    }
}

class PluginTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClassBuilderPluginIsRetainedForLazyFactoryLifetime() {
        var producer: BoardProducer? = BoardProducer()
        var component: PluginLifetimeComponent? = producer.map {
            PluginLifetimeComponent(producer: $0.boxed)
        }
        var plugin: ModuleBuilderPluginSpy? = ModuleBuilderPluginSpy()
        weak var retainedPlugin = plugin

        plugin?.apply(for: component!)
        plugin = nil

        XCTAssertNotNil(retainedPlugin)
        guard retainedPlugin != nil else { return }

        let board = producer?.produceBoard(identifier: "plugin-lifetime")

        XCTAssertNotNil(board)
        XCTAssertEqual(retainedPlugin?.buildCallCount, 1)

        component = nil
        producer = nil

        XCTAssertNil(retainedPlugin)
    }
}
