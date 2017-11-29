//
//  ImageResponse.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 24..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import Foundation

struct ImageResponse {
    var status: String
    var imageUrls: [String]
    var species: Species?
    var breed: Breed?
    
    init(json: [String: Any]) {
        if let status = json["status"] as? String {
            self.status = status
        } else {
            self.status = ""
        }
        if let imageUrls = json["image_url"] as? [String] {
            self.imageUrls = imageUrls
        } else {
            self.imageUrls = []
        }
        
        if let speciesCode = json["kind_code"] as? Int, let speciesName = SpeciesName(rawValue: speciesCode) {
            self.species = Species.init(dict: ["code": speciesName.rawValue as AnyObject, "name": speciesName.description as AnyObject])
        }
        
        if let breedCode = json["kind_code"] as? Int, let species = self.species {
            self.breed = species.getBreed(code: breedCode)
        }
    }
}
