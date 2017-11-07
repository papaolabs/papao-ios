//
//  Age.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 4..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Age: PublicDataProtocol {
    var code: Int
    var name: String

    init(dict: [String: AnyObject]) {
        self.code = dict["code"] as! Int
        self.name = dict["name"] as! String
    }
}
