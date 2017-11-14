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
    
    static var count: Int { return PostDetailSection.comment.hashValue + 1}
}

class PostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var speciesLabel: PPOBadge!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
    
    var postId: Int?
    private var postDetail: PostDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speciesLabel.setStyle(type: .medium)
        
        let footer = UIView.init(frame: CGRect.zero)
        tableView.tableFooterView = footer
        
        if let postId = postId {
            getPostDetail(postId: postId)
        }
    }
    
    func getPostDetail(postId: Int) {
        let api = HttpHelper.init()
        api.readPost(postId: postId, completion: { (result) in
            do {
                let postDetail = try result.unwrap()
                self.postDetail = postDetail
                
                self.speciesLabel.setTitle(postDetail.upKindName, for: .normal)
                self.breedLabel.text = postDetail.kindName
                self.commentLabel.text = "\(postDetail.commentCount ?? 0)"
                self.hitCountLabel.text = "\(postDetail.hitCount ?? 0)"
                
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        })
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

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // Image, Menu, Description, Comment 세가지
        return PostDetailSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            cell.setPostDetail(postDetail)
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
        default:
            return 40
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
