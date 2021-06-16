//
//  AppDelegate.swift
//  Boardy
//
//  Created by congncif on 08/08/2020.
//  Copyright (c) 2020 congncif. All rights reserved.
//

import Boardy
import Resolver
import SiFUtilities
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    @LazyInjected var rootBoard: RootBoard

//    @LazyInjected var deepLinkHandler: DeepLinkHandling

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let registry = ServiceRegistry()
        registry.registerAllServices()
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIViewController.swizzling()

        guard let window = self.window else { return false }
        rootBoard.installIntoWindow(window)
        rootBoard.activate(withGuaranteedInput: launchOptions)

//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.mainboard.installIntoRootViewController(window.rootViewController!.presentedViewController!)
//            let text = String(Int.random(in: 0 ... 999))
//            self.mainboard.activateBoard(identifier: "1", withOption: text)
//        }

        mainboard.registerFlow(matchedIdentifiers: "1", target: self) { (_, output: Int) in
            print("😍 DEFAULT FLOW \(output)")
        }

        mainboard.registerGuaranteedFlow(matchedIdentifiers: "1", target: self, uniqueOutputType: Int.self) { _, output in
            print("😍 GUARANTEED FLOW \(output)")
        }

        mainboard.registerChainFlow(matchedIdentifiers: "1", target: self)
            .handle(outputType: Int.self) { _, output in
                print("😍 CHAIN FLOW \(output)")
            }
            .eventuallySkipHandling()

//        deepLinkHandler.start(with: window!.rootViewController!)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let link = url.absoluteString
//        deepLinkHandler.handleDeepLink(link)

        window?.rootViewController?.handleDeepLink(link, handlerClub: DeepLinkAppClub())

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    lazy var mainboard: Motherboard = {
        let task1 = TaskBoard<String, Int>(identifier: "1", executor: { board, input, completion in
            print("👉 Task \(board.identifier) activated: \(input)")
            print("👉 \(type(of: input)) \(input) will be converted to Int")

            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                if let result = Int(input) {
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "error.no-value", code: 1, userInfo: nil)))
                    }
                }
            }
        }, processingHandler: {
            $0.isProcessing ? $0.rootViewController.view.showLoading(animated: false) : $0.rootViewController.view.hideLoading(animated: false)
        }, errorHandler: {
            $0.sendToMotherboard(data: $1)
        })

        let task2 = TaskBoard<Int, String>(identifier: "2", executor: { board, input, completion in
            print("👉 Task \(board.identifier) activated: \(input)")
            print("👉 \(type(of: input)) \(input) will be converted to String")

            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                let result = String(input)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            }
        }, processingHandler: {
            $0.isProcessing ? $0.rootViewController.view.showLoading(animated: false) : $0.rootViewController.view.hideLoading(animated: false)
        })

        let task3 = TaskBoard<String, String>(identifier: "3", executor: { board, input, completion in
            print("👉 Task \(board.identifier) activated: \(input)")
            print("👉 \(type(of: input)) \(input) will be returned with tick mark")

            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    completion(.success("✅ " + input))
                }
            }
        }, processingHandler: {
            $0.isProcessing ? $0.rootViewController.view.showLoading(animated: false) : $0.rootViewController.view.hideLoading(animated: false)
        })

        let motherboard = Motherboard(boards: [task1, task2, task3])

        motherboard.registerFlowSteps("1" ->>> "2" ->>> "3")

        motherboard.registerFlow(BoardActivateFlow(matchedIdentifiers: ["3"], nextHandler: { text in
            print("🏁 " + String(describing: text))
        }))

        return motherboard
    }()
}
