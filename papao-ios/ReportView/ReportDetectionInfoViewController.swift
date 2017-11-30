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
    @IBOutlet weak var stepTitleLabel3: UILabel!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var featureTextView: UITextView!
    
    @IBOutlet weak var happenDateTitleLabel: UILabel!
    @IBOutlet weak var happenDateDescLabel: UILabel!
    @IBOutlet weak var happenPlaceTitleLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var markerForCurrentLocation: GMSMarker?

    // for input the date
    var comp = NSDateComponents()
    private let datePicker = UIDatePicker()

    // instance for posting Post
    var post: PostRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleLabel()
        
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
        
        // auto filling
        setPost(post: post)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.ppWarmPink
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    func setTitleLabel() {
        if let postType = post?.postType {
            switch postType {
            case .MISSING:
                title = "실종 신고"
                stepTitleLabel3.text = "실종 정보"
                happenDateDescLabel.text = "실종 날짜"
                happenDateTitleLabel.text = "실종 정보를 입력해주세요"
                happenPlaceTitleLabel.text = "실종 장소를 지정해주세요"
            case .ROADREPORT:
                 title = "길거리 제보"
                 stepTitleLabel3.text = "발견 정보"
                 happenDateDescLabel.text = "발견 날짜"
                 happenDateTitleLabel.text = "발견 정보를 입력해주세요"
                 happenPlaceTitleLabel.text = "발견 장소를 지정해주세요"
            case .PROTECTING:
                title = "임시 보호"
                stepTitleLabel3.text = "발견 정보"
                happenDateDescLabel.text = "발견 날짜"
                happenDateTitleLabel.text = "발견 정보를 입력해주세요"
                happenPlaceTitleLabel.text = "발견 장소를 지정해주세요"
            default:
                break
            }
        }
    }
    
    func setPost(post: PostRequest?) {
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
        //For date format
        dateTextField.text = datePicker.date.toString(format: "yyyy-MM-dd")
        
        // set date for Post instance
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
        toolbar.tintColor = UIColor.ppWarmPink

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

    func presentAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Todo: Post Validation
        if let post = post {
            guard post.happenDate != nil else {
                presentAlert(message: "발견 날짜 입력은 필수입니다.")
                return
            }
//            guard post.happenDate != nil else {
//                presentAlert(message: "발견 장소 지정은 필수입니다.")
//                return
//            }
        } else {
            print("post 생성 에러")
            return
        }
        
        if segue.identifier == "PreviewSegue" {
            if let viewController = segue.destination as? ReportPreviewViewController {
                // 텍스트뷰 설정 안누르고 바로 다음버튼 눌렀을 때
                if let featureText = featureTextView.text {
                    post?.feature = featureText
                }
                
                // pass data to next viewController
                viewController.post = post
            }
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

extension ReportDetectionInfoViewController: UITextViewDelegate {
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
