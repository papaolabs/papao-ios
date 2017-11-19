//
//  PostDetailViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 17..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

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
        
        // keyboard event
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)

        
        speciesLabel.setStyle(type: .medium)
        
        let footer = UIView.init(frame: CGRect.zero)
        tableView.tableFooterView = footer
        
        if let postId = postId {
            getPostDetail(postId: postId)
        }
    }
    
    func getPostDetail(postId: Int) {
        api.readPost(postId: postId, completion: { (result) in
            do {
                let postDetail = try result.unwrap()
                self.postDetail = postDetail
                
                self.speciesLabel.setTitle(postDetail.upKindName, for: .normal)
                self.breedLabel.text = postDetail.kindName
                self.hitCountLabel.text = "\(postDetail.hitCount ?? 0)"
                
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        })
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
    
    // MARK: - IBAction
    @objc func favoriteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "즐겨찾기 되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
        
        let button = sender as! UIButton
        button.tintColor = UIColor.gray
    }
    
    @objc func sendComment(_ sender: Any) {
        
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
}

extension PostDetailViewController: UITextFieldDelegate {
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
            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            return cell
        case PostDetailSection.description.hashValue:
            let cell: PostDetailTextTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailTextCell",
                                                                                    for: indexPath) as! PostDetailTextTableViewCell
            cell.setPostDetail(postDetail)
            return cell
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
                print(text)
            }
            return cell
        default:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case PostDetailSection.image.rawValue:
            return 421
        case PostDetailSection.description.rawValue:
            return 244
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
            return 244
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
