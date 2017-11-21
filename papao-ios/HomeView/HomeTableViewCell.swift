//
//  HomeTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 20..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var postTypeLabel: UILabel!
    @IBOutlet weak var homePostView1: HomePostView!
    @IBOutlet weak var homePostView2: HomePostView!
    @IBOutlet weak var homePostView3: HomePostView!
    var postViews: [HomePostView]!
    
    override func awakeFromNib() {
        initialize()
    }
    
    func initialize() {
        postTypeImageView.setRadius(radius: postTypeImageView.frame.size.width/2)
        
        postViews = [homePostView1, homePostView2, homePostView3]
    }
    
    func setPosts(posts: [Post]) {
        for (index, _) in postViews.enumerated() {
            if posts.indices.contains(index) {
                let postView = postViews[index]
                postView.setPost(posts[index])
            } else {
                break
            }
        }
    }
}

class HomePostView: UIView {
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var hitCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        initialize()
    }
    
    func initialize() {
        thumbImageView.setRadius(radius: 8)
        thumbImageView.layer.masksToBounds = true
    }
    
    func setPost(_ post: Post) {
        breedLabel.text = post.kindName
        genderLabel.text = post.genderType.description
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let formattedDate = formatter.date(from: post.happenDate)
        formatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = formatter.string(from: formattedDate ?? Date())

        hitCountLabel.text = String(describing:post.hitCount ?? 0)
        commentCountLabel.text = String(describing:post.commentCount ?? 0)
        
        // set represent image
        if post.imageUrls.count > 0 {
            if let url = post.imageUrls[0]["url"] as? String {
                Alamofire.request(url).responseData { response in
                    if let data = response.result.value {
                        let image = UIImage(data: data)
                        self.thumbImageView.image = image
                    }
                }
            }
        }
    }
}
