//
//  Filter.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Filter {
    var species: String
    var breed: String
    var gender: String
    var beginDate: String
    var endDate: String
    var sidoCode: String
    var gunguCode: String
    
    init() {
        species = ""
        breed = ""
        gender = ""
        beginDate = ""
        endDate = ""
        sidoCode = ""
        gunguCode = ""
    }
}

