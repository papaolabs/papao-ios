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
    fileprivate var isBookmarked: Bool = false
    
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    let api = HttpHelper.init()
    var postDetail: PostDetail?

    func setPostDetail(_ postDetail: PostDetail?) {
        if let postDetail = postDetail {
            self.postDetail = postDetail
            
            if let hitCount = postDetail.hitCount {
                self.favoriteButton.setTitle("\(hitCount)", for: .normal)
            }
            
            // 북마크 카운트 조회 & 업데이트
            loadBookmarkCount(postId: postDetail.id)
            
            // user id 필요한 내용
            accountKit.requestAccount { (account, error) in
                if let error = error {
                    // 문제가 있거나 비회원일 때
                    print(error)
                } else {
                    if let accountId = account?.accountID, let postId = self.postDetail?.id {
                        // 북마크 상태 조회 & 업데이트
                        self.loadBookmarkState(postId: postId, userId: accountId)
                    }
                }
            }
        }
    }
    
    func loadBookmarkState(postId: Int, userId: String) {
        api.checkBookmark(postId: "\(postId)", parameter: ["userId": userId]) { (result) in
            do {
                let isBookmarked = try result.unwrap()
                self.updateBookmarkButton(bookmarked: isBookmarked)
            } catch {
                print(error)
            }
        }
    }
    
    func loadBookmarkCount(postId: Int) {
        api.countBookmark(postId: "\(postId)") { (result) in
            do {
                let count = try result.unwrap()
                self.favoriteButton.setTitle("\(count)", for: .normal)
            } catch {
                print(error)
            }
        }
    }
    
    func updateBookmarkButton(bookmarked: Bool) {
        let newImage = bookmarked ? UIImage.init(named: "iconBookmarkPressed") : UIImage.init(named: "iconBookmarkDetail")
        self.favoriteButton.setImage(newImage, for: .normal)
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

