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
    
    // Todo: - 컨트롤러에서 처리 가능하도록 수정
    weak var parentViewController: UIViewController?

    let api = HttpHelper.init()
    var user: User?
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
            user = AccountManager.sharedInstance.getLoggedUser()
            if let userId = user?.id, let postId = self.postDetail?.id {
                // 북마크 상태 조회 & 업데이트
                self.loadBookmarkState(postId: postId, userId: userId)
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
        if let user = user, let postId = self.postDetail?.id {
            // 북마크 버튼의 상태를 토글 (추가 -> 취소, 취소 -> 추가)
            self.toggleBookmarkState(postId: postId, userId: user.id, willBookmark: !sender.bookmarked)
        } else {
            alert(message: "로그인 후 북마크 추가가 가능합니다. 로그인하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                self.goToLoginView()
            })
        }
    }
    
    fileprivate func alert(message: String, confirmText: String, cancel: Bool = false, completion: @escaping ((_ action: UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: confirmText, style: .cancel, handler: completion)
        alert.addAction(okAction)
        if cancel {
            let cancelAction = UIAlertAction(title: "아니오", style: .default)
            alert.addAction(cancelAction)
        }
        parentViewController?.present(alert, animated: false)
    }
    
    fileprivate func goToLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        parentViewController?.present(loginViewController, animated: true, completion: nil)
    }
}


