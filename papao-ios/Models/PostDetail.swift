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
    var stateType: String?          // 보호 상태
    var postType: String?           // Post 타입
    var genderType: String?         // 성별
    var neuterType: String?         // 중성화 여부
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
    var weight: Float?              // 몸무게 Float
    
    var commentCount: Int?
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
        self.stateType = json["stateType"] as? String
        self.postType = json["postType"] as? String
        self.genderType = json["genderType"] as? String
        self.neuterType = json["neuterType"] as? String
        
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
    
    /**
     표시할 수 있는 텍스트 정보 수 반환
     Todo: - 로직 추가 필요
     **/
    func countOfTextInfo() -> Int! {
        var count = 0
        if (feature != nil && feature != "") { count += 1 }
        if (kindName != nil && kindName != "") { count += 1 }
        if (happenPlace != nil && happenPlace != "") { count += 1 }
        return count
    }
}

