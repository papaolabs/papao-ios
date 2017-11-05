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
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var representImageView: UIImageView!
    @IBOutlet weak var thumbnailButton1: UIButton!
    @IBOutlet weak var thumbnailButton2: UIButton!
    @IBOutlet weak var thumbnailButton3: UIButton!
    
    @IBOutlet weak var genderDescriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var neuterLabel: UILabel!
    
    @IBOutlet weak var userContactLabel: UILabel!
    @IBOutlet weak var happenDateLabel: UILabel!
    @IBOutlet weak var happenPlaceLabel: UILabel!
    
    @IBOutlet weak var featureLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPost()
    }
    
    func setPost() {
        setTitle()
        setImages()
        setAnimalInfo()
        setDetectionInfo()
        setMapView()
    }
    
    func setTitle() {
        if let species = post?.kindUpCode, let speciesCode = Int(species), let speciesName = SpeciesName(rawValue: speciesCode), let breedName = post?.kindName, let gender = post?.gender {
            speciesLabel.text = speciesName.description
            genderLabel.text = gender
            breedLabel.text = breedName
        }
    }

    func setImages() {
        let array = [thumbnailButton1, thumbnailButton2, thumbnailButton3]
        if let images = post?.images {
            for (index, element) in images.enumerated() {
                let thumbnailButton = array[index]
                thumbnailButton?.setImage(element, for: .normal)
                thumbnailButton?.isHidden = false
            }
        }
        
        // default selection
        thumbnailButton1Pressed(thumbnailButton1)
    }
    
    func setAnimalInfo() {
        if let age = post?.age, let neuter = post?.neuter, let gender = post?.gender, let weight = post?.weight {
            weightLabel.text = weight
            neuterLabel.text = neuter
            ageLabel.text = age
            genderDescriptionLabel.text = gender
        }
    }
    
    func setDetectionInfo() {
        if let post = self.post {
            happenDateLabel.text = post.happenDate
            happenPlaceLabel.text = post.happenPlace
            userContactLabel.text = post.userContact ?? ""
            featureLabel.text = post.feature ?? ""
        }
    }
    
    func setMapView() {
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
        marker.isDraggable = true
        
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
        self.navigationController?.popToRootViewController(animated: true)
    }
}
