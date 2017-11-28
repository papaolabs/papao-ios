//
//  ImageInfo.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 23..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct ImageInfo {
    var date: String?
    var latitude: Double?
    var longitude: Double?
    
    init(_ dict: NSDictionary) {
        if let exif = dict["{Exif}"] as? [String: Any] {
            if let date = exif["DateTimeOriginal"] {
                self.date = date as? String
            }
        }
        if let gps = dict["{GPS}"] as? [String: Any] {
            if let latitude = gps["Latitude"] {
                self.latitude = latitude as? Double
            }
            if let longitude = gps["Longitude"] {
                self.longitude = longitude as? Double
            }
        }
    }
}
