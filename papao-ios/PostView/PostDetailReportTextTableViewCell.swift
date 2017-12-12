//
//  PostDetailReportTextTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 28..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class PostDetailReportTextTableViewCell: UITableViewCell {
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var neuterLabel: UILabel!
    
    @IBOutlet var happenDateLabel: UILabel!
    @IBOutlet var happenPlaceLabel: UILabel!
    
    @IBOutlet var featureLabel: UILabel!
    @IBOutlet var userContactLabel: UILabel!
    
    @IBOutlet var mapView: GMSMapView!

    // 실종, 제보 타이틀 변경용
    @IBOutlet weak var happenDateTitleLabel: UILabel!
    @IBOutlet weak var happenPlaceTitleLabel: UILabel!
    
    func setPostDetail(_ postDetail: PostDetail?) {
        guard let postDetail = postDetail else {
            return
        }
        
        genderLabel.text = postDetail.genderType.description
        ageLabel.text = postDetail.age?.description
        
        if let weight = postDetail.weight, weight != -1 {
            weightLabel.text = "\(weight) kg"
        } else {
            weightLabel.text = "모름"
        }
        
        neuterLabel.text = postDetail.neuterType.description

        happenDateLabel.text = postDetail.happenDate.toDate(format: "yyyyMMdd")?.toString(format: "yyyy년 MM월 dd일")
        happenPlaceLabel.text = postDetail.happenPlace
        featureLabel.text = postDetail.feature ?? ""
        if let contact = postDetail.managerContact {
            userContactLabel.text = contact != "-1" ? contact : "없음"
        } else {
            userContactLabel.text = "없음"
        }
        
        if (postDetail.postType == .MISSING) {
            happenDateTitleLabel.text = "실종날짜"
            happenPlaceTitleLabel.text = "실종장소"
        }
        
        setMapView(happenPlace: postDetail.happenPlace)
    }
    
    func setMapView(happenPlace address: String) {
        guard address.count > 0 else {
            mapView.isHidden = true
            return
        }
        
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        
        if let escapeAddress = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let url = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=@\(escapeAddress)"
            print(url)
            Alamofire.request(url).responseData { response in
                if let json = response.result.value, let result = String.init(data: json, encoding: String.Encoding.utf8) {
                    var latitude: Double = 0
                    var longitude: Double = 0
                    let scanner = Scanner.init(string: result)
                    if scanner.scanUpTo("\"lat\" :", into: nil) && scanner.scanString("\"lat\" :", into: nil) {
                        scanner.scanDouble(&latitude)
                        if scanner.scanUpTo("\"lng\" :", into: nil) && scanner.scanString("\"lng\" :", into: nil) {
                            scanner.scanDouble(&longitude)
                        }
                    }
                    let coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    self.createMarker(coordinate)
                }
            }
        }
    }
    
    // MARK: - Private Functions
    private func createMarker(_ location: CLLocationCoordinate2D) {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        marker.map = mapView
        marker.isDraggable = false
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 15)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
}

