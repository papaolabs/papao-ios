//
//  HomeTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 20..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var postTypeLabel: UILabel!
    @IBOutlet weak var homePostView1: HomePostView!
    @IBOutlet weak var homePostView2: HomePostView!
    @IBOutlet weak var homePostView3: HomePostView!
    
    override func awakeFromNib() {
        initialize()
    }
    
    func initialize() {
    }
}

class HomePostView: UIView {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var hitCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
