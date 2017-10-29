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
    var speciesList: [Species]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create species list
        if let path = Bundle.main.path(forResource: "SpeciesList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let speciesList: [AnyObject] = dict["Species"] as? [AnyObject] {
                self.speciesList = speciesList.map({ (dict) -> Species in
                    return Species(dict: dict as! [String: AnyObject])
                })
            }
        }
        
        // create breed list
        if let path = Bundle.main.path(forResource: "BreedList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let breedList: [AnyObject] = dict["Breed"] as? [AnyObject] {
                self.breedList = breedList.map({ (dict) -> Breed in
                    return Breed(dict: dict as! [String: AnyObject])
                })
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func speciesButtonPressed(_ sender: Any) {
    }
    
    @IBAction func breedButtonPressed(_ sender: Any) {
    }
    
}
