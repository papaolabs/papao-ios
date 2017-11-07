//
//  APIKeys.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 23..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

func valueForAPIKey(keyname keyname: String) -> String {
    let filePath = Bundle.main.path(forResource: "keys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filePath!)
    let value: String = plist?.object(forKey: keyname) as! String
    return value
}
