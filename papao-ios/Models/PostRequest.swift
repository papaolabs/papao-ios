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
    var uid : String                            // Post ID
    var imageUrls: [String]    // 사진 URL
    var postType: PostType                      // Post 타입
    
    // Optional
    var species: Species?                       // 축종코드
    var breed: Breed?                           // 품종
    var contact: String?                        // 연락처
    
    var genderType: Gender?                     // 성별
    var neuterType: Neuter?                     // 중성화
    var age: Age?                               // 출생년도
    var weight: Float?                          // 몸무게
    var feature: String?                        // 특징
    
    var sido: Sido?                          // 시도
    var gungu: Gungu?                         // 군구
    
    // MARK: - For UI
    var images: [UIImage]?
    
    init() {
        happenDate = ""
        happenPlace = ""
        uid = "-1"
        postType = PostType.ROADREPORT
        imageUrls = []
    }

    func toDict() -> [String: AnyObject] {
        // Todo: - imageUrls 처리
        return [
            "happenDate": happenDate as AnyObject,
            "happenPlace": happenPlace as AnyObject,
            "uid": uid as AnyObject,
            "postType": postType.rawValue as AnyObject,
            "imageUrls": imageUrls as AnyObject,
            "upKindCode": (species?.code ?? SpeciesName.ETC.rawValue) as AnyObject,
            "kindCode": (breed?.code ?? -1) as AnyObject,
            "contact": contact as AnyObject,
            "genderType": (genderType?.rawValue ?? Gender.Q.rawValue) as AnyObject,
            "neuterType": (neuterType?.rawValue ?? Neuter.U.rawValue) as AnyObject,
            "age": (age?.name ?? "-1") as AnyObject,
            "weight": (weight ?? -1) as AnyObject,
            "feature": (feature ?? "") as AnyObject,
            "sidoCode": (sido?.code ?? -1) as AnyObject,
            "gunguCode": (gungu?.code ?? -1) as AnyObject
        ]
    }
}
