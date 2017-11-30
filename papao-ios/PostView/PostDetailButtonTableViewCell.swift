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
    var onDeleteButtonPressed : ((Int) -> Void)?
    var onSetStatusButtonPressed : ((Int, State) -> Void)?

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
                if userId == postDetail.userId {
                    // 더보기 버튼 활성화
                    etcButton.isHidden = false
                }
                
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
        if willBookmark {
            api.registerBookmark(postId: "\(postId)", userId: userId) { (result) in
                do {
                    let cudResult = try result.unwrap()
                    switch cudResult.rawValue {
                    case let code where code > 0:
                        self.bookmarkButton.bookmarked = true
                        self.loadBookmarkCount(postId: postId)

                    default:
                        self.alert(message: "북마크 등록에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                        })
                    }
                } catch {
                    print(error)
                    self.alert(message: "북마크 등록에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                    })
                }
            }
        } else {
            api.cancelBookmark(postId: "\(postId)", userId: userId) { (result) in
                do {
                    let cudResult = try result.unwrap()
                    switch cudResult.rawValue {
                    case let code where code > 0:
                        self.bookmarkButton.bookmarked = false
                        self.loadBookmarkCount(postId: postId)
                    default:
                        self.alert(message: "북마크 취소에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                        })
                    }
                } catch {
                    print(error)
                    self.alert(message: "북마크 취소에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                    })
                }
            }
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

    @IBAction func shareButtonPressed(_ sender: Any) {
        if let postId = postDetail?.id, let url = URL(string: "\(valueForAPIKey(keyname: "API_BASE_URL"))dashboard/posts/\(postId)/share") {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            parentViewController?.present(vc, animated: true)
        }
    }

    @IBAction func etcButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "메뉴", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        }
        let processAction = UIAlertAction(title: "\(State.PROCESS.description)으로 변경", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.setStatus(postId: self.postDetail?.id, status: .PROCESS)
        }
        let returnAction = UIAlertAction(title: "\(State.RETURN.description)로 변경", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.setStatus(postId: self.postDetail?.id, status: .RETURN)
        }
        let naturalDeathAction = UIAlertAction(title: "\(State.NATURALDEATH.description)로 변경", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.setStatus(postId: self.postDetail?.id, status: .NATURALDEATH)
        }
        let euthanasiaAction = UIAlertAction(title: "\(State.EUTHANASIA.description)로 변경", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.setStatus(postId: self.postDetail?.id, status: .EUTHANASIA)
        }
        let adoptionAction = UIAlertAction(title: "\(State.ADOPTION.description)로 변경", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.setStatus(postId: self.postDetail?.id, status: .ADOPTION)
        }
        let deleteAction = UIAlertAction(title: "게시글 삭제", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.deletePost(postId: self.postDetail?.id)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(processAction)
        alertController.addAction(returnAction)
        alertController.addAction(naturalDeathAction)
        alertController.addAction(euthanasiaAction)
        alertController.addAction(adoptionAction)
        alertController.addAction(deleteAction)
        parentViewController?.present(alertController, animated: true, completion: nil)
    }

    fileprivate func alert(message: String, confirmText: String, cancel: Bool = false, completion: @escaping ((_ action: UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if cancel {
            let cancelAction = UIAlertAction(title: "아니오", style: .default)
            alert.addAction(cancelAction)
        }
        let okAction = UIAlertAction(title: confirmText, style: .cancel, handler: completion)
        alert.addAction(okAction)
        parentViewController?.present(alert, animated: false)
    }
    
    fileprivate func goToLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        parentViewController?.present(loginViewController, animated: true, completion: nil)
    }
    
    fileprivate func deletePost(postId: Int?) {
        if let onDeletePressed = self.onDeleteButtonPressed, let postId = postId {
            onDeletePressed(postId)
        }
    }
    
    fileprivate func setStatus(postId: Int?, status: State) {
        if let onSetStatusPressed = self.onSetStatusButtonPressed, let postId = postId {
            onSetStatusPressed(postId, status)
        }
    }
    
}


