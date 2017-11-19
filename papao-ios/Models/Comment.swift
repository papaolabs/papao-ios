//
//  Comment.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Comment {
    var postId: Int
    var contents: [Content]?
    
    init?(json: [String: Any]) {
        guard let id = json["postId"] as? Int else {
            return nil
        }
        
        self.postId = id
        
        if let contents = json["contents"] as? [[String: AnyObject]] {
            self.contents = contents.map({ (item) -> Content in
                return Content.init(json: item)
            })
        }
    }

    var count: Int {
        if let contents = self.contents {
            return contents.count
        }
        return 0
    }
}

struct Content {
    var id: Int
    var userId: String
    var text: String
    var createdDate: String
    var lastModifiedDate: String
    
    init(json: [String: Any]) {
        if let id = json["id"] as? Int {
            self.id = id
        } else {
            self.id = -1
        }
        if let userId = json["userId"] as? String {
            self.userId = userId
        } else {
            self.userId = ""
        }
        if let text = json["text"] as? String {
            self.text = text
        } else {
            self.text = ""
        }
        if let createdDate = json["createdDate"] as? String {
            self.createdDate = createdDate
        } else {
            self.createdDate = ""
        }
        if let lastModifiedDate = json["updatedDate"] as? String {
            self.lastModifiedDate = lastModifiedDate
        } else {
            self.lastModifiedDate = ""
        }
    }
}
