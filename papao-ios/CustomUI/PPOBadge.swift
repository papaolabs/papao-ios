//
//  PPOBadgeLabel.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 11. 5..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

enum PPOBadgeType {
    case small
    case medium
}

class PPOBadge: UIButton {
    required init(borderColor: UIColor) {
        super.init(frame: .zero)
        initialize()
        setBorder(color: borderColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        // set other operations after super.init, if required
        layer.borderWidth = 1
        layer.borderColor = UIColor.init(named: "textBlack")?.cgColor

        // blocking interactions
    }
    
    func setStyle(type: PPOBadgeType, backgroundColor: UIColor? = nil, titleColor: UIColor? = nil) {
        switch type {
        case .small:
            setRadius(radius: 10)
            contentEdgeInsets = .init(top: 3, left: 8, bottom: 2, right: 8)
        case .medium:
            setBackgroundColor(color: backgroundColor)
            setRadius(radius: 13)
            contentEdgeInsets = .init(top: 5, left: 18, bottom: 4, right: 17)
        }
        
        setBackgroundColor(color: backgroundColor)
        setTitleColor(titleColor, for: .normal)
    }
    
    func setBackgroundColor(color: UIColor?) {
        if let backgroundColor = color {
            self.backgroundColor = backgroundColor
            setBorder(color: backgroundColor)
        } else {
            setBorder(color: UIColor.init(named: "textBlack") ?? .black)
        }
    }
}
