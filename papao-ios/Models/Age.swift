//
//  Age.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 4..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Age: PublicDataProtocol {
    var code: Int           // dummy
    var name: String        // 연도 yyyy

    init(dict: [String: AnyObject]) {
        if let code = dict["code"] as? Int {
            self.code = code
        } else {
            self.code = -1
        }
        
        if let name = dict["name"] as? Int {
            self.name = String(describing: name)
        } else if let nameString = dict["name"] as? String {
            self.name = nameString
        } else {
            self.name = "-1"
        }
        
    }
    
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        
        guard name != "-1" else {
            return "미상"
        }
        guard let birthday: Date = formatter.date(from: name) else {
            return "미상"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let ageYear = ageComponents.year!
        
        if ageYear < 1 {
            return "1살 미만"
        }
        return String(describing: "\(ageYear) 살")
    }
}
