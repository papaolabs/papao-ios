//
//  PostDetailTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 17..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class PostDetailImageTableViewCell: UITableViewCell {
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet weak var thumbnailButton1: UIButton!
    @IBOutlet weak var thumbnailButton2: UIButton!
    @IBOutlet weak var thumbnailButton3: UIButton!
    
    // 공고일 안내
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var deadlineBadge: PPOBadge!
    
    var thumbnailButtons: [UIButton] = []
    var images: [UIImage?] = [UIImage?](repeating: nil, count: 3)
    var postDetail: PostDetail?
    
    override func awakeFromNib() {
        thumbnailButtons = [thumbnailButton1, thumbnailButton2, thumbnailButton3]
        thumbnailButtons.forEach { (button) in
            button.setRadius(radius: 2)
        }
    }
    func setPostDetail(_ postDetail: PostDetail?) {
        self.postDetail = postDetail
        setImages()
        setDeadlineBadge()
    }
    
    func setImages() {
        if let imageUrls = postDetail?.imageUrls {
            for (index, element) in imageUrls.enumerated() {
                let url = element["url"] as! String
                Alamofire.request(url).responseData { response in
                    if let data = response.result.value, let image = UIImage(data: data) {
                        self.images.insert(image, at: index)
                        let thumbnailButton = self.thumbnailButtons[index]
                        thumbnailButton.setImage(image, for: .normal)
                        thumbnailButton.isHidden = false
                        
                        if index == 0 {
                            // default selection
                            self.thumbnailButton1Pressed(self.thumbnailButton1)
                        }
                    }
                }
            }
        }
    }
    
    func setDeadlineBadge() {
        if let deadlineDay = postDetail?.deadlineDay, postDetail?.postType == .SYSTEM {
            popupView.isHidden = false
            deadlineBadge.setStyle(type: .medium, backgroundColor: UIColor.init(white: 0, alpha: 0.4), titleColor: .white)
            deadlineBadge.setBorder(color: .clear)
            switch deadlineDay {
            case let x where x > 0:
                deadlineBadge.setTitle("보호의무가 \(deadlineDay)일 후 종료됩니다", for: .normal)
            case let x where x == 0:
                deadlineBadge.setTitle("보호의무가 오늘 종료됩니다", for: .normal)
            case let x where x < 0:
                deadlineBadge.setTitle("보호의무 기간이 종료되었습니다", for: .normal)
            default:
                break
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func thumbnailButton1Pressed(_ sender: UIButton) {
        if images.indices.contains(0) {
            thumbnailButton1.layer.opacity = 1
            thumbnailButton2.layer.opacity = 0.4
            thumbnailButton3.layer.opacity = 0.4
            postImageView.image = images[0]
        }
    }
    
    @IBAction func thumbnailButton2Pressed(_ sender: UIButton) {
        if images.indices.contains(1) {
            thumbnailButton1.layer.opacity = 0.4
            thumbnailButton2.layer.opacity = 1
            thumbnailButton3.layer.opacity = 0.4
            postImageView.image = images[1]
        }
    }
    
    @IBAction func thumbnailButton3Pressed(_ sender: UIButton) {
        if images.indices.contains(2) {
            thumbnailButton1.layer.opacity = 0.4
            thumbnailButton2.layer.opacity = 0.4
            thumbnailButton3.layer.opacity = 1
            postImageView.image = images[2]
        }
    }
}
