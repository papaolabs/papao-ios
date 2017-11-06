//
//  Post.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

enum Type: String {
    case SYSTEM = "SYSTEM"
    case PROTECTING = "PROTECTING"
    case ROADREPORT = "ROADREPORT"
    case MISSING = "MISSING"

    var keyName: String {
        get { return String(describing: self) }
    }
    
    var description: String {
        switch self {
        case .SYSTEM:
            return "보호소"
        case .PROTECTING:
            return "개인보호"
        case .ROADREPORT:
            return "제보"
        case .MISSING:
            return "실종"
        }
    }
}

enum Neuter: String {
    case Y = "Y"
    case N = "N"
    case U = "U"
    
    var keyName: String {
        get { return String(describing: self) }
    }
    
    var description: String {
        switch self {
        case .Y:
            return "중성화 O"
        case .N:
            return "중성화 X"
        case .U:
            return "모름"
        }
    }
}

enum Gender: String {
    case M = "M"
    case F = "F"
    case Q = "Q"
    
    var keyName: String {
        get { return String(describing: self) }
    }
    
    var description: String {
        switch self {
        case .M:
            return "수컷"
        case .F:
            return "암컷"
        case .Q:
            return "모름"
        }
    }
}

struct Post {
    // MARK: - Required
    var happenDate: String          // 발견날짜 (yyyyMMdd)
    var happenPlace: String         // 발견장소 (주소 문자열)
    var id : Int                    // Post ID
    var imageUrls: [String] = []    // 사진 URL
    var kindUpCode: String          // 축종코드
    var type: String                // Post 타입

    // MARK: - Optional
    var age: String?                // 나이
    var feature: String?            // 특징(메모)
    var kindCode: String?           // 품종코드
    var kindName: String?           // 품종 이름
    var gender: String?             // 성별
    var introduction: String?       // 소개
    var neuter: String?             // 중성화 여부
    var state: String?              // 보호 상태
    var userAddress: String?        // 유저 주소
    var userContact: String?        // 유저 연락처
    var userName: String?           // 유저 이름
    var weight: String?             // 몸무게 Float
    
    // MARK: - For UI
    var images: [UIImage]?
    
    init() {
        self.happenDate = ""
        self.happenPlace = ""
        self.id = -1
        self.kindUpCode = ""
        self.type = "01"
    }
    
    init(fromDict postDict: Dictionary<String, AnyObject>) {
        self.happenDate = postDict["happenDate"] as! String
        self.happenPlace = postDict["happenPlace"] as! String
        self.id = Int(postDict["id"] as! Int)
        for imageUrl in postDict["imageUrls"] as! [String] {
            self.imageUrls.append(imageUrl)
        }
        self.kindUpCode = postDict["kindUpCode"] as! String
        self.type = postDict["type"] as! String
        
        self.age = postDict["age"] as? String
        self.feature = postDict["feature"] as? String
        self.gender = postDict["gender"] as? String
        self.introduction = postDict["introduction"] as? String
        self.kindCode = postDict["kindCode"] as? String
        self.kindName = postDict["kindName"] as? String
        self.neuter = postDict["neuter"] as? String
        self.state = postDict["state"] as? String
        self.userAddress = postDict["userAddress"] as? String
        self.userContact = postDict["userContact"] as? String
        self.userName = postDict["userName"] as? String
        self.weight = postDict["weight"] as? String
    }
    
    /**
     표시할 수 있는 텍스트 정보 수 반환
     Todo: - 로직 추가 필요
     **/
    func countOfTextInfo() -> Int! {
        var count = 0
        if (feature != nil && feature != "") { count += 1 }
        if (kindName != nil && kindName != "") { count += 1 }
        if (happenPlace != nil && happenPlace != "") { count += 1 }
        if (userName != nil && userName != "") { count += 1 }
        if (userContact != nil && userContact != "") { count += 1 }
        return count
    }
}

