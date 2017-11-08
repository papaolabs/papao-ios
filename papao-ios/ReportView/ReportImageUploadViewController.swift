//
//  ReportImageUploadViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 26..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

class ReportImageUploadViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var stepLabel2: UILabel!
    @IBOutlet weak var stepLabel3: UILabel!

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // for getting a photo
    private let picker = BSImagePickerViewController()

    // imageViews for picked photos
    private var selectedImagesViews: [UIImageView]!
    private var selectedImages: [UIImage]!
    
    let tagForIconView = 999
    
    var post: Post = Post.init()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(named: "warmPink")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set step Label
        stepLabel2.setRadius(radius: stepLabel2.bounds.width/2)
        stepLabel2.setBorder(color: UIColor.white)
        stepLabel3.setRadius(radius: stepLabel2.bounds.width/2)
        stepLabel3.setBorder(color: UIColor.white)
        
        // set picker
        picker.delegate = self
        picker.maxNumberOfSelections = 3

        // set pageControl
        pageControl.numberOfPages = 3
        
        // set content size of scrollView
        imageScrollView.contentSize = CGSize(width: imageScrollView.bounds.size.width * 3, height: imageScrollView.bounds.size.height)
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.alwaysBounceVertical = false
        imageScrollView.alwaysBounceHorizontal = true
        imageScrollView.isPagingEnabled = true
        imageScrollView.delegate = self
        imageScrollView.setBorder(color: UIColor.init(named: "borderGray") ?? UIColor.black)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(uploadImagesPressed))
        imageScrollView.addGestureRecognizer(tapGestureRecognizer)
        imageScrollView.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        // initialize imageViews in scrollView
        if selectedImagesViews == nil {
            selectedImagesViews = []
            for index in 0..<pageControl.numberOfPages {
                let imageView = UIImageView.init(frame: CGRect(origin: CGPoint(x:Int(imageScrollView.bounds.size.width) * index, y:0), size: imageScrollView.bounds.size))
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                
                // add icon
                let iconImageView = UIImageView.init(image: UIImage.init(named: "iconAddpic"))
                iconImageView.center = imageView.center
                iconImageView.tag = tagForIconView
                imageView.addSubview(iconImageView)
                
                selectedImagesViews.append(imageView)
                imageScrollView.addSubview(imageView)
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func pageChangeValue(sender: UIPageControl) {
        let xPoint = sender.currentPage * Int(imageScrollView.bounds.size.width)
        imageScrollView.setContentOffset(CGPoint.init(x: xPoint, y: 0), animated: true)
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
                }
            }
            // set images to imageViews
            self.setImagesForPreview(self.selectedImages)
            
            // scroll to front forcibly
            self.scrollToFront()
        }, completion: nil)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        if self.selectedImages == nil || self.selectedImages.isEmpty {
            let alert = UIAlertController(title: nil, message: "사진은 반드시 한장 이상 등록해주세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
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
    
    func setImagesForPreview(_ images: [UIImage]) {
        DispatchQueue.main.async(execute: {
            // remove existing images in each imageViews
            self.clearSelectedImageViews()

            // set new images to each imageViews
            for index in 0..<images.count {
                let imageView = self.selectedImagesViews[index]
                imageView.viewWithTag(self.tagForIconView)?.isHidden = true   // hidden icon view
                imageView.image = images[index]
            }
        })
    }

    func clearSelectedImages() {
        self.selectedImages = []
    }
    
    func clearSelectedImageViews() {
        self.selectedImagesViews.forEach({ (imageView) in
            imageView.image = nil
        })
    }
    
    func scrollToFront() {
        DispatchQueue.main.async(execute: {
            self.imageScrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        })
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        pageControl.currentPage = Int(floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1)
    }
    
    // MARK: - ImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageView = selectedImagesViews[0]
        imageView.image = chosenImage
        
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 다음 페이지 넘어가기전 vaildation
        if self.selectedImages == nil || self.selectedImages.isEmpty {
            let alert = UIAlertController(title: nil, message: "사진은 반드시 한장 이상 등록해주세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
            
            return
        }

        if segue.identifier == "AnimalInfoSegue" {
            if let viewController = segue.destination as? ReportAnimalInfoViewController {
                // set images of post to selectedImages
                self.post.images = selectedImages

                // pass data to next viewController
                viewController.post = post
            }
        }
    }
}
