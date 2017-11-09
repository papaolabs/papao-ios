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
    var kindUpCode: String?                     // 축종코드
    var kindCode: Int?                          // 품종코드
    var feature: String?                        // 특징
    var gender: String?                         // 성별
    var neuter: String?                         // 중성화
    var age: Int?                               // 출생년도
    var weight: Float?                          // 몸무게
    var sidoCode: Int?                          // 시도
    var gunguCode: Int?                         // 군구
    
    // MARK: - For UI
    var images: [UIImage]?
}
