//
//  ReportDetectionInfoViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 30..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportDetectionInfoViewController: UIViewController {
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var featureTextView: UITextView!
    
    var comp = NSDateComponents()
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDatePicker()
    }
    
    func setDatePicker() {
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current

        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        // add toolbar to textField
        dateTextField.inputAccessoryView = toolbar
        // add datepicker to textField
        dateTextField.inputView = datePicker
    }

    @objc func doneDatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: datePicker.date)
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
    @IBAction func previewButtonPressed(_ sender: UIButton) {
        
    }
}
