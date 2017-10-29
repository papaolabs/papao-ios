//
//  Breed.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Category {
    var code: Int
    var name: String
    
    init(dict: [String: AnyObject]) {
        self.code = dict["code"] as! Int
        self.name = dict["name"] as! String
    }
}

struct Breed {
    var category: Category
    var code: Int
    var name: String
    
    init(dict: [String: AnyObject]) {
        self.category = Category(dict: dict["category"] as! [String : AnyObject])
        self.code = dict["code"] as! Int
        self.name = dict["name"] as! String
    }
}
