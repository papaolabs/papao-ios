//
//  PPOPicker.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

protocol PPOPickerDelegate {
    func pickerView(inputAccessoryViewFor pickerView: PPOPicker) -> UIView?
    func pickerView(didSelect value: PublicDataProtocol, inRow row: Int, inComponent component: Int, delegatedFrom pickerView: PPOPicker)
    
}

class PPOPicker: NSObject {
    var delegate: PPOPickerDelegate? {
        didSet {
            textView.inputAccessoryView = delegate?.pickerView(inputAccessoryViewFor: self)
        }
    }
    
    fileprivate let pickerView = UIPickerView()
    fileprivate var textView = UITextField()
    fileprivate weak var parentViewController: UIViewController?
    public weak var callerButton: UIButton?
    public fileprivate(set) var items: [[PublicDataProtocol]] = []
    
    init (parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        super.init()
        setupPickerView()
    }
    
    deinit {
        textView.removeFromSuperview()
    }
}

// MARK: - Getter and Setter
extension PPOPicker {    
    func set(items: [[PublicDataProtocol]]) {
        self.items = items
        pickerView.reloadAllComponents()
    }
    
    var selectedItems: [PublicDataProtocol] {
        var result = [PublicDataProtocol]()
        for index in 0..<pickerView.numberOfComponents {
            let selectedRow = pickerView.selectedRow(inComponent: index)
            if index < items.count && selectedRow < items[index].count {
                result.append(items[index][selectedRow])
            }
        }
        return result
    }
}


// MARK: - setup Views
extension PPOPicker {
    fileprivate func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        textView.inputView = pickerView
        parentViewController?.view.addSubview(textView)
    }
    
    func startPicking() {
        textView.becomeFirstResponder()
    }
    
    func endPicking() {
        textView.resignFirstResponder()
    }
    
}


// MARK: - UIPickerViewDataSource
extension PPOPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
}

// MARK: - UIPickerViewDelegate
extension PPOPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[component][row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickerView(didSelect: items[component][row], inRow: row, inComponent: component, delegatedFrom: self)
    }
}
