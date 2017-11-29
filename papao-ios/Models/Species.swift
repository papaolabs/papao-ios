//
//  Species.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

enum SpeciesName: Int {
    case DOG = 417000
    case CAT = 422400
    case ETC = 429900
    
    var keyName: String {
        get { return String(describing: self) }
    }
    
    var description: String {
        switch self {
        case .DOG:
            return "개"
        case .CAT:
            return "고양이"
        case .ETC:
            return "기타"
        }
    }
}

struct Species: PublicDataProtocol {
    var code: Int
    var name: String
    var breeds: [Breed] = []
    
    init(dict: [String: AnyObject]) {
        self.code = dict["code"] as! Int
        switch dict["name"] as! String {
        case SpeciesName.DOG.keyName:
            self.name = SpeciesName.DOG.description
        case SpeciesName.CAT.keyName:
            self.name = SpeciesName.CAT.description
        case SpeciesName.ETC.keyName:
            self.name = SpeciesName.ETC.description
        default:
            self.name = SpeciesName.ETC.description
        }
        if let breeds = dict["breeds"] as? [[String : AnyObject]] {
            self.breeds = breeds.map({ (town) -> Breed in
                return Breed(dict: town)
            })
        }
    }
    
    func getBreed(code: Int) -> Breed? {
        if let breed = self.breeds.first(where: {$0.code == code}) {
            return breed
        } else {
            return nil
        }
    }
}
