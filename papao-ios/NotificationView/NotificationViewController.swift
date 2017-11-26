//
//  NotificationViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 13..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit

class NotificationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    let api = HttpHelper.init()
    var history: NotificationHistory?
    var userId: String?
    let sizeOfPostPerPage = "20"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = emptyView
        setPullToRefresh()
        
        userId = AccountManager.sharedInstance.getLoggedUser()?.id
        loadNotificationHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotificationHistory()
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
        loadNotificationHistory()
        sender.endRefreshing()
    }
    
    func loadNotificationHistory(index: String? = nil) {
        if let userId = userId {
            if let index = index {
                let parameters = ["index": index, "size": sizeOfPostPerPage] as [String : AnyObject]
                api.getPushHistory(userId: "userId", parameters: parameters) { (result) in
                    do {
                        self.history = try result.unwrap()
                        self.tableView.reloadData()
                    } catch {
                        print(error)
                    }
                }
            } else {
                // 처음 api 요청
                let parameters = ["index": 0, "size": sizeOfPostPerPage] as [String : AnyObject]
                api.getPushHistory(userId: userId, parameters: parameters) { (result) in
                    do {
                        self.history = try result.unwrap()
                        self.tableView.reloadData()
                    } catch {
                        print(error)
                    }
                }
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

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.history?.pushLogs.count, count > 0 else {
            tableView.separatorStyle = .none
            return 0
        }
        tableView.separatorStyle = .singleLine
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "historyCell",
                                                                    for: indexPath) as! NotificationTableViewCell
        let row = indexPath.row
        if let pushLog = history?.pushLogs[row] {
            cell.setPushLog(pushLog)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = history?.pushLogs.count, indexPath.row == count - 1 {
            if let size = Int(sizeOfPostPerPage) {
                let nextIndex = indexPath.row/size + 1
                loadNotificationHistory(index: "\(nextIndex)")
            } else {
                print("pagination에 문제가 있습니다")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pushLog = self.history?.pushLogs[indexPath.row]
        guard let postDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetail") as? PostDetailViewController else {
            return
        }
        
        postDetailViewController.postId = pushLog?.postId
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
