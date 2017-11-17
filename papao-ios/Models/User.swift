//
//  User.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 16..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct User {
    var id: String
    var nickName: String
    var phone: String
    var push: Bool
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let phone = json["phone"] as? String else {
                return nil
        }
        
        self.id = id
        if let nickName = json["nickName"] as? String {
            self.nickName = nickName
        } else {
            self.nickName = "말많은 프렌치불독"
        }

        self.phone = phone
        
        if let push = json["push"] as? Bool {
            self.push = push
        } else {
            self.push = false
        }
    }
}
