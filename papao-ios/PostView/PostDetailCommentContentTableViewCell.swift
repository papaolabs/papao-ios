//
//  PostDetailCommentContentTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PostDetailCommentContentTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var relativeTimeLabel: UILabel!
    
    override func awakeFromNib() {
        initialize()
    }
    
    func initialize() {
        thumbnailImageView.setRadius(radius: thumbnailImageView.frame.size.width/2)
        thumbnailImageView.setBorder(color: UIColor.init(named: "placeholderGray") ?? .gray)
    }
    
    func setComment(_ content: Content?) {
        if let content = content {
            // Todo: 썸네일 표시
            nicknameLabel.text = content.userId
            contentLabel.text = content.text
            // Todo: 상대시간 표시
            relativeTimeLabel.text = content.createdDate
        }
        
    }
}
