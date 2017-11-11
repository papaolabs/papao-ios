//
//  Post.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 11..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Post {
    var id : Int                    // Post ID
    var stateType: String?          // 보호 상태
    var genderType: String?         // 성별
    var imageUrls: [[String: Any]] = []    // 사진 URL

    var happenDate: String          // 발견날짜 (yyyyMMdd)
    var happenPlace: String         // 발견장소 (주소 문자열)
    
    var kindName: String?           // 품종 이름
    
    var commentCount: Int?
    var hitCount: Int?              // 조회수
    var createdDate: String?        // 등록 날짜
    var updatedDate: String?        // 수정 날짜
    
    init?(json: [String: Any]) {
        guard let imageUrls = json["imageUrls"] as? [[String: Any]],
            let happenDate = json["happenDate"] as? String,
            let happenPlace = json["happenPlace"] as? String,
            let id = json["id"] as? Int else {
                return nil
        }

        for imageUrl: [String: Any] in imageUrls {
            self.imageUrls.append(imageUrl)
        }
        self.happenDate = happenDate
        self.happenPlace = happenPlace
        self.id = Int(id)
        
        
        self.stateType = json["stateType"] as? String
        
        self.genderType = json["gender"] as? String
        
        self.kindName = json["kindName"] as? String

        if let commentCount = json["commentCount"] as? Int {
            self.commentCount = Int(commentCount)
        }
        
        if let hitCount = json["hitCount"] as? Int {
            self.hitCount = Int(hitCount)
        }
        
        self.createdDate = json["weight"] as? String
        self.updatedDate = json["weight"] as? String
    }
}
