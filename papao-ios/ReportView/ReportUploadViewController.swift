//
//  ReportUploadViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import GoogleMaps

class ReportUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSMapViewDelegate {
    @IBOutlet var uploadButton: UIButton!

    @IBOutlet var uploadedImageView: UIImageView!
    @IBOutlet weak var dateTakenLabel: UILabel!
    @IBOutlet weak var locationTakenLabel: UILabel!
    
    var post: PostRequest = PostRequest.init()

    // for getting a photo
    let picker = UIImagePickerController()
    
    // for marking to a location
    var mapView: GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }

    // MARK: - IBActions
    @IBAction func uploadButtonPressed(button: UIButton) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - ImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        uploadedImageView.contentMode = .scaleAspectFit
        uploadedImageView.image = chosenImage

        let assetURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL as URL], options: nil)
        guard let result = asset.firstObject else {
            return
        }
        
        let imageManager = PHImageManager.default()
        imageManager.requestImageData(for: result , options: nil, resultHandler:{
            (data, responseString, imageOriet, info) -> Void in
            let imageData: NSData = data! as NSData
            if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                print("imageProperties: ", imageProperties)

                let imageInfo = ImageInfo(imageProperties)
                self.dateTakenLabel.text = imageInfo.date
                
                if let latitude = imageInfo.latitude, let longitude = imageInfo.longitude {
                    let coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    self.addMap(coordinate)
                    
                    self.setAddress(from: coordinate)
                }
            }
            
        })

        dismiss(animated:true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Google Marker Delegates
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        let geocoder = GMSGeocoder.init()
        geocoder.reverseGeocodeCoordinate(marker.position) { (geocodeResponse: GMSReverseGeocodeResponse?, error) in
            self.locationTakenLabel.text = geocodeResponse?.firstResult()?.lines?.joined(separator: ", ")
        }
    }
    
    // MARK: - Private Functions
    private func addMap(_ coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 16.0)
    
        self.mapView = GMSMapView.map(withFrame: CGRect.init(x: 0, y: view.bounds.height/2+100, width: view.bounds.size.width, height: 200), camera: camera)
        self.mapView?.isMyLocationEnabled = false
        self.mapView?.delegate = self
        if let mapView = self.mapView {
            view.addSubview(mapView)
        }

        self.addMarker(from: coordinate)
    }
    
    private func addMarker(from coordinate: CLLocationCoordinate2D) {
        // Creates a marker in the center of the map.
        if let mapView = self.mapView {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            marker.title = "발견 장소"
            marker.map = mapView
            marker.isDraggable = true
        }
    }
    
    private func setAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder.init()
        geocoder.reverseGeocodeCoordinate(coordinate) { (geocodeResponse: GMSReverseGeocodeResponse?, error) in
            self.locationTakenLabel.text = geocodeResponse?.firstResult()?.lines?.joined(separator: ", ")
        }
    }
}
