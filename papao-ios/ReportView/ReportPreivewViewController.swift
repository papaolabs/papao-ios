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
    @IBOutlet weak var happenDateTitleLabel: UILabel!
    @IBOutlet weak var happenPlaceTitleLabel: UILabel!
    
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
        setTitleLabel()
        setCustomUI()
        setPost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationSetting()
    }

    func setNavigationSetting() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.ppTextBlack
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.ppTextBlack]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    func setTitleLabel() {
        if let postType = post?.postType {
            switch postType {
            case .MISSING:
                happenDateTitleLabel.text = "실종날짜"
                happenPlaceTitleLabel.text = "실종장소"
            case .ROADREPORT, .PROTECTING:
                happenDateTitleLabel.text = "발견날짜"
                happenPlaceTitleLabel.text = "발견장소"
            default:
                break
            }
        }
    }

    func setCustomUI() {
        speciesLabel.setStyle(type: .medium)
        
        thumbnailButtons = [thumbnailButton1, thumbnailButton2, thumbnailButton3]
        thumbnailButtons.forEach { (button) in
            button.setRadius(radius: 2)
        }
        
        mapView.setBorder(color: UIColor.ppBorderGray)
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
        if let species = post?.species {
            speciesLabel.setTitle(species.name, for: .normal)
            breedLabel.text = post?.breed?.name ?? "기타"
            genderLabel.text = post?.genderType?.description
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
        if let weight = post?.weight {
            weightLabel.text = String(describing:weight)
        } else {
            weightLabel.text = "모름"
        }
        
        neuterLabel.text = post?.neuterType?.description ?? Neuter.U.description
        ageLabel.text = post?.age?.description ?? "미상"
        genderDescriptionLabel.text = post?.genderType?.description ?? Gender.Q.description
    }
    
    func setDetectionInfo() {
        if let post = self.post {
            happenDateLabel.text = post.happenDate.toString(format: "yyyy-MM-dd")
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
}
