//
//  Statistics.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 21..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

enum StatisticsType {
    case adoption
    case euthanasia
    case naturalDeath
    case returnPet
    
    var keyName: String {
        get { return String(describing: self) }
    }
    
    var description: String {
        switch self {
        case .adoption:
            return "입양률"
        case .euthanasia:
            return "안락사율"
        case .naturalDeath:
            return "자연사율"
        case .returnPet:
            return "반환율"
        }
    }
    
    var chartColorString: (String, String) {
        switch self {
        case .adoption:
            return ("darkishPink", "lightPink")
        case .euthanasia:
            return ("darkSkyBlue", "babyBlue")
        case .naturalDeath:
            return ("tangerineOrange", "eggShell")
        case .returnPet:
            return ("coolBlue", "lightSkyBlue")
        }
    }
    
    var backgroundColorString: String {
        switch self {
        case .adoption:
            return "warmPink"
        case .euthanasia:
            return "skyBlue"
        case .naturalDeath:
            return "pastelOrange"
        case .returnPet:
            return "seafoamBlue"
        }
    }
}

struct Statistics {
    var adoptionCount: Int
    var beginDate: Date
    var endDate: Date
    var euthanasiaCount: Int
    var naturalDeathCount: Int
    var returnCount: Int
    var saveCount: Int
    var totalCount: Int
    var unknownCount: Int
    
    init(json: [String: Any]) {
        if let adoptionCount = json["adoptionCount"] as? Int {
            self.adoptionCount = adoptionCount
        } else {
            self.adoptionCount = 0
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if let beginDateString = json["beginDate"] as? String, let beginDate = formatter.date(from: beginDateString) {
            self.beginDate = beginDate
        } else {
            self.beginDate = Date()
        }
        
        if let endDateString = json["endDate"] as? String, let endDate = formatter.date(from: endDateString) {
            self.endDate = endDate
        } else {
            self.endDate = Date()
        }
        
        if let euthanasiaCount = json["euthanasiaCount"] as? Int {
            self.euthanasiaCount = euthanasiaCount
        } else {
            self.euthanasiaCount = 0
        }
        
        if let naturalDeathCount = json["naturalDeathCount"] as? Int {
            self.naturalDeathCount = naturalDeathCount
        } else {
            self.naturalDeathCount = 0
        }
        
        if let returnCount = json["returnCount"] as? Int {
            self.returnCount = returnCount
        } else {
            self.returnCount = 0
        }
        
        if let saveCount = json["saveCount"] as? Int {
            self.saveCount = saveCount
        } else {
            self.saveCount = 0
        }
        
        if let totalCount = json["totalCount"] as? Int {
            self.totalCount = totalCount
        } else {
            self.totalCount = 0
        }
        
        if let unknownCount = json["unknownCount"] as? Int {
            self.unknownCount = unknownCount
        } else {
            self.unknownCount = 0
        }
    }
    
    func getRate(statisticsType: StatisticsType) -> Int {
        guard totalCount > 0 else {
            return 0
        }
        switch statisticsType {
        case .adoption:
            return 100 * adoptionCount / totalCount
        case .euthanasia:
            return 100 * euthanasiaCount / totalCount
        case .naturalDeath:
            return 100 * naturalDeathCount / totalCount
        case .returnPet:
            return 100 * returnCount / totalCount
        }
    }
}
