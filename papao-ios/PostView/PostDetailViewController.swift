//
//  PostDetailViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 17..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire
import AccountKit

enum PostDetailSection: Int {
    case image = 0
    case menu
    case description
    case comment
    case commentContent
    case commentWriting
    
    static var count: Int { return PostDetailSection.commentWriting.hashValue + 1}
}

class PostDetailViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var speciesLabel: PPOBadge!
    @IBOutlet weak var statusBadge: PPOBadge!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
    
    var postId: Int?
    private var postDetail: PostDetail?
    private var comment: Comment?
    let api = HttpHelper.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        speciesLabel.setStyle(type: .medium)
        
        let footer = UIView.init(frame: CGRect.zero)
        tableView.tableFooterView = footer
        
        if let postId = postId {
            getPostDetail(postId: postId)
            getComments(postId: postId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // keyboard event
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func getPostDetail(postId: Int) {
        api.readPost(postId: postId, completion: { (result) in
            do {
                let postDetail = try result.unwrap()
                self.postDetail = postDetail
                
                self.statusBadge.setStyle(type: .medium, backgroundColor: postDetail.stateType.color, titleColor: .white)
                
                if let postDetail = self.postDetail {
                    switch postDetail.postType {
                    case .PROTECTING, .SYSTEM:
                        self.statusBadge.setTitle(postDetail.stateType.description, for: .normal)
                    case .MISSING:
                        if postDetail.stateType == .PROCESS {
                            self.statusBadge.setTitle("찾는 중", for: .normal)
                        } else {
                            self.statusBadge.setTitle(postDetail.stateType.description, for: .normal)
                        }
                    case .ROADREPORT:
                        self.statusBadge.isHidden = true
                    }
                }
                
                self.genderLabel.text = postDetail.genderType != .Q ? postDetail.genderType.description : ""
                self.speciesLabel.setTitle(postDetail.upKindName, for: .normal)
                self.breedLabel.text = postDetail.kindName
                self.hitCountLabel.text = "\(postDetail.hitCount ?? 0)"
                
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        })
    }
    
    func getComments(postId: Int) {
        api.readComments(postId: "\(postId)") { (result) in
            do {
                let comment = try result.unwrap()
                self.comment = comment
                self.commentLabel.text = "\(comment.count)"
                
                // 댓글 섹션만 리로드
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.contentInset = UIEdgeInsets.zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func sendComment(text: String) {
        let user = AccountManager.sharedInstance.getLoggedUser()
        if let userId = user?.id, let postId = self.postId {
            let parameters = [
                "userId": userId,
                "text": text
            ]
            self.api.postComment(postId: String(describing: postId), parameters: parameters as [String : AnyObject]) { (result) in
                do {
                    let cudResult: CUDResult = try result.unwrap()
                    if cudResult == .success {
                        self.getComments(postId: postId)
                    } else {
                        self.alert(message: "댓글 작성에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                        })
                    }
                } catch {
                    print(error)
                }
            }
        } else {
            alert(message: "로그인 후 댓글 작성이 가능합니다. 로그인하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                self.goToLoginView()
            })
        }
    }
    
    func deletePost(postId: Int) {
        if let user = AccountManager.sharedInstance.getLoggedUser() {
            api.deletePost(postId: postId, userId: user.id) { (result) in
                do {
                    let cudResult = try result.unwrap()
                    if cudResult == .success {
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self.alert(message: "포스트 삭제에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                        })
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func setStatus(postId: Int, status: State) {
        if let user = AccountManager.sharedInstance.getLoggedUser() {
            api.setStatus(postId: postId, userId: user.id, parameters: ["stateType": status.rawValue]) { (result) in
                do {
                    let cudResult = try result.unwrap()
                    if cudResult == .success {
                        self.alert(message: "유기동물의 상태가 변경되었습니다", confirmText: "확인", completion: { (action) in
                            // 내용 새로고침
                            self.getPostDetail(postId: postId)
                        })
                    } else {
                        self.alert(message: "유기동물 상태 변경에 실패했습니다. 다시 시도해주세요", confirmText: "확인", completion: { (action) in
                        })
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    fileprivate func alert(message: String, confirmText: String, cancel: Bool = false, completion: @escaping ((_ action: UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if cancel {
            let cancelAction = UIAlertAction(title: "아니오", style: .default)
            alert.addAction(cancelAction)
        }
        let okAction = UIAlertAction(title: confirmText, style: .cancel, handler: completion)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    fileprivate func goToLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        present(loginViewController, animated: true, completion: nil)
    }
}

extension PostDetailViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard AccountManager.sharedInstance.isLoggedUserValid() else {
            alert(message: "로그인 후 댓글 작성이 가능합니다. 로그인하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                self.goToLoginView()
            })
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // Image, Menu, Description, Comment 세가지
        return PostDetailSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == PostDetailSection.commentContent.hashValue) {
            return self.comment?.count ?? 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        switch section {
        case PostDetailSection.image.hashValue:
            let cell: PostDetailImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailImageCell",
                                                                        for: indexPath) as! PostDetailImageTableViewCell
            cell.setPostDetail(postDetail)
            return cell
        case PostDetailSection.menu.hashValue:
            let cell: PostDetailButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailButtonCell",
            for: indexPath) as! PostDetailButtonTableViewCell
            cell.setPostDetail(postDetail)
            cell.onDeleteButtonPressed = { (postId) in
                self.deletePost(postId: postId)
            }
            cell.onSetStatusButtonPressed = { (postId, status) in
                self.setStatus(postId: postId, status: status)
            }
            // Todo: - 다른 로직으로 개선 필요
            cell.parentViewController = self
            return cell
        case PostDetailSection.description.hashValue:
            if postDetail?.postType == .SYSTEM {
                // 보호소일 때만
                let cell: PostDetailTextTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailTextCell",
                                                                                      for: indexPath) as! PostDetailTextTableViewCell
                cell.setPostDetail(postDetail)
                return cell
            } else {
                let cell: PostDetailReportTextTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailReportTextCell",
                                                                                      for: indexPath) as! PostDetailReportTextTableViewCell
                cell.setPostDetail(postDetail)
                return cell
            }
        case PostDetailSection.comment.hashValue:
            let cell: PostDetailCommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailCommentCell",
                                                                              for: indexPath) as! PostDetailCommentTableViewCell
            cell.setComment(comment)
            return cell
        case PostDetailSection.commentContent.hashValue:
            let row = indexPath.row
            let cell: PostDetailCommentContentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailCommentContentCell",
                                                                                     for: indexPath) as! PostDetailCommentContentTableViewCell
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
            if let contents = self.comment?.contents {
                cell.setContent(contents[row])
            }
            return cell
        case PostDetailSection.commentWriting.hashValue:
            let cell: PostDetailCommentWritingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailCommentWritingCell",
                                                                                            for: indexPath) as! PostDetailCommentWritingTableViewCell
            cell.textField.delegate = self
            cell.onSendPressed = { (text) in
                if let text = text, text != "" {
                    self.sendComment(text: text)
                }
            }
            return cell
        default:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case PostDetailSection.image.rawValue:
            return 421
        case PostDetailSection.description.rawValue:
            return UITableViewAutomaticDimension
        case PostDetailSection.commentContent.rawValue:
            return UITableViewAutomaticDimension
        case PostDetailSection.commentWriting.rawValue:
            return 48
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case PostDetailSection.image.rawValue:
            return 421
        case PostDetailSection.description.rawValue:
            return UITableViewAutomaticDimension
        case PostDetailSection.commentContent.rawValue:
            return UITableViewAutomaticDimension
        case PostDetailSection.commentWriting.rawValue:
            return 48
        default:
            return 40
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
