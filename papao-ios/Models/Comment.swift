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
    var contents: [Content]
}

struct Content {
    var id: Int
    var userId: String
    var text: String
    var createdDate: String
    var lastModifiedDate: String
}
