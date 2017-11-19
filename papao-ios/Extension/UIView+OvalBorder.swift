//
//  UILabel+OvalBorder.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 5..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

extension UIView {
    func setRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func setBorder(color: UIColor, width: CGFloat? = nil) {
        self.layer.borderWidth = width ?? 1
        self.layer.borderColor = color.cgColor
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
