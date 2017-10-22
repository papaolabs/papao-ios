//
//  ReportUploadViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var uploadedImageView: UIImageView!
    
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
        dismiss(animated:true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
