//
//  Post.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

enum PostType: String {
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
            return "임시보호"
        case .ROADREPORT:
            return "길거리 제보"
        case .MISSING:
            return "실종"
        }
    }
}

enum State: String {
    case PROCESS = "PROCESS"
    case RETURN = "RETURN"
    case NATURALDEATH = "NATURALDEATH"
    case EUTHANASIA = "EUTHANASIA"
    case ADOPTION = "ADOPTION"
    
    var color: UIColor? {
        switch self {
        case .PROCESS:
            return nil
        case .RETURN:
            return UIColor.init(named: "dodgerBlue")
        case .NATURALDEATH:
            return UIColor.init(named: "pinkishGrey")
        case .EUTHANASIA:
            return UIColor.init(named: "borderGray")
        case .ADOPTION:
            return UIColor.init(named: "warmPink")
        }
    }
    
    var keyName: String {
        get { return String(describing: self) }
    }
    
    var description: String {
        switch self {
        case .PROCESS:
            return "보호중"
        case .RETURN:
            return "종료(반환)"
        case .NATURALDEATH:
            return "종료(자연사)"
        case .EUTHANASIA:
            return "종료(안락사)"
        case .ADOPTION:
            return "종료(입양)"
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

struct PostDetail {
    var id : Int                    // Post ID
    var desertionId: String?        // 공공데이터 ID
    var stateType: State            // 보호 상태
    var postType: PostType          // Post 타입
    var genderType: Gender          // 성별
    var neuterType: Neuter          // 중성화 여부
    var imageUrls: [[String: Any]] = []    // 사진 URL

    var feature: String?            // 특징(메모)
    var shelterName: String?        // 보호소 이름
    var managerName: String?        // 유저 이름
    var managerContact: String?     // 유저 연락처

    var happenDate: String          // 발견날짜 (yyyyMMdd)
    var happenPlace: String         // 발견장소 (주소 문자열)

    var upKindName: String          // 축종코드
    var kindName: String?           // 품종 이름

    var sidoName: String?           // 시도
    var gunguName: String?          // 군구

    var age: Int?                   // 출생연도
    var ageDesc: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        
        guard let age = self.age,
              let birthday: Date = formatter.date(from: String(age)) else {
            return "모름"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        let ageYear = ageComponents.year!
        
        if ageYear < 1 {
            return "1살 미만"
        }
        return String(describing: "\(ageYear) 살")
    }
    var weight: Float?              // 몸무게 Float
    
    var commentCount: Int?          // 댓글 수
    var hitCount: Int?              // 조회수
    var createdDate: String?        // 등록 날짜
    var updatedDate: String?        // 수정 날짜
    
    init?(json: [String: Any]) {
        guard let upKindName = json["upKindName"] as? String,
            let imageUrls = json["imageUrls"] as? [[String: Any]],
            let happenDate = json["happenDate"] as? String,
            let happenPlace = json["happenPlace"] as? String,
            let id = json["id"] as? Int else {
                return nil
        }

        self.upKindName = upKindName
        for imageUrl: [String: Any] in imageUrls {
            self.imageUrls.append(imageUrl)
        }
        self.happenDate = happenDate
        self.happenPlace = happenPlace
        self.id = Int(id)
        self.desertionId = json["desertionId"] as? String

        if let stateType = json["stateType"] as? String {
            self.stateType = State(rawValue: stateType) ?? State.PROCESS
        } else {
            self.stateType = State.PROCESS
        }
        
        if let postType = json["postType"] as? String {
            self.postType = PostType(rawValue: postType) ?? PostType.SYSTEM
        } else {
            self.postType = PostType.SYSTEM
        }
        
        if let genderType = json["genderType"] as? String {
            self.genderType = Gender(rawValue: genderType) ?? Gender.Q
        } else {
            self.genderType = Gender.Q
        }
        
        if let neuterType = json["neuterType"] as? String {
            self.neuterType = Neuter(rawValue: neuterType) ?? Neuter.U
        } else {
            self.neuterType = Neuter.U
        }
        
        self.feature = json["feature"] as? String
        self.shelterName = json["shelterName"] as? String
        self.managerName = json["managerName"] as? String
        self.managerContact = json["managerContact"] as? String
        
        self.kindName = json["kindName"] as? String
        
        self.sidoName = json["sidoName"] as? String
        self.gunguName = json["gunguName"] as? String
        
        
        if let age = json["age"] as? Int{
            self.age = age
        } else if let ageString = json["age"] as? String {
            self.age = Int(ageString)
        }
        
        if let weight = json["weight"] as? Float {
            self.weight = weight
        } else if let weightString = json["weight"] as? String {
            self.weight = Float(weightString)
        }
        
        if let commentCount = json["commentCount"] as? Int {
            self.commentCount = commentCount
        } else if let commentCountString = json["commentCount"] as? String {
            self.commentCount = Int(commentCountString)
        }

        if let hitCount = json["hitCount"] as? Int {
            self.hitCount = hitCount
        } else if let hitCountString = json["hitCount"] as? String {
            self.hitCount = Int(hitCountString)
        }
        
        self.createdDate = json["createdDate"] as? String
        self.updatedDate = json["updatedDate"] as? String
    }
}

