//
//  String+DictionaryFromJson.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 2..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

extension String {
    func dictionaryFromJSON () -> Dictionary<String, AnyObject>? {
        do {
            if let data = self.data(using: .utf8), let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                return dict
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        return nil
    }
}

