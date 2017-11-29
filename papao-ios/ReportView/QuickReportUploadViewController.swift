//
//  QuickReportUploadViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 29..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

class QuickReportUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var photoImageView: UIImageView!
    private var selectedImages: [UIImage]!
    @IBOutlet weak var step2Label: UILabel!
    
    let tagForIconView = 999

    // for getting a photo
    private let picker = BSImagePickerViewController()

    var post: PostRequest = PostRequest.init()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.ppWarmPink
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        step2Label.setRadius(radius: step2Label.bounds.width/2)
        step2Label.setBorder(color: UIColor.white)
        
        // set picker
        picker.delegate = self
        picker.maxNumberOfSelections = 1
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(uploadImagesPressed))
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
        photoImageView.isUserInteractionEnabled = true
    }
    
    @IBAction func uploadImagesPressed() {
        bs_presentImagePickerController(picker, animated: true,
                                        select: { (asset: PHAsset) -> Void in
        }, deselect: { (asset: PHAsset) -> Void in
        }, cancel: { (assets: [PHAsset]) -> Void in
        }, finish: { (assets: [PHAsset]) -> Void in
            self.clearSelectedImages()
            // extract images from PHAssets
            for asset:PHAsset in assets {
                if let image = self.getUIImage(asset: asset) {
                    self.selectedImages.append(image)
                    
                    // set images to imageViews
                    DispatchQueue.main.async(execute: {
                        self.photoImageView.image = image
                    })
                }
            }
        }, completion: nil)
    }
    
    func clearSelectedImages() {
        self.selectedImages = []
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if selectedImages == nil || selectedImages.isEmpty {
            let alert = UIAlertController(title: nil, message: "사진은 반드시 한장 이상 등록해주세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        } else {
            // 이미지 업로드
            uploadImages(selectedImages)
        }
    }
    
    // MARK: - ImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        photoImageView.image = chosenImage
        
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    func getUIImage(asset: PHAsset) -> UIImage? {
        var image: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                image = UIImage(data: data)
            }
        }
        return image
    }
    
    func uploadImages(_ images: [UIImage]) {
        let api = HttpHelper.init()
        // Todo: 포스트 타입 지정
        let imageRequest = ImageRequest.init(file: images, postType: .ROADREPORT)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QuickAnimalInfoSegue" {
            
        }
    }
}
