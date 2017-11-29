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
