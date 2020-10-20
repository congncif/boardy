//
//  HeadlineProtocols.swift
//  Boardy
//
//  Created by NGUYEN CHI CONG on 8/30/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import UIKit

protocol HeadlineController: UIViewController {
    var delegate: HeadlineDelegate? { get set }
}

protocol HeadlineDelegate: AnyObject {
    func returnRoot()
    func gotoNext()
}

protocol HeadlineBuildable {
    func build() -> HeadlineController
}
