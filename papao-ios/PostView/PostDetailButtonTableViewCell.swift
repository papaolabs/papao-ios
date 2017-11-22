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
    @IBOutlet var bookmarkButton: PPOBookmarkButton!
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
                self.bookmarkButton.setTitle("\(hitCount)", for: .normal)
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
                self.bookmarkButton.bookmarked = isBookmarked
            } catch {
                print(error)
            }
        }
    }
    
    func loadBookmarkCount(postId: Int) {
        api.countBookmark(postId: "\(postId)") { (result) in
            do {
                let count = try result.unwrap()
                self.bookmarkButton.setTitle("\(count)", for: .normal)
            } catch {
                print(error)
            }
        }
    }
    
    func toggleBookmarkState(postId: Int, userId: String, willBookmark: Bool) {
        let completionCallback: (ApiResult<Bool>) -> (Void) = { (result) in
            do {
                let isBookmarked = try result.unwrap()
                self.bookmarkButton.bookmarked = isBookmarked
                self.loadBookmarkCount(postId: postId)
            } catch {
                print(error)
            }
        }
        if willBookmark {
            api.registerBookmark(postId: "\(postId)", userId: userId, completion: completionCallback)
        } else {
            api.cancelBookmark(postId: "\(postId)", userId: userId, completion: completionCallback)
        }
    }

    @IBAction func bookmarkButtonPressed(sender: PPOBookmarkButton) {
        accountKit.requestAccount { (account, error) in
            if let error = error {
                // 문제가 있거나 비회원일 때
                print(error)
            } else {
                if let accountId = account?.accountID, let postId = self.postDetail?.id {
                    // 북마크 버튼의 상태를 토글 (추가 -> 취소, 취소 -> 추가)
                    self.toggleBookmarkState(postId: postId, userId: accountId, willBookmark: !sender.bookmarked)
                } else {
                    // Todo: alert
                    print("not logged user")
                }
            }
        }
        
    }
}


