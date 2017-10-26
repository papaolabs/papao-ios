//
//  ReportImageUploadViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 26..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportImageUploadViewController: UIViewController {
    @IBOutlet var progressToolBar: UIToolbar!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    var uploadImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // resize of the toolbar
        var yPosition = UIViewController.statusBarHeight
        if let heightOfNavigation = self.navigationController?.navigationBar.intrinsicContentSize.height {
            yPosition += heightOfNavigation
        }
        progressToolBar.frame = CGRect(x:0, y:yPosition, width:self.view.bounds.size.width, height:54)
    }
}
