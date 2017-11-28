//
//  BookmarkViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire
import AccountKit

class BookmarkViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    var postResponse: PostResponse?
    var userId: String?
    let api = HttpHelper.init()
    let sizeOfPostPerPage = "20"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = emptyView
        setPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationSetting()
        
        userId = AccountManager.sharedInstance.getLoggedUser()?.id
        loadBookmarks()
    }
    
    func setNavigationSetting() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.ppTextBlack
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.ppTextBlack]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .default
    }

    
    func setPullToRefresh() {
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = "당겨서 새로고침"
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        // 데이터 새로고침
        loadBookmarks()
        sender.endRefreshing()
    }
    
    func loadBookmarks(index: String? = nil) {
        if let userId = self.userId {
            if let index = index {
                let parameters = ["index": index, "size": sizeOfPostPerPage] as [String : AnyObject]
                api.readBookmarkByUserId(userId: userId, parameters: parameters, completion: { (result) in
                    do {
                        let newPostResponse = try result.unwrap()
                        if self.postResponse != nil {
                            // 기존에 post 목록 데이터가 있으면 elements에 추가
                            self.postResponse?.elements.append(contentsOf: newPostResponse.elements.flatMap{ $0 })
                        } else {
                            // 기존에 post 목록 데이터 없으면 (처음 요청인 경우)
                            self.postResponse = newPostResponse
                        }
                        self.tableView.reloadData()
                    } catch {
                        print(error)
                    }
                })
            } else {
                // 처음 api 요청
                let parameters = ["index": 0, "size": sizeOfPostPerPage] as [String : AnyObject]
                api.readBookmarkByUserId(userId: userId, parameters: parameters, completion: { (result) in
                    do {
                        let newPostResponse = try result.unwrap()
                        self.postResponse = newPostResponse
                        self.tableView.reloadData()
                    } catch {
                        print(error)
                    }
                })
            }
        } else {
            alert(message: "로그인이 필요한 화면입니다. 로그인 하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
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
        self.present(alert, animated: false)
    }
    
    fileprivate func goToLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        present(loginViewController, animated: true, completion: nil)
    }
}

extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = postResponse?.elements.count, count > 0 else {
            tableView.separatorStyle = .none
            return 0
        }
        tableView.separatorStyle = .singleLine
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReportTypePostTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifier",
                                                                    for: indexPath) as! ReportTypePostTableViewCell
        let row = indexPath.row;
        guard let post = postResponse?.elements[row] else {
            return cell
        }
        
        cell.setPost(post: post)

        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 158
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = postResponse?.elements.count, indexPath.row == count - 1 {
            if let size = Int(sizeOfPostPerPage) {
                let nextIndex = indexPath.row/size + 1
                loadBookmarks(index: "\(nextIndex)")
            } else {
                print("pagination에 문제가 있습니다")
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = self.postResponse?.elements[indexPath.row]
        guard let postDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetail") as? PostDetailViewController else {
            return
        }
        
        postDetailViewController.postId = row?.id
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
