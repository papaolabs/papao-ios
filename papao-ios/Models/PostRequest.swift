//
//  PostRequest.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 9..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

struct PostRequest {
    // Required
    var happenDate: String                      // 발견날짜 (yyyyMMdd)
    var happenPlace: String                     // 발견장소 (주소 문자열)
    var uid : Int                               // Post ID
    var imageUrls: [String: AnyObject] = [:]    // 사진 URL
    var postType: String                        // Post 타입
    
    // Optional
    var upKindCode: Int?                        // 축종코드
    var kindCode: Int?                          // 품종코드
    var contact: String?                        // 연락처
    
    var genderType: String?                     // 성별
    var neuterType: String?                     // 중성화
    var age: Int?                               // 출생년도
    var weight: Float?                          // 몸무게
    var feature: String?                        // 특징
    
    var sidoCode: Int?                          // 시도
    var gunguCode: Int?                         // 군구
    
    // MARK: - For UI
    var images: [UIImage]?
    
    init() {
        happenDate = ""
        happenPlace = ""
        uid = -1
        postType = PostType.ROADREPORT.rawValue
    }

    func toDict() -> [String: AnyObject] {
        // Todo: - imageUrls 처리
        return [
            "happenDate": happenDate as AnyObject,
            "happenPlace": happenPlace as AnyObject,
            "uid": uid as AnyObject,
            "postType": postType as AnyObject,
            "imageUrls": ["http://www.animal.go.kr/files/shelter/2017/11/20171114091119.jpg"] as AnyObject,
            "upKindCode": upKindCode as AnyObject,
            "kindCode": kindCode as AnyObject,
            "contact": contact as AnyObject,
            "genderType": genderType as AnyObject,
            "neuterType": neuterType as AnyObject,
            "age": age as AnyObject,
            "weight": weight as AnyObject,
            "feature": feature as AnyObject,
            "sidoCode": sidoCode as AnyObject,
            "gunguCode": gunguCode as AnyObject
        ]
    }
}
