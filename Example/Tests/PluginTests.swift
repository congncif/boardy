//
//  PluginTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 10/1/21.
//  Copyright © 2021 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

class PluginTests: XCTestCase {
    func testModuleBuilderPluginClassIsRetainedForLazyBuild() throws {
        weak var weakPlugin: RetainedModuleBuilderPlugin?
        let launcher: PluginLauncher

        do {
            let plugin = RetainedModuleBuilderPlugin(identifier: "retained-plugin")
            weakPlugin = plugin
            launcher = PluginLauncher.with(options: .default)
                .install(plugin: plugin)
                .instantiate()
        }

        XCTAssertNotNil(weakPlugin)

        var output: String?
        launcher.activateNow { mainboard in
            mainboard.matchedFlow("retained-plugin", with: String.self).handle { value in
                output = value
            }
            mainboard.activation("retained-plugin", with: String.self).activate(with: "OK")
        }

        XCTAssertEqual(output, "OK")
        XCTAssertNotNil(weakPlugin)
    }
}

private final class RetainedModuleBuilderPlugin: ModuleBuilderPlugin {
    let identifier: BoardID

    init(identifier: BoardID) {
        self.identifier = identifier
    }

    func internalContinuousRegistrations(sharedComponent _: any SharedValueComponent, producer _: any ActivatableBoardProducer) -> [BoardRegistration] {
        []
    }

    func build(with identifier: BoardID, sharedComponent _: any SharedValueComponent, internalContinuousProducer _: any ActivatableBoardProducer) -> ActivatableBoard {
        PluginOutputBoard(identifier: identifier)
    }
}

private final class PluginOutputBoard: Board, GuaranteedBoard, GuaranteedOutputSendingBoard {
    typealias InputType = String
    typealias OutputType = String

    func activate(withGuaranteedInput input: String) {
        sendOutput(input)
    }
}
