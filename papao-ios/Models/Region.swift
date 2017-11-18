//
//  Region.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Sido: PublicDataProtocol {
    var code: Int
    var name: String
    var towns: [Gungu] = []
    
    init(dict: [String: AnyObject]) {
        if let towns = dict["towns"] as? [[String : AnyObject]] {
            self.towns = towns.map({ (town) -> Gungu in
                return Gungu(dict: town)
            })
        }
        
        self.code = dict["code"] as! Int
        self.name = dict["name"] as! String
    }
}

struct Gungu: PublicDataProtocol {
    var code: Int
    var name: String
    
    init(dict: [String: AnyObject]) {
        self.code = dict["code"] as! Int
        self.name = dict["name"] as! String
    }
}
