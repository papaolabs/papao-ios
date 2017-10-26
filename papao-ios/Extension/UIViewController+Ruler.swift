//
//  UIViewController+Ruler.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 26..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

extension UIViewController {
    class var statusBarHeight: CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
}
