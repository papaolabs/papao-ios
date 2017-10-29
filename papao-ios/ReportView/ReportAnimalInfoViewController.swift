//
//  ReportAnimalInfoViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 27..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportAnimalInfoViewController: UIViewController {
    var breedList: [Breed]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "BreedList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            print(dict)
            if let breedList: [AnyObject] = dict["Breed"] as? [AnyObject] {
                self.breedList = breedList.map({ (dict) -> Breed in
                    return Breed(dict: dict as! [String : AnyObject])
                })
            }
        }
    }
}
