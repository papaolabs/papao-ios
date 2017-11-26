//
//  Region.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Sido: PublicDataProtocol {
    var code: Int
    var name: String
    var towns: [Gungu] = []
    
    init(dict: [String: AnyObject]) {
        if let towns = dict["towns"] as? [[String : AnyObject]] {
            self.towns = towns.map({ (town) -> Gungu in
                return Gungu(dict: town)
            })
        }
        
        self.code = dict["code"] as! Int
        self.name = dict["name"] as! String
    }
    
    init?(name: String) {
        // 시도 이름으로 초기화
        if let path = Bundle.main.path(forResource: "RegionList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let regions: [AnyObject] = dict["Region"] as? [AnyObject] {
                if let sido = regions.map({ (dict) -> Sido in
                    return Sido(dict: dict as! [String: AnyObject])
                }).first(where: {$0.name == name}) {
                    self.code = sido.code
                    self.name = sido.name
                    self.towns = sido.towns
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getGungu(name: String) -> Gungu? {
        if let gungu = self.towns.first(where: {$0.name == name}) {
            return gungu
        } else {
            return nil
        }
    }
}

struct Gungu: PublicDataProtocol {
    var code: Int
    var name: String
    
    init(dict: [String: AnyObject]) {
        self.code = dict["code"] as! Int
        self.name = dict["name"] as! String
    }
}
