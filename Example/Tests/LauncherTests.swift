//
//  LauncherTests.swift
//  Boardy_Tests
//
//  Created by NGUYEN CHI CONG on 3/10/22.
//  Copyright © 2022 [iF] Solution. All rights reserved.
//

@testable import Boardy
import XCTest

class SpyBoard: Board, GuaranteedBoard {
    typealias InputType = String

    func activate(withGuaranteedInput input: String) {
        sendToMotherboard(data: input)
    }
}

class SpyModulePlugin: ModulePlugin {
    let identifier: BoardID

    init(identifier: BoardID) {
        self.identifier = identifier
    }

    func apply(for main: MainComponent) {
        main.producer.registerBoard(identifier) { identifier in
            SpyBoard(identifier: identifier)
        }
    }
}

class SpyURLOpenerPlugin: GuaranteedURLOpenerPlugin {
    var scheme: String

    init(scheme: String) {
        self.scheme = scheme
    }

    var name: String {
        scheme + "-plugin"
    }

    func willOpen(url: URL) -> URLOpeningOption<String> {
        if let host = url.host, url.scheme == scheme {
            return .yes(host)
        } else {
            return .no
        }
    }

    func mainboard(_ mainboard: FlowMotherboard, openWith parameter: String) {
        mainboard.activation("test", with: String.self).activate(with: parameter)
    }
}

class LauncherTests: XCTestCase {
    var launcher: PluginLauncher!

    var xValue: String?
    var zValue: Bool = false

    override func setUpWithError() throws {
        launcher = PluginLauncher.with(options: .default)
            .install(plugin: SpyModulePlugin(identifier: "test"))
            .instantiate { mainboard in
                mainboard.matchedFlow("test", with: String.self)
                    .addTarget(self) { target, value in
                        target.xValue = value
                    }
            }
            .installURLOpenerPlugin(name: "xxx-plugin", condition: { url -> URLOpeningOption<String> in
                if let host = url.host, url.scheme == "xxx" {
                    return .yes(host)
                } else {
                    return .no
                }
            }, handler: { mainboard, param in
                mainboard.activation("test", with: String.self).activate(with: param)
            })
            .install(urlOpenerPluginsBuilder: {
                SpyURLOpenerPlugin(scheme: "yyy")
                SpyURLOpenerPlugin(scheme: "zzz")
            })
            .installURLOpenerPlugin(name: "zzz-block-plugin", condition: { url in
                url.scheme == "zzz"
            }, handler: { [weak self] _ in
                self?.zValue = true
            })
    }

    override func tearDownWithError() throws {
        launcher = nil
    }

    func testBlockURLOpenerPlugin() {
        let matchedCandidates = launcher.open(link: "xxx://localhost")
        XCTAssertTrue(matchedCandidates.count == 1)
        XCTAssertEqual(xValue, "localhost")
        XCTAssertEqual(matchedCandidates.first, "xxx-plugin")
    }

    func testURLOpenerPlugin() {
        let matchedCandidates = launcher.open(link: "yyy://localhost")
        XCTAssertTrue(matchedCandidates.count == 1)
        XCTAssertEqual(xValue, "localhost")
        XCTAssertEqual(matchedCandidates.first, "yyy-plugin")
    }

    func testMultipleURLOpenerPlugin() {
        let matchedCandidates = launcher.open(link: "zzz://localhost")
        XCTAssertTrue(matchedCandidates.count == 2)
        XCTAssertEqual(xValue, "localhost")
        XCTAssertTrue(zValue)
        XCTAssertEqual(matchedCandidates.first, "zzz-plugin")
        XCTAssertEqual(matchedCandidates.last, "zzz-block-plugin")
    }

    func testMultipleURLOpenerReturnsAllMatchedCandidatesWhileOnlySelectionExecutes() {
        var selectedCandidateNames: [String] = []
        launcher.setURLOpenerSelectionHandler { _, _, candidates, select in
            let selectedCandidates = Array(candidates.suffix(1))
            selectedCandidateNames = selectedCandidates.map(\.name)
            select(selectedCandidates)
        }

        let matchedCandidates = launcher.open(link: "zzz://localhost")

        XCTAssertEqual(matchedCandidates, ["zzz-plugin", "zzz-block-plugin"])
        XCTAssertEqual(selectedCandidateNames, ["zzz-block-plugin"])
        XCTAssertNil(xValue)
        XCTAssertTrue(zValue)
    }

    func testCleanGatewayBarrierExemptCompletesAndAllowsActivation() {
        let destinationID: BoardID = "gateway-exempt-destination"
        let exemptLauncher = PluginLauncher.with(options: .default)
            .install(plugin: SpyModulePlugin(identifier: destinationID))
            .install(gatewayBarrier: .exempt, for: destinationID)
            .instantiate { mainboard in
                mainboard.matchedFlow(destinationID, with: String.self)
                    .addTarget(self) { target, value in
                        target.xValue = value
                    }
            }

        exemptLauncher.activateNow { mainboard in
            mainboard.activation(destinationID, with: String.self)
                .activate(with: "allowed")
        }

        XCTAssertEqual(xValue, "allowed")
    }

    func testLegacyZeroWidthGatewayBarrierExemptRemainsSourceCompatible() {
        let registration = GatewayBarrierRegistration.​exempt

        XCTAssertNotNil(registration)
    }
}
