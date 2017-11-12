//
//  PostDetailCommentTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 11..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PostDetailCommentTableViewCell: UITableViewCell {
    @IBOutlet weak var commentButton: UIButton!
    
    func setPostDetail(_ postDetail: PostDetail?) {
        if let commentCount = postDetail?.commentCount {
            self.commentButton.setTitle("댓글 \(commentCount)개", for: .normal)
        }
    }
}
