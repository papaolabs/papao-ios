//
//  Date+PPAdditions.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 11. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

extension Date {
    func toString(format: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
