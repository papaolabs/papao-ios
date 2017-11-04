//
//  Species.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

enum SpeciesName: String {
    case DOG = "개"
    case CAT = "고양이"
    case ETC = "기타"
    
    var keyName: String {
        get { return String(describing: self) }
    }
}

struct Species: PublicDataProtocol {
    var code: Int
    var name: String
    
    init(dict: [String: AnyObject]) {
        self.code = dict["code"] as! Int
        switch dict["name"] as! String {
        case SpeciesName.DOG.keyName:
            self.name = SpeciesName.DOG.rawValue
        case SpeciesName.CAT.keyName:
            self.name = SpeciesName.CAT.rawValue
        case SpeciesName.ETC.keyName:
            self.name = SpeciesName.ETC.rawValue
        default:
            self.name = SpeciesName.ETC.rawValue
        }
    }
}
