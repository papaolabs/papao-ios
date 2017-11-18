//
//  FilterViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    @IBOutlet weak var dogButton: PPOBadge!
    @IBOutlet weak var catButton: PPOBadge!
    @IBOutlet weak var etcButton: PPOBadge!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    var filter = Filter.init()
    var genderList: [Gender] = [Gender.M, Gender.F, Gender.A]
    var breedList: [PublicDataProtocol]!
    var regionList: [PublicDataProtocol]!
    
    fileprivate var picker: PPOPicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customizing some buttons
        dogButton.setStyle(type: .medium)
        catButton.setStyle(type: .medium)
        etcButton.setStyle(type: .medium)
        
        // create breed list
        if let path = Bundle.main.path(forResource: "BreedList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let breedList: [AnyObject] = dict["Breed"] as? [AnyObject] {
                self.breedList = breedList.map({ (dict) -> Breed in
                    return Breed(dict: dict as! [String: AnyObject])
                })
            }
        }
        
        // create region list
        if let path = Bundle.main.path(forResource: "RegionList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let regions: [AnyObject] = dict["Region"] as? [AnyObject] {
                self.regionList = regions.map({ (dict) -> Sido in
                    return Sido(dict: dict as! [String: AnyObject])
                })
            }
        }
        
        // set segment for selecting Gender
        for (index, element) in genderList.enumerated() {
            genderSegment.setTitle(element.description, forSegmentAt: index)
        }
    }
    
    // MARK: - IBActions
    @IBAction func dogButtonPressed(_ sender: PPOBadge) {
        self.filter.species = "\(SpeciesName.DOG.rawValue)"
        sender.isSelected = true
        catButton.isSelected = false
        etcButton.isSelected = false
    }
    
    @IBAction func catButtonPressed(_ sender: PPOBadge) {
        self.filter.species = "\(SpeciesName.CAT.rawValue)"
        sender.isSelected = true
        dogButton.isSelected = false
        etcButton.isSelected = false
    }
    
    @IBAction func etcButtonPressed(_ sender: PPOBadge) {
        self.filter.species = "\(SpeciesName.ETC.rawValue)"
        sender.isSelected = true
        dogButton.isSelected = false
        catButton.isSelected = false
    }
    
    @IBAction func breedButtonPressed(_ sender: Any) {

    }
    
    @IBAction func genderSegmentChanged(_ sender: UISegmentedControl) {
        filter.gender = genderList[sender.selectedSegmentIndex].rawValue
    }
    
    @IBAction func sidoButtonPressed(_ sender: Any) {
    }
    
    @IBAction func gunguButtonPressed(_ sender: Any) {
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        print(filter)
    }
}
