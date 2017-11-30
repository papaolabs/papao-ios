//
//  PPOPickerButton.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 6..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PPOPickerButton: UIButton {
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
        // set background, color
        backgroundColor = .white
        tintColor = UIColor.ppBrownishGray
        
        // set other operations after super.init, if required
        layer.cornerRadius = 8
        layer.borderWidth = 0.4
        layer.borderColor = UIColor.ppBorderGray.cgColor
        
        // set image
        setImage(UIImage.init(named: "triangle"), for: .normal)
        
        // alignment
        contentHorizontalAlignment = .left
        imageEdgeInsets = .init(top: imageEdgeInsets.top, left: self.bounds.width - 26, bottom: imageEdgeInsets.bottom, right: imageEdgeInsets.right)
        titleEdgeInsets = .init(top: titleEdgeInsets.top, left: 3, bottom: titleEdgeInsets.bottom, right: titleEdgeInsets.right)
        
        // blocking interactions
    }
}
