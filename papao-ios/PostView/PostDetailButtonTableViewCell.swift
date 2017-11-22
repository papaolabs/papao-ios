//
//  PostDetailButtonTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire
import AccountKit

class PostDetailButtonTableViewCell: UITableViewCell {
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var etcButton: UIButton!
    
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    let api = HttpHelper.init()
    var postDetail: PostDetail?

    func setPostDetail(_ postDetail: PostDetail?) {
        self.postDetail = postDetail
        
        if let hitCount = postDetail?.hitCount {
            self.favoriteButton.setTitle("\(hitCount)", for: .normal)
        }
    }
    
    func updateBookmarkButton(bookmarked: Bool) {
        if bookmarked {
            self.favoriteButton.setImage(UIImage.init(named: "iconBookmarkPressed"), for: .normal)
            if let currentTitle = self.favoriteButton.currentTitle, let currentCount = Int(currentTitle) {
                // Todo: count api 통해서 업데이트
                self.favoriteButton.setTitle("\(currentCount+1)", for: .normal)
            }
        } else {
            self.favoriteButton.setImage(UIImage.init(named: "iconBookmarkDetail"), for: .normal)
            if let currentTitle = self.favoriteButton.currentTitle, let currentCount = Int(currentTitle) {
                // Todo: count api 통해서 업데이트
                let newCount = (currentCount == 0) ? 0 : currentCount-1
                self.favoriteButton.setTitle("\(newCount)", for: .normal)
            }
        }
    }
    
    @IBAction func bookmarkButtonPressed(sender: UIButton) {
        accountKit.requestAccount { (account, error) in
            if let error = error {
                // 문제가 있거나 비회원일 때
                print(error)
            } else {
                if let accountId = account?.accountID, let postId = self.postDetail?.id {
                    self.api.registerBookmark(postId: "\(postId)", userId: accountId, completion: { (result) in
                        do {
                            let isSuccess = try result.unwrap()
                            self.updateBookmarkButton(bookmarked: isSuccess)
                        } catch {
                            print(error)
                        }
                    })
                } else {
                    // Todo: alert
                    print("not logged user")
                }
            }
        }
        
    }
}

