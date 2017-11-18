//
//  PostDetailButtonTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PostDetailButtonTableViewCell: UITableViewCell {
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var etcButton: UIButton!
    
    func setPostDetail(_ postDetail: PostDetail?) {
        if let hitCount = postDetail?.hitCount {
            self.favoriteButton.setTitle("\(hitCount)", for: .normal)
        }
    }
}

