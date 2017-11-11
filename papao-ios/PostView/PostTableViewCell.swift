//
//  PostTableViewCell.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 17..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var happenDateLabel: UILabel!
    @IBOutlet weak var happenPlaceLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var stateBadge: PPOBadge!
    
    override func awakeFromNib() {
        initialize()
    }
    
    func initialize() {
        postImageView.setRadius(radius: 8)
    }
    
    func setPost(post: Post) {
        kindLabel.text = post.kindName ?? "기타"
        genderLabel.text = post.genderType ?? ""
        happenDateLabel.text = post.happenDate
        happenPlaceLabel.text = post.happenPlace
        viewCountLabel.text = String(describing:post.hitCount ?? 0)
        commentCountLabel.text = String(describing:post.commentCount ?? 0)
        
        // set represent image
        if post.imageUrls.count > 0 {
            if let url = post.imageUrls[0]["url"] as? String {
                Alamofire.request(url).responseData { response in
                    if let data = response.result.value {
                        let image = UIImage(data: data)
                        self.postImageView.image = image
                    }
                }
            }
        }
        
        // state badge
        if let stateValue = post.stateType, let state = State(rawValue: stateValue) {
            if state == .PROCESS {
                stateBadge.isHidden = true
            } else {
                stateBadge.isHidden = false
                stateBadge.setStyle(type: .small, backgroundColor: state.color)
                stateBadge.setTitle(state.rawValue, for: .normal)
            }
        }
    }
}
