//
//  QuickReportInfoViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import GoogleMaps

class QuickReportInfoViewController: UIViewController {
    @IBOutlet weak var contentScrollView: UIScrollView!

    @IBOutlet weak var speciesButton: UIButton!
    @IBOutlet weak var breedButton: UIButton!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var featureTextView: UITextView!
    
    var post: PostRequest?
    var currentSpecies: Species?
    
    var breedList: [PublicDataProtocol]!
    var speciesList: [PublicDataProtocol]!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var markerForCurrentLocation: GMSMarker?
    
    // for input the date
    var comp = NSDateComponents()
    private let datePicker = UIDatePicker()
    
    fileprivate var picker: PPOPicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set Indice to caller buttons to specify data
        breedButton.tag = PickerName.BreedPicker.rawValue
        speciesButton.tag = PickerName.SpeciesPicker.rawValue
        
        // create species list
        if let path = Bundle.main.path(forResource: "SpeciesList", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            if let speciesList: [AnyObject] = dict["Species"] as? [AnyObject] {
                self.speciesList = speciesList.map({ (dict) -> Species in
                    return Species(dict: dict as! [String: AnyObject])
                })
            }
        }
        
        // auto filling
        setPost(post: post)
        
        mapView.setBorder(color: UIColor.ppBorderGray)
        mapView.setRadius(radius: 2)
        featureTextView.setBorder(color: UIColor.ppBorderGray)
        featureTextView.setRadius(radius: 2)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        setDatePicker()
        setContactTextField()
        setFeatureTextView()
    }
    
    func setPost(post: PostRequest?) {
        // 품종, 축종 자동 입력
        if let species = post?.species {
            currentSpecies = species
            speciesButton.setTitle(species.name, for: .normal)
        }
        if let breed = post?.breed {
            breedButton.setTitle(breed.name, for: .normal)
        }
        
        // 전화번호와 날짜 자동 입력
        if let user = AccountManager.sharedInstance.getLoggedUser() {
            contactTextField.text = user.phone.getPhoneWithoutDash()
        }
        dateTextField.text = post?.happenDate.toString(format: "yyyy-MM-dd")
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
            post?.contact = text
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
    
    @objc func doneDatePicker() {
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: datePicker.date)
        
        // set date for Post instance
        formatter.dateFormat = "yyyyMMdd"
        post?.happenDate = datePicker.date
        
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
    func setFeatureTextView() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(doneFeatureTextView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        toolbar.sizeToFit()
        
        featureTextView.inputAccessoryView = toolbar
    }
    
    @objc func doneFeatureTextView() {
        if let featureText = featureTextView.text {
            post?.feature = featureText
        }
        self.view.endEditing(true)
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
        guard let breeds = currentSpecies?.breeds else {
            return
        }
        picker = PPOPicker(parentViewController: self)
        picker?.delegate = self
        picker?.callerButton = sender
        picker?.set(items: [breeds])
        picker?.startPicking()
    }
    
    private func selectDefaultBreed() {
        post?.breed = nil
        // 축종 선택 시 품종 첫번째꺼 자동 설정
        if let species = post?.species, species.breeds.count > 0 {
            post?.breed = species.breeds[0]
            breedButton.setTitle(post?.breed?.name, for: .normal)
        }
    }
    
    // MARK: - Private Functions
    func presentAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    @IBAction func registerReport(_ sender: Any) {
        if let postRequest = post {
            let api = HttpHelper.init()
            api.createPost(parameters: postRequest.toDict(), completion: { (result) in
                do {
                    let cudResult = try result.unwrap()
                    switch cudResult.rawValue {
                    case let code where code > 0:
                        self.navigationController?.popToRootViewController(animated: true)
                    default:
                        self.alert(message: "글 작성에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                        })
                    }
                } catch {
                    print(error)
                    self.alert(message: "글 작성에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                    })
                }
            })
        } else {
            self.alert(message: "글 작성에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
            })
        }
    }
    
    fileprivate func alert(message: String, confirmText: String, cancel: Bool = false, completion: @escaping ((_ action: UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: confirmText, style: .cancel, handler: completion)
        alert.addAction(okAction)
        if cancel {
            let cancelAction = UIAlertAction(title: "아니오", style: .default)
            alert.addAction(cancelAction)
        }
        self.present(alert, animated: false)
    }
}

extension QuickReportInfoViewController: PPOPickerDelegate {
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
                    post?.species = species
                    currentSpecies = species
                    selectDefaultBreed()
                }
            case PickerName.BreedPicker.rawValue:
                if let breed = selectedPublicData as? Breed {
                    post?.breed = breed
                }
            case PickerName.AgePicker.rawValue:
                if let age = selectedPublicData as? Age {
                    post?.age = age
                    callerView.setTitle(age.name, for: .normal)
                }
            case PickerName.WeightPicker.rawValue:
                if let weight = selectedPublicData as? Weight {
                    post?.weight = Float(weight.name)
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

extension QuickReportInfoViewController: GMSMapViewDelegate {
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
                
                // 시도 군구 코드 입력
                if let (sido, gungu) = self.getSido(from: geocodeResponse?.firstResult()) {
                    self.post?.sido = sido
                    self.post?.gungu = gungu
                }
            }
        }
    }
    
    private func getSido(from address: GMSAddress?) -> (Sido?, Gungu?)? {
        guard let administrativeAreaName = address?.administrativeArea,
            let locality = address?.locality else {
                return (nil, nil)
        }
        guard let sido = Sido(name: administrativeAreaName) else {
            return (nil, nil)
        }
        
        return (sido, sido.getGungu(name: locality))
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

extension QuickReportInfoViewController: CLLocationManagerDelegate {
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

extension QuickReportInfoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 303, right: 0)
        contentScrollView.scrollIndicatorInsets = contentScrollView.contentInset
        contentScrollView.scrollToBottom()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        contentScrollView.contentInset = UIEdgeInsets.zero
        contentScrollView.scrollIndicatorInsets = contentScrollView.contentInset
        contentScrollView.scrollToBottom()
        self.view.endEditing(true);
    }
}

