//
//  ReportImageUploadViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 26..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportImageUploadViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var progressToolBar: UIToolbar!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    // for getting a photo
    let picker = UIImagePickerController()

    var uploadImagesViews: [UIImageView] = []
    var uploadButtonView: UIView!
    var uploadButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // resize of the toolbar
        var yPosition = UIViewController.statusBarHeight
        if let heightOfNavigation = self.navigationController?.navigationBar.intrinsicContentSize.height {
            yPosition += heightOfNavigation
        }
        progressToolBar.frame = CGRect(x:0, y:yPosition, width:self.view.bounds.size.width, height:54)
        
        // set pageControl
        pageControl.numberOfPages = 3
        
        // set content size of scrollView
        imageScrollView.contentSize = CGSize(width: imageScrollView.bounds.size.width * 3, height: imageScrollView.bounds.size.height)
        imageScrollView.backgroundColor = UIColor.lightGray
        imageScrollView.layer.cornerRadius = 5
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.alwaysBounceVertical = false
        imageScrollView.alwaysBounceHorizontal = true
        imageScrollView.isPagingEnabled = true
        imageScrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        // create imageViews in scrollView
        for index in 0..<pageControl.numberOfPages {
            let imageView = UIImageView.init(frame: CGRect(origin: CGPoint(x:Int(imageScrollView.bounds.size.width) * index, y:0), size: imageScrollView.bounds.size))
            imageView.contentMode = .scaleAspectFill
            imageView.tag = index
            uploadImagesViews.append(imageView)
            imageScrollView.addSubview(imageView)
        }
    }
    
    // MARK: - IBActions
    @IBAction func pageChangeValue(sender: UIPageControl) {
        let xPoint = sender.currentPage * Int(imageScrollView.bounds.size.width)
        imageScrollView.setContentOffset(CGPoint.init(x: xPoint, y: 0), animated: true)
    }
    
    @IBAction func uploadImagesPressed() {
        print("uploadButtonPressed")
        addImageView()
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        pageControl.currentPage = Int(floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1)
    }
    
    // MARK: - private
    func addImageView() {
        let imageView = uploadImagesViews[0]
        imageView.image = UIImage(named: "sampleDog")
    }
}
