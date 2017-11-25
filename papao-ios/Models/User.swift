//
//  User.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 16..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

enum PushType: String {
    case GUEST = "GUEST"
    case USER = "USER"
}

class User: NSObject, NSCoding {
    var id: String
    var nickname: String
    var phone: String
    var profileUrl: String?
    var devicesToken: [String]
    
    init?(json: [String: Any]?) {
        guard let json = json,
            let id = json["userId"] as? String,
            let phone = json["phone"] as? String else {
                return nil
        }
        
        self.id = id
        if let nickName = json["nickname"] as? String {
            self.nickname = nickName
        } else {
            self.nickname = "말많은 프렌치불독"
        }

        self.phone = phone
        
        if let devicesToken = json["devicesToken"] as? [String] {
            self.devicesToken = devicesToken
        } else {
            self.devicesToken = []
        }
        
        if let profileUrl = json["profileUrl"] as? String {
            self.profileUrl = profileUrl
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(nickname, forKey: "nickname")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(profileUrl, forKey: "profileUrl")
        aCoder.encode(devicesToken, forKey: "devicesToken")
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        nickname = aDecoder.decodeObject(forKey: "nickname") as? String ?? ""
        phone = aDecoder.decodeObject(forKey: "phone") as? String ?? ""
        profileUrl = aDecoder.decodeObject(forKey: "profileUrl") as? String ?? ""
        devicesToken = aDecoder.decodeObject(forKey: "devicesToken") as? [String] ?? []
    }
}

