//
//  FilterViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 18..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    @IBOutlet weak var speciesButton: PPOPickerButton!
    @IBOutlet weak var breedButton: PPOPickerButton!
    @IBOutlet weak var sidoButton: PPOPickerButton!
    @IBOutlet weak var gunguButton: PPOPickerButton!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var beginDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var dateSegment: UISegmentedControl!

    var filter: Filter?
    var genderList: [Gender] = [Gender.M, Gender.F, Gender.A]
    var speciesList: [PublicDataProtocol]!
    var currentSpecies: Species?
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

        // set Indice to caller buttons to specify data
        speciesButton.tag = PickerName.SpeciesPicker.rawValue
        breedButton.tag = PickerName.BreedPicker.rawValue
        sidoButton.tag = PickerName.SidoPicker.rawValue
        gunguButton.tag = PickerName.GunguPicker.rawValue
    
        // create species list
        if let path = Bundle.main.path(forResource: "SpeciesList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let speciesList: [AnyObject] = dict["Species"] as? [AnyObject] {
                self.speciesList = speciesList.map({ (dict) -> Species in
                    return Species(dict: dict as! [String: AnyObject])
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
            if let species = filter.species {
                speciesButton.setTitle(species.name, for: .normal)
                currentSpecies = species
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
                currentSido = sido
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
    
    @IBAction func speciesButtonPressed(_ sender: UIButton) {
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [speciesList])
        picker?.startPicking()
    }

    @IBAction func breedButtonPressed(_ sender: UIButton) {
        guard let breeds = currentSpecies?.breeds else {
            presentAlert(message: "축종 선택을 먼저 해주세요")
            return
        }

        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [breeds])
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
            presentAlert(message: "시도 선택을 먼저 해주세요")
            return
        }
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [towns])
        picker?.startPicking()
    }

    @IBAction func dateValueChange(_ sender: UISegmentedControl) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        switch sender.selectedSegmentIndex {
        case 0:
            let today = Date()
            filter?.beginDate = today
            filter?.endDate = today
            beginDateTextField.text = formatter.string(from: today)
            endDateTextField.text = formatter.string(from: today)
        case 1:
            let lastWeek = Calendar.current.date(byAdding: .weekday, value: -7, to: Date())
            filter?.beginDate = lastWeek
            beginDateTextField.text = formatter.string(from: lastWeek!)
        case 2:
            let twoWeeksAgo = Calendar.current.date(byAdding: .weekday, value: -14, to: Date())
            filter?.beginDate = twoWeeksAgo
            beginDateTextField.text = formatter.string(from: twoWeeksAgo!)
        case 3:
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            filter?.beginDate = lastMonth
            beginDateTextField.text = formatter.string(from: lastMonth!)
        case 4:
            let lastThreeMonth = Calendar.current.date(byAdding: .month, value: -3, to: Date())
            filter?.beginDate = lastThreeMonth
            beginDateTextField.text = formatter.string(from: lastThreeMonth!)
        case 5:
            let wholePeriod = Calendar.current.date(byAdding: .year, value: -10, to: Date())
            filter?.beginDate = wholePeriod
            beginDateTextField.text = formatter.string(from: wholePeriod!)
        default: break
        }
    }
    
    // MARK: - Private methods
    fileprivate func presentAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    fileprivate func setBeginDatePicker() {
        //Formate Date
        beginDatePicker.datePickerMode = .date
        beginDatePicker.calendar = Calendar.autoupdatingCurrent
        beginDatePicker.locale = Locale.init(identifier: "kr_KR")
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        toolbar.tintColor = UIColor.ppWarmPink
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(doneBeginDatePicker))
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        
        beginDateTextField.inputAccessoryView = toolbar
        beginDateTextField.inputView = beginDatePicker
    }
    
    @objc func doneBeginDatePicker() {
        // 날짜 선택 세그먼트 선택 취소
        dateSegment.selectedSegmentIndex = UISegmentedControlNoSegment
        
        // For date formate
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
        toolbar.tintColor = UIColor.ppWarmPink
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(doneEndDatePicker))
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        
        endDateTextField.inputAccessoryView = toolbar
        endDateTextField.inputView = endDatePicker
    }
    
    @objc func doneEndDatePicker() {
        // 날짜 선택 세그먼트 선택 취소
        dateSegment.selectedSegmentIndex = UISegmentedControlNoSegment
        
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
    fileprivate func clearGungu() {
        filter?.gungu = nil
        gunguButton.setTitle("전체", for: .normal)
    }
    
    fileprivate func clearSido() {
        filter?.sido = nil
        currentSido = nil
        sidoButton.setTitle("전체", for: .normal)
    }
    
    fileprivate func clearSpecies() {
        filter?.species = nil
        currentSpecies = nil
        speciesButton.setTitle("전체", for: .normal)
    }
    
    fileprivate func clearBreed() {
        filter?.breed = nil
        breedButton.setTitle("전체", for: .normal)
    }

    // MARK: - PPOPicker Delegate
    @objc func pickerCancelAction() {
        // 취소 버튼 누르면 해제되는 것으로
        if let callerView = picker?.callerButton {
            // set selected data to post instance as picker
            switch callerView.tag {
            case PickerName.SpeciesPicker.rawValue:
                clearSpecies()
                clearBreed()
            case PickerName.BreedPicker.rawValue:
                clearBreed()
            case PickerName.SidoPicker.rawValue:
                clearSido()
                clearGungu()
            case PickerName.GunguPicker.rawValue:
                clearGungu()
            default: break
            }
        }
        
        picker?.endPicking()
    }
    
    @objc func pickerSetAction() {
        if let selectedItems = picker?.selectedItems, let callerView = picker?.callerButton {
            let selectedPublicData: PublicDataProtocol = selectedItems[0]
            callerView.setTitle(selectedPublicData.name, for: .normal)
            
            // set selected data to post instance as picker
            switch callerView.tag {
            case PickerName.SpeciesPicker.rawValue:
                if let species = selectedPublicData as? Species {
                    filter?.species = species
                    currentSpecies = species
                    clearBreed()
                }
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
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        toolbar.tintColor = UIColor.ppWarmPink
        
        let cancelButton = UIBarButtonItem(title: "초기화", style: .plain, target: self, action: #selector(pickerCancelAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(pickerSetAction))
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        return toolbar
    }
    
    func pickerView(didSelect value: PublicDataProtocol, inRow row: Int, inComponent component: Int, delegatedFrom pickerView: PPOPicker) {
    }
}
