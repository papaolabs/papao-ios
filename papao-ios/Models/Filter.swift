//
//  Filter.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Filter {
    var postType: [String]    // 포스트타입 리스트
    var upKindCode: String    // 축종코드
    var kindCode: String      // 품종코드
    var genderType: String    // 성별(M,F,Q)
    var beginDate: String     // yyyyMMdd
    var endDate: String       // yyyyMMdd
    var sidoCode: String      // 시도코드
    var gunguCode: String     // 군구코드
    
    init(postTypes: [String]) {
        self.postType = postTypes
        upKindCode = ""
        kindCode = ""
        genderType = ""
        beginDate = ""
        endDate = ""
        sidoCode = ""
        gunguCode = ""
    }
    
    func toDict() -> [String: AnyObject] {
        return [
            "postType": postType as AnyObject,
            "upKindCode": upKindCode as AnyObject,
            "kindCode": kindCode as AnyObject,
            "genderType": genderType as AnyObject,
            "beginDate": beginDate as AnyObject,
            "endDate": endDate as AnyObject,
            "sidoCode": sidoCode as AnyObject,
            "gunguCode": gunguCode as AnyObject
        ]
    }
}


