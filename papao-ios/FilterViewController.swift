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
    @IBOutlet weak var breedButton: PPOPickerButton!
    @IBOutlet weak var sidoButton: PPOPickerButton!
    @IBOutlet weak var gunguButton: PPOPickerButton!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    var filter = Filter.init()
    var genderList: [Gender] = [Gender.M, Gender.F, Gender.A]
    var breedList: [PublicDataProtocol]!
    var sidoList: [PublicDataProtocol]!
    var currentSido: Sido?
    
    fileprivate var picker: PPOPicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customizing some buttons
        dogButton.setStyle(type: .medium)
        catButton.setStyle(type: .medium)
        etcButton.setStyle(type: .medium)
        
        // set Indice to caller buttons to specify data
        breedButton.tag = PickerName.BreedPicker.rawValue
        sidoButton.tag = PickerName.SidoPicker.rawValue
        gunguButton.tag = PickerName.GunguPicker.rawValue

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
                self.sidoList = regions.map({ (dict) -> Sido in
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
    
    @IBAction func breedButtonPressed(_ sender: UIButton) {
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [breedList])
        picker?.startPicking()
    }
    
    @IBAction func genderSegmentChanged(_ sender: UISegmentedControl) {
        filter.gender = genderList[sender.selectedSegmentIndex].rawValue
    }
    
    @IBAction func sidoButtonPressed(_ sender: UIButton) {
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [sidoList])
        picker?.startPicking()
    }
    
    @IBAction func gunguButtonPressed(_ sender: UIButton) {
        guard let towns = currentSido?.towns else {
            return
        }
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [towns])
        picker?.startPicking()
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        print(filter)
    }
    
    // MARK: - Private methods
    fileprivate func clearGungu() {
        filter.gunguCode = ""
        gunguButton.setTitle("전체", for: .normal)
    }
}

extension FilterViewController: PPOPickerDelegate {
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
            case PickerName.BreedPicker.rawValue:
                if let breed = selectedPublicData as? Breed {
                    filter.breed = "\(breed.code)"
                }
            case PickerName.SidoPicker.rawValue:
                if let sido = selectedPublicData as? Sido {
                    filter.sidoCode = "\(sido.code)"
                    
                    // 군구 선택을 위한 설정
                    currentSido = sido
                    clearGungu()
                }
            case PickerName.GunguPicker.rawValue:
                if let gungu = selectedPublicData as? Gungu {
                    filter.gunguCode = "\(gungu.code)"
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
}
