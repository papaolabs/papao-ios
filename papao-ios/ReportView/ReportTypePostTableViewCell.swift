//
//  ReportTypePostTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 16..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ReportTypePostTableViewCell: PostTableViewCell {
    @IBOutlet weak var postTypeBadge: PPOBadge!
    
    override func setPost(post: Post) {
        super.setPost(post: post)
        
        // PostType badge
        postTypeBadge.setStyle(type: .small, backgroundColor: UIColor.init(named: "placeholderGray"), titleColor: UIColor.init(named: "textBlack"))
        postTypeBadge.setTitle(post.postType.description, for: .normal)
    }

}
