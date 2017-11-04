//
//  ReportAnimalInfoViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 27..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

enum PickerName: Int {
    case SpeciesPicker
    case BreedPicker
    case WeightPicker
    case AgePicker
}

class ReportAnimalInfoViewController: UIViewController, PPOPickerDelegate {
    @IBOutlet weak var speciesButton: UIButton!
    @IBOutlet weak var breedButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var neuterSegment: UISegmentedControl!
    
    // instance for posting Post
    var post: Post?
    
    var breedList: [PublicDataProtocol]!
    var speciesList: [PublicDataProtocol]!
    var ageList: [PublicDataProtocol]!
    var weightList: [PublicDataProtocol]!
    
    var genderList: [Gender] = [Gender.M, Gender.F, Gender.Q]
    var neuterList: [Neuter] = [Neuter.Y, Neuter.N, Neuter.U]
    
    fileprivate var picker: PPOPicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set Indice to caller buttons to specify data
        breedButton.tag = PickerName.BreedPicker.rawValue
        speciesButton.tag = PickerName.SpeciesPicker.rawValue
        weightButton.tag = PickerName.WeightPicker.rawValue
        ageButton.tag = PickerName.AgePicker.rawValue
        
        // set segment for selecting Neuter
        for (index, element) in neuterList.enumerated() {
            neuterSegment.setTitle(element.rawValue, forSegmentAt: index)
        }
        
        // set segment for selecting Gender
        for (index, element) in genderList.enumerated() {
            genderSegment.setTitle(element.rawValue, forSegmentAt: index)
        }
        
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
        
        // create weight list
        if let path = Bundle.main.path(forResource: "WeightList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let weightList: [AnyObject] = dict["Weight"] as? [AnyObject] {
                self.weightList = weightList.map({ (dict) -> Weight in
                    return Weight(dict: dict as! [String: AnyObject])
                })
            }
        }
        
        // create age list
        if let path = Bundle.main.path(forResource: "AgeList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let ageList: [AnyObject] = dict["Age"] as? [AnyObject] {
                self.ageList = ageList.map({ (dict) -> Age in
                    return Age(dict: dict as! [String: AnyObject])
                })
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func speciesButtonPressed(_ sender: UIButton) {
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [speciesList])
        picker?.startPicking()
        
    }
    
    @IBAction func breedButtonPressed(_ sender: UIButton) {
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [breedList])
        picker?.startPicking()
    }
    
    @IBAction func ageButtonPressed(_ sender: UIButton) {
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [ageList])
        picker?.startPicking()
    }
    
    @IBAction func weightButtonPressed(_ sender: UIButton) {
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [weightList])
        picker?.startPicking()
    }
    
    @IBAction func genderValueChanged(_ sender: UISegmentedControl) {
        post?.gender = genderList[sender.selectedSegmentIndex].keyName
        print(String(describing: post))
    }
    
    @IBAction func neuterValueChanged(_ sender: UISegmentedControl) {
        post?.neuter = neuterList[sender.selectedSegmentIndex].keyName
        print(String(describing: post))
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        // go to next step with post instance
        guard let reportDetectionInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetectionInfo") as? ReportDetectionInfoViewController else {
            return
        }
        reportDetectionInfoViewController.post = self.post
    }

    // MARK: - PPOPicker Delegate
    @objc func pickerCancelAction() {
        picker?.endPicking()
    }
    
    @objc func pickerSetAction() {
        if let selectedItems = picker?.selectedItems, let callerView = picker?.callerButton {
            print("\(selectedItems)")
            let selectedPublicData: PublicDataProtocol = selectedItems[0]
            callerView.setTitle(selectedPublicData.name, for: .normal)
            
            // set selected data to post instance as picker
            switch callerView.tag {
            case PickerName.SpeciesPicker.rawValue:
                if let species = selectedPublicData as? Species {
                    post?.kindUpCode = String(describing: species.code)
                }
            case PickerName.BreedPicker.rawValue:
                if let breed = selectedPublicData as? Breed {
                    post?.kindCode = String(describing: breed.code)
                    post?.kindName = breed.name
                }
            case PickerName.AgePicker.rawValue:
                if let age = selectedPublicData as? Age {
                    post?.age = age.name
                }
            case PickerName.WeightPicker.rawValue:
                if let weight = selectedPublicData as? Weight {
                    post?.weight = weight.name
                }
            default: break
            }
        }
        picker?.endPicking()
    }
    
    func pickerView(inputAccessoryViewFor pickerView: PPOPicker) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        view.backgroundColor = .white
        let buttonWidth: CGFloat = 100
        
        let cancelButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - buttonWidth - 10, y: 0, width: buttonWidth, height: 40))
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.setTitleColor(.lightGray, for: .highlighted)
        cancelButton.addTarget(self, action: #selector(pickerCancelAction), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        let setButton = UIButton(frame: CGRect(x: 10, y: 0, width: buttonWidth, height: 40))
        setButton.setTitle("선택", for: .normal)
        setButton.setTitleColor(.black, for: .normal)
        setButton.setTitleColor(.lightGray, for: .highlighted)
        setButton.addTarget(self, action: #selector(pickerSetAction), for: .touchUpInside)
        view.addSubview(setButton)
        
        return view
    }
    
    func pickerView(didSelect value: PublicDataProtocol, inRow row: Int, inComponent component: Int, delegatedFrom pickerView: PPOPicker) {
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetectionInfoSegue" {
            if let viewController = segue.destination as? ReportDetectionInfoViewController {
                // pass data to next viewController
                viewController.post = post
            }
        }
    }
}

