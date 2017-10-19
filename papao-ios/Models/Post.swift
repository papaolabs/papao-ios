//
//  Post.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct Post {
    var feature: String?
    var gender: String?
    var happenDate: String?
    var happenPlace: String?
    var id : Int
    var imageUrl: String?
    var introduction: String?
    var kindCode: String?
    var kindName: String?
    var kindUpCode: String?
    var neuter: String?
    var state: String?
    var type: String?
    var userAddress: String?
    var userContact: String?
    var userName: String?
    var weight: String?
    
    init(_ postDict: Dictionary<String, String>) {
        self.feature = postDict["feature"]
        self.gender = postDict["gender"]
        self.happenDate = postDict["happenDate"]
        self.happenPlace = postDict["happenPlace"]
        self.id = Int(postDict["id"]!)!
        self.imageUrl = postDict["imageUrl"]
        self.introduction = postDict["introduction"]
        self.kindCode = postDict["kindCode"]
        self.kindName = postDict["kindName"]
        self.kindUpCode = postDict[""]
        self.neuter = postDict["neuter"]
        self.state = postDict["state"]
        self.type = postDict["type"]
        self.userAddress = postDict["userAddress"]
        self.userContact = postDict["userContact"]
        self.weight = postDict["weight"]
    }
    
    /**
     표시할 수 있는 텍스트 정보 수 반환
     Todo: - 로직 추가 필요
     **/
    let countOfTextInfo: Int! = {
        var count = 1
        return count
    }()
}
