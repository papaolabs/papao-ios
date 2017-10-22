//
//  ReportUploadViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class ReportUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var uploadButton: UIButton!

    @IBOutlet var uploadedImageView: UIImageView!
    @IBOutlet weak var dateTakenLabel: UILabel!
    @IBOutlet weak var locationTakenLabel: UILabel!

    let picker = UIImagePickerController()
    
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
                if let exif = imageProperties["{Exif}"] as? [String: Any] {
                    if let date = exif["DateTimeOriginal"] {
                        self.dateTakenLabel.text = "날짜시간: \(date as! String)"
                    }
                }
                if let gps = imageProperties["{GPS}"] as? [String: Any] {
                    if let latitude = gps["Latitude"] {
                        self.locationTakenLabel.text = String(describing: "위치: \(latitude as! Float)")
                    }
                    if let longitude = gps["Longitude"] {
                        self.locationTakenLabel.text = "\(String(describing: self.locationTakenLabel.text)), \(longitude)"
                    }
                }
                
            }
            
        })

        dismiss(animated:true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
