//
//  PPOBadgeLabel.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 11. 5..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

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
        layer.cornerRadius = 13
        layer.borderWidth = 1
        layer.borderColor = UIColor.init(named: "textBlack")?.cgColor
        contentEdgeInsets = .init(top: 5, left: 18, bottom: 4, right: 17)
        
        // blocking interactions
        
    }
}
