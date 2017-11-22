//
//  PPOBookmarkButton.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PPOBookmarkButton: UIButton {
    private var _bookmarked: Bool = false
    var bookmarked: Bool {
        set(newVal) {
            _bookmarked = newVal
            let newImage = newVal ? UIImage.init(named: "iconBookmarkPressed") : UIImage.init(named: "iconBookmarkDetail")
            setImage(newImage, for: .normal)
        }
        get {
            return _bookmarked
        }
    }
}
