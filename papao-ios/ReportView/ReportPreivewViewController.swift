//
//  ReportPreivewViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 5..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportPreviewViewController: UIViewController {
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(post)
    }

    @IBAction func registerReport(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
