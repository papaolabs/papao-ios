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
        postViews.forEach { (view) in
            view.initialize()
        }
    }
    
    func setPosts(posts: [Post]?) {
        for (index, _) in postViews.enumerated() {
            if let posts = posts {
                let postView = postViews[index]
                if posts.indices.contains(index) {
                    postView.setPost(posts[index])
                } else {
                    postView.setEmpty()
                }
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
    let gradient = CAGradientLayer()

    override func awakeFromNib() {
        initialize()
    }
    
    func initialize() {
        thumbImageView.setRadius(radius: 8)
        thumbImageView.layer.masksToBounds = true
        
        // add gradient
        thumbImageView.layer.cornerRadius = 8
        thumbImageView.layer.masksToBounds = true
        thumbImageView.layer.addSublayer(gradient)
    }
    
    func setEmpty() {
        breedLabel.text = "등록된 동물 없음"
        genderLabel.text = ""
        dateLabel.text = ""
        hitCountLabel.text = ""
        commentCountLabel.text = ""
        thumbImageView.image = UIImage(named: "placeholder")!
        // 비율 자름
        thumbImageView.contentMode = .scaleAspectFit
        thumbImageView.clipsToBounds = true
        
        gradient.frame = thumbImageView.bounds
        gradient.colors = [UIColor.init(white: 0, alpha: 0).cgColor, UIColor.init(white: 0, alpha: 0.25).cgColor]
    }
    
    func setPost(_ post: Post) {
        breedLabel.text = post.kindName
        genderLabel.text = post.genderType.description
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let formattedDate = formatter.date(from: post.happenDate)
        formatter.dateFormat = "yyyy.MM.dd"
        if let dateString = formattedDate {
            dateLabel.text = formatter.string(from: dateString)
        } else {
            dateLabel.text = ""
        }

        hitCountLabel.text = String(describing:post.hitCount ?? 0)
        commentCountLabel.text = String(describing:post.commentCount ?? 0)
        
        // set represent image
        let placeholderImage = UIImage(named: "placeholder")!
        if post.imageUrls.count > 0 {
            if let urlString = post.imageUrls[0]["url"] as? String, let url = URL(string: urlString) {
                self.thumbImageView.sd_setImage(with: url, placeholderImage: placeholderImage)
                
                gradient.frame = thumbImageView.bounds
                gradient.colors = [UIColor.init(white: 0, alpha: 0).cgColor, UIColor.init(white: 0, alpha: 0.25).cgColor]
                
                // 비율 자름
                thumbImageView.contentMode = .scaleAspectFill
                thumbImageView.clipsToBounds = true
            }
        } else {
            self.thumbImageView.image = placeholderImage
        }
    }
}
