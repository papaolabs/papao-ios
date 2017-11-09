//
//  PostTableViewCell.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 17..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

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
