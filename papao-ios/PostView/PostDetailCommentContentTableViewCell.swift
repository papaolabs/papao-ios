//
//  PostDetailCommentContentTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire
import DateToolsSwift

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
        thumbnailImageView.setBorder(color: UIColor.ppPlaceholderGray, width: 0.4)
        // Todo: - placeholder image 설정
    }
    
    func setContent(_ content: Content?) {
        if let content = content {
            nicknameLabel.text = content.nickname
            contentLabel.text = content.text

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let relativeTime = formatter.date(from: content.createdDate)?.timeAgoSinceNow
            relativeTimeLabel.text = relativeTime
            Alamofire.request(content.profileUrl).responseData { response in
                if let data = response.result.value {
                    let image = UIImage(data: data)
                    self.thumbnailImageView.image = image
                }
            }
        }
        
    }
}
