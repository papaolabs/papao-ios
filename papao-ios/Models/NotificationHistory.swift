//
//  NotificationHistory.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

enum MessageType: String {
    case search = "SEARCH"
    case alarm = "ALARM"
    case bookmark = "BOOKMARK"
}

struct NotificationHistory {
    var userId: Int
    var pushLogs: [PushLog]
    
    init(json: [String: Any]) {
        if let userId = json["userId"] as? Int {
            self.userId = userId
        } else {
            self.userId = -1
        }

        if let pushLogs = json["pushLogs"] as? [[String: Any]] {
            self.pushLogs = pushLogs.map({ (item) -> PushLog in
                return PushLog.init(json: item)
            })
        } else {
            self.pushLogs = []
        }
    }
}

struct PushLog {
    var id: Int
    var postId: Int
    var message: String
    var type: MessageType
    var createdDate: String
    var updatedDate: String
    
    init(json: [String: Any]) {
        if let id = json["id"] as? Int {
            self.id = id
        } else {
            self.id = -1
        }
        if let postId = json["postId"] as? Int {
            self.postId = postId
        } else {
            self.postId = -1
        }
        if let type = json["type"] as? String {
            self.type = MessageType(rawValue: type) ?? MessageType.search
        } else {
            self.type = MessageType.search
        }
        if let message = json["message"] as? String {
            self.message = message
        } else {
            self.message = ""
        }
        if let createdDate = json["createdDate"] as? String {
            self.createdDate = createdDate
        } else {
            self.createdDate = ""
        }
        if let updatedDate = json["updatedDate"] as? String {
            self.updatedDate = updatedDate
        } else {
            self.updatedDate = ""
        }
    }
}

