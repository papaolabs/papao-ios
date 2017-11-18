//
//  Filter.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Filter {
    var postTypes: [PostType]   // 포스트타입 리스트
    var species: SpeciesName?   // 축종
    var breed: Breed?           // 품종
    var genderType: Gender?     // 성별(M,F,Q)
    var beginDate: Date?        // yyyyMMdd
    var endDate: Date?          // yyyyMMdd
    var sido: Sido?             // 시도
    var gungu: Gungu?           // 군구
    
    init(postTypes: [PostType]) {
        self.postTypes = postTypes
    }
    
    func toDict() -> [String: AnyObject] {
        var dict = ["postType": postTypes.map({ (postType) -> String in
            return postType.rawValue
        }).joined(separator: ",") as AnyObject]
        if let species = species {
            dict["upKindCode"] = "\(species.rawValue)" as AnyObject
        }
        if let breed = breed {
            dict["kindCode"] = "\(breed.code)" as AnyObject
        }
        if let genderType = genderType {
            dict["genderType"] = "\(genderType.rawValue)" as AnyObject
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if let beginDate = beginDate {
            dict["beginDate"] = "\(formatter.string(from: beginDate))" as AnyObject
        }
        if let endDate = endDate {
            dict["endDate"] = "\(formatter.string(from: endDate))" as AnyObject
        }
        if let sido = sido {
            dict["sidoCode"] = "\(sido.code)" as AnyObject
        }
        if let gungu = gungu {
            dict["gungu"] = "\(gungu.code)" as AnyObject
        }
        return dict
    }
}


