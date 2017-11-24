//
//  ImageRequest.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 24..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct ImageRequest {
    var file: [Data]!
    var postType: PostType
    
    func toDict() -> [String: AnyObject] {
        return [
            "file": file as AnyObject,
            "post_type": postType.rawValue as AnyObject
        ]
    }
}
