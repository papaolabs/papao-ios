//
//  UIScrollView+PPAdditions.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 30..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}
