//
//  FilterViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    var regionList: [PublicDataProtocol]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create species list
        if let path = Bundle.main.path(forResource: "RegionList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let regions: [AnyObject] = dict["Region"] as? [AnyObject] {
                self.regionList = regions.map({ (dict) -> Sido in
                    return Sido(dict: dict as! [String: AnyObject])
                })
            }
        }
    }
}
