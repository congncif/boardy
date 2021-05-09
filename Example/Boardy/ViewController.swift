//
//  ViewController.swift
//  Boardy
//
//  Created by congncif on 08/08/2020.
//  Copyright (c) 2020 congncif. All rights reserved.
//

import Boardy
import Resolver
import UIKit

public struct LBBoardActivation {
    let mainboard: MotherboardType
}

extension MotherboardType {
    public var lb: LBBoardActivation {
        return LBBoardActivation(mainboard: self)
    }
}

protocol LBActivatable {
    func activate(_ id: BoardID, with input: String)
    func interactSomething(with other: BoardID, data: String)
}

extension LBBoardActivation: LBActivatable {
    func activate(_ id: BoardID, with input: String) {
        mainboard.activateBoard(BoardInput(target: id, input: input))
    }

    func interactSomething(with other: BoardID, data: String) {
        mainboard.interactWithBoard(BoardCommand(identifier: other, input: data))
    }
}

func activateLB() {
    let mb = Motherboard()
    mb.lb.activate(BoardID("lb"), with: "abc")
}

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let someData: Any? = "ABC"

        ChainDataHandler(self)
            .with(dataType: String.self) { _, data in
                print("data: \(data)")
            }
            .fallback()
            .handle(data: someData)
    }

    override func viewDidDisplay() {}
}
