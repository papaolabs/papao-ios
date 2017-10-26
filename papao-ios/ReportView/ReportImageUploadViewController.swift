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

    var uploadImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // resize of the toolbar
        var yPosition = UIViewController.statusBarHeight
        if let heightOfNavigation = self.navigationController?.navigationBar.intrinsicContentSize.height {
            yPosition += heightOfNavigation
        }
        progressToolBar.frame = CGRect(x:0, y:yPosition, width:self.view.bounds.size.width, height:54)
        
        // set content size of scrollView
        imageScrollView.contentSize = CGSize(width: imageScrollView.bounds.size.width * 3, height: imageScrollView.bounds.size.height)
        imageScrollView.backgroundColor = UIColor(named: "warmPink")
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.alwaysBounceVertical = false
        imageScrollView.alwaysBounceHorizontal = true
        imageScrollView.isPagingEnabled = true
        imageScrollView.delegate = self
    }
    
    // MARK: - IBActions
    @IBAction func pageChangeValue(sender: UIPageControl) {
        let xPoint = sender.currentPage * Int(imageScrollView.bounds.size.width)
        imageScrollView.setContentOffset(CGPoint.init(x: xPoint, y: 0), animated: true)
    }
    
    // MARK: - UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        pageControl.currentPage = Int(floor((scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1)
    }
}
