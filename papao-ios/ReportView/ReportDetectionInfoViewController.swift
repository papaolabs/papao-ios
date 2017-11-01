//
//  ReportDetectionInfoViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 30..
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

    // for input the date
    var comp = NSDateComponents()
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
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
    
    // MARK: - Google Marker Delegates
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        let geocoder = GMSGeocoder.init()
        geocoder.reverseGeocodeCoordinate(marker.position) { (geocodeResponse: GMSReverseGeocodeResponse?, error) in
            print(String(describing:geocodeResponse?.firstResult()?.lines?.joined(separator: ", ")))
        }
    }

    // MARK: - Private Functions
    private func addMarker(_ location: CLLocationCoordinate2D) {
        // Creates a marker in the center of the map.
        if let mapView = self.mapView {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            marker.title = "발견 장소"
            marker.map = mapView
            marker.isDraggable = true
        }
    }
    
    private func setAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder.init()
        geocoder.reverseGeocodeCoordinate(coordinate) { (geocodeResponse: GMSReverseGeocodeResponse?, error) in
            print(String(describing:geocodeResponse?.firstResult()?.lines?.joined(separator: ", ")))
        }
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
        self.addMarker(location.coordinate)

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
