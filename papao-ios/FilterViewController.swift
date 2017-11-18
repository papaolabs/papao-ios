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
    @IBOutlet weak var beginDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    
    var filter: Filter?
    var genderList: [Gender] = [Gender.M, Gender.F, Gender.A]
    var breedList: [PublicDataProtocol]!
    var sidoList: [PublicDataProtocol]!
    var currentSido: Sido?
    
    // for input the date
    var comp = NSDateComponents()
    private let beginDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    
    fileprivate var picker: PPOPicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set date pickers
        setBeginDatePicker()
        setEndDatePicker()
        
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
        
        // 기존 필터 데이터 화면에 적용
        if let filter = self.filter {
            if filter.species == .DOG {
                dogButtonPressed(dogButton)
            } else if filter.species == .CAT {
                catButtonPressed(catButton)
            } else if filter.species == .ETC {
                etcButtonPressed(etcButton)
            }
            
            if let breed = filter.breed {
                breedButton.setTitle(breed.name, for: .normal)
            }
            
            for (index, element) in genderList.enumerated() {
                if (filter.genderType == element) {
                    genderSegment.selectedSegmentIndex = index
                }
            }
            
            if let sido = filter.sido {
                sidoButton.setTitle(sido.name, for: .normal)
            }
            if let gungu = filter.gungu {
                gunguButton.setTitle(gungu.name, for: .normal)
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let beginDate = filter.beginDate {
                beginDateTextField.text = formatter.string(from: beginDate)
            }
            if let endDate = filter.endDate {
                endDateTextField.text = formatter.string(from: endDate)
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func dogButtonPressed(_ sender: PPOBadge) {
        self.filter?.species = SpeciesName.DOG
        sender.isSelected = true
        catButton.isSelected = false
        etcButton.isSelected = false
    }
    
    @IBAction func catButtonPressed(_ sender: PPOBadge) {
        self.filter?.species = SpeciesName.CAT
        sender.isSelected = true
        dogButton.isSelected = false
        etcButton.isSelected = false
    }
    
    @IBAction func etcButtonPressed(_ sender: PPOBadge) {
        self.filter?.species = SpeciesName.ETC
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
        filter?.genderType = genderList[sender.selectedSegmentIndex]
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

    // MARK: - Private methods
    fileprivate func clearGungu() {
        filter?.gungu = nil
        gunguButton.setTitle("전체", for: .normal)
    }
    
    fileprivate func setBeginDatePicker() {
        //Formate Date
        beginDatePicker.datePickerMode = .date
        beginDatePicker.calendar = Calendar.autoupdatingCurrent
        beginDatePicker.locale = Locale.init(identifier: "kr_KR")
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(doneBeginDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        beginDateTextField.inputAccessoryView = toolbar
        beginDateTextField.inputView = beginDatePicker
    }
    
    @objc func doneBeginDatePicker() {
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        beginDateTextField.text = formatter.string(from: beginDatePicker.date)
        
        // set date for Post instance
        formatter.dateFormat = "yyyyMMdd"
        filter?.beginDate = beginDatePicker.date
        
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    fileprivate func setEndDatePicker() {
        //Formate Date
        endDatePicker.datePickerMode = .date
        endDatePicker.calendar = Calendar.autoupdatingCurrent
        endDatePicker.locale = Locale.init(identifier: "kr_KR")
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(doneEndDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        endDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputView = endDatePicker
    }
    
    @objc func doneEndDatePicker() {
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        endDateTextField.text = formatter.string(from: endDatePicker.date)
        
        // set date for Post instance
        formatter.dateFormat = "yyyyMMdd"
        filter?.endDate = endDatePicker.date
        
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
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
                    filter?.breed = breed
                }
            case PickerName.SidoPicker.rawValue:
                if let sido = selectedPublicData as? Sido {
                    filter?.sido = sido
                    
                    // 군구 선택을 위한 설정
                    currentSido = sido
                    clearGungu()
                }
            case PickerName.GunguPicker.rawValue:
                if let gungu = selectedPublicData as? Gungu {
                    filter?.gungu = gungu
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
