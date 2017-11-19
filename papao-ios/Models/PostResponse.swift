//
//  PostResponse.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct PostResponse {
    var totalElements: Int
    var totalPages: Int
    var elements: [Post?]
    
    init(json: [String: Any]) {
        if let totalElements = json["totalElements"] as? Int {
            self.totalElements = totalElements
        } else {
            self.totalElements = 0
        }
        
        if let totalPages = json["totalPages"] as? Int {
            self.totalPages = totalPages
        } else {
            self.totalPages = 0
        }
        
        if let elements = json["elements"] as? [[String: Any]] {
            self.elements = elements.map({ (item) -> Post? in
                return Post.init(json: item)
            })
        } else {
            self.elements = []
        }
    }
}
