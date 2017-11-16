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
            let nickName = json["nickName"] as? String,
            let phone = json["phone"] as? String,
            let push = json["push"] as? Bool else {
                return nil
        }
        
        self.id = id
        self.nickName = nickName
        self.phone = phone
        self.push = push
    }
}
