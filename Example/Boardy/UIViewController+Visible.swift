//
//  UIViewController+Visible.swift
//  Boardy_Example
//
//  Created by NGUYEN CHI CONG on 9/13/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var isVisible: Bool {
        isViewLoaded && view.window != nil
    }
}
