//
//  ImageRequest.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 24..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

struct ImageRequest {
    var file: [UIImage]!
    var postType: PostType
    
    func toDict() -> [String: AnyObject] {
        let dataList = file.map { (image) -> Data in
            return UIImagePNGRepresentation(image)!
        }
        return [
            "file": dataList as AnyObject,
            "post_type": postType.rawValue as AnyObject
        ]
    }
}
