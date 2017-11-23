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
    var userId: String?         // userId
    
    var index: String           // 인덱스(Int)
    var size: String            // 개수(Int)
    
    init(postTypes: [PostType]) {
        self.postTypes = postTypes
        
        // 날짜세팅 기본 값(일주일 전 - 오늘)
        let lastWeek = Calendar.current.date(byAdding: .weekday, value: -7, to: Date())
        self.beginDate = lastWeek
        self.endDate = Date()
        
        // 인덱스, 사이즈 기본값 설정
        self.index = "0"
        self.size = "10"
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
        if let genderType = genderType, genderType != .A {
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
        if let userId = userId {
            dict["userId"] = "\(userId)" as AnyObject
        }

        dict["index"] = "\(index)" as AnyObject
        dict["size"] = "\(size)" as AnyObject
        
        return dict
    }
}


