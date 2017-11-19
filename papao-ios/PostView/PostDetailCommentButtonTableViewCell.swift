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
    
    func setComment(_ comment: Comment?) {
        if let commentCount = comment?.count {
            self.commentButton.setTitle("댓글 \(commentCount)개", for: .normal)
        } else {
            self.commentButton.setTitle("댓글 0개", for: .normal)
        }
    }
}
