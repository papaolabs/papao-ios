//
//  ReportPreivewViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 5..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class ReportPreviewViewController: UIViewController {
    @IBOutlet weak var speciesLabel: PPOBadge!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var representImageView: UIImageView!
    @IBOutlet weak var thumbnailButton1: UIButton!
    @IBOutlet weak var thumbnailButton2: UIButton!
    @IBOutlet weak var thumbnailButton3: UIButton!
    var thumbnailButtons: [UIButton] = []
    
    @IBOutlet weak var genderDescriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var neuterLabel: UILabel!
    
    @IBOutlet weak var userContactLabel: UILabel!
    @IBOutlet weak var happenDateLabel: UILabel!
    @IBOutlet weak var happenPlaceLabel: UILabel!
    
    @IBOutlet weak var featureLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var post: PostRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomUI()
        setPost()
    }
    
    func setCustomUI() {
        speciesLabel.setStyle(type: .medium)
        
        thumbnailButtons = [thumbnailButton1, thumbnailButton2, thumbnailButton3]
        thumbnailButtons.forEach { (button) in
            button.setRadius(radius: 2)
        }
        
        mapView.setBorder(color: UIColor.init(named: "borderGray") ?? UIColor.black)
        mapView.setRadius(radius: 2)
    }
    
    func setPost() {
        setTitle()
        setImages()
        setAnimalInfo()
        setDetectionInfo()
        setMapView()
    }
    
    func setTitle() {
        if let species = post?.upKindCode {
            if let speciesName = SpeciesName(rawValue: Int(species)) {
                speciesLabel.setTitle(speciesName.description, for: .normal)
            }
            breedLabel.text = String(describing:post?.kindCode)
            genderLabel.text = post?.genderType ?? "모름"
        }
    }

    func setImages() {
        if let images = post?.images {
            for (index, element) in images.enumerated() {
                let thumbnailButton = thumbnailButtons[index]
                thumbnailButton.setImage(element, for: .normal)
                thumbnailButton.isHidden = false
            }
        }
        
        // default selection
        thumbnailButton1Pressed(thumbnailButton1)
    }
    
    func setAnimalInfo() {
        weightLabel.text = String(describing:post?.weight)
        neuterLabel.text = String(describing:post?.neuterType)
        ageLabel.text = String(describing:post?.age)
        genderDescriptionLabel.text = post?.genderType ?? Gender.Q.description
    }
    
    func setDetectionInfo() {
        if let post = self.post {
            happenDateLabel.text = post.happenDate
            happenPlaceLabel.text = post.happenPlace
            userContactLabel.text = post.contact ?? "없음"
            featureLabel.text = post.feature ?? ""
        }
    }
    
    func setMapView() {
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        
        if let escapeAddress = post?.happenPlace.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
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
    
    private func imageToGrayscale(_ image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
        currentFilter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        let output = currentFilter!.outputImage
        let cgimg = context.createCGImage(output!,from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        return processedImage
    }
    
    // MARK: - IBActions
    @IBAction func thumbnailButton1Pressed(_ sender: UIButton) {
        if let images = self.post?.images {
            if images.indices.contains(0) {
                thumbnailButton1.layer.opacity = 1
                thumbnailButton2.layer.opacity = 0.4
                thumbnailButton3.layer.opacity = 0.4
                representImageView.image = images[0]
            }
        }
    }
    
    @IBAction func thumbnailButton2Pressed(_ sender: UIButton) {
        if let images = self.post?.images {
            if images.indices.contains(1) {
                thumbnailButton1.layer.opacity = 0.4
                thumbnailButton2.layer.opacity = 1
                thumbnailButton3.layer.opacity = 0.4
                representImageView.image = images[1]
            }
        }
    }
    
    @IBAction func thumbnailButton3Pressed(_ sender: UIButton) {
        if let images = self.post?.images {
            if images.indices.contains(2) {
                thumbnailButton1.layer.opacity = 0.4
                thumbnailButton2.layer.opacity = 0.4
                thumbnailButton3.layer.opacity = 1
                representImageView.image = images[2]
            }
        }
    }
    
    @IBAction func registerReport(_ sender: Any) {
        // Todo: Http POST
        self.navigationController?.popToRootViewController(animated: true)
    }
}
