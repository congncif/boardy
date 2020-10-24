//
//  UIColor+Random.swift
//  Boardy_Example
//
//  Created by FOLY on 10/24/20.
//  Copyright © 2020 [iF] Solution. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func random() -> UIColor {
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
