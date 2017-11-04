//
//  ReportDetectionInfoViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 30..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import GoogleMaps

class ReportDetectionInfoViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var featureTextView: UITextView!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var markerForCurrentLocation: GMSMarker?

    // for input the date
    var comp = NSDateComponents()
    private let datePicker = UIDatePicker()

    // instance for posting Post
    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        setDatePicker()
        setContactTextField()
    }
    
    func setContactTextField() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(doneContactTextField))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        toolbar.sizeToFit()

        contactTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneContactTextField() {
        if let text = contactTextField.text {
            // set user contact to post instance
            post?.userContact = text
        }
        self.view.endEditing(true)
    }
    
    func setDatePicker() {
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.calendar = Calendar.autoupdatingCurrent
        datePicker.locale = Locale.init(identifier: "kr_KR")

        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelDatePicker))
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
        
        // set date for Post instance
        formatter.dateFormat = "yyyyMMdd"
        post?.happenDate = formatter.string(from: datePicker.date)
        
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
    @IBAction func previewButtonPressed(_ sender: UIButton) {
        
    }
    
    // MARK: - Google Marker Delegates
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        setAddress(from: marker.position)
    }

    // MARK: - Private Functions
    private func createMarker(_ location: CLLocationCoordinate2D) {
        // Creates a marker in the center of the map.
        if markerForCurrentLocation == nil {
            markerForCurrentLocation = GMSMarker()
            markerForCurrentLocation?.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            markerForCurrentLocation?.map = mapView
            markerForCurrentLocation?.isDraggable = true
            setAddress(from: location)
            mapView.selectedMarker = markerForCurrentLocation
        }
    }
    
    private func setAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder.init()
        geocoder.reverseGeocodeCoordinate(coordinate) { (geocodeResponse: GMSReverseGeocodeResponse?, error) in
            if let markerForCurrentLocation = self.markerForCurrentLocation, let addressString = self.addressExceptCountry(geocodeResponse?.firstResult()) {
                markerForCurrentLocation.title = addressString
                self.post?.happenPlace = addressString
            }
        }
    }
    
    private func addressExceptCountry(_ address: GMSAddress?) -> String? {
        // 주소에서 대한민국 글자 제거하고 리턴
        if let addressString = address?.lines?.joined(separator: ", ") {
            if let range = addressString.range(of: "대한민국 ") {
                let addressExceptCountry = addressString[range.upperBound..<addressString.endIndex]
                print(addressExceptCountry) // print Hello
                return String(addressExceptCountry)
            } else {
                return addressString
            }
        }
        return nil
    }
}

extension ReportDetectionInfoViewController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 15)
        self.createMarker(location.coordinate)

        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
