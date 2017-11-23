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

struct User {
    var id: String
    var nickName: String
    var phone: String
    var profileUrl: String?
    var devicesToken: [String]?
    
    init?(json: [String: Any]?) {
        guard let json = json,
            let id = json["userId"] as? String,
            let phone = json["phone"] as? String else {
                return nil
        }
        
        self.id = id
        if let nickName = json["nickname"] as? String {
            self.nickName = nickName
        } else {
            self.nickName = "말많은 프렌치불독"
        }

        self.phone = phone
        
        if let devicesToken = json["devicesToken"] as? [String] {
            self.devicesToken = devicesToken
        }
        
        if let profileUrl = json["profileUrl"] as? String {
            self.profileUrl = profileUrl
        }
    }
}
