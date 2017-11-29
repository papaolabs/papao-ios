//
//  String+PPAdditions.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

extension String {
    func toDate(format yyyyMMdd: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = yyyyMMdd
        return formatter.date(from: self)
    }

    func getPhoneWithoutDash() -> String {
        return self.components(separatedBy: ["-"]).joined()
    }
}
