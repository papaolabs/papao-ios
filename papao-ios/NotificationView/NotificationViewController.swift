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
    var history: NotificationHistory?
    
    override func viewDidLoad() {
        if AccountManager.sharedInstance.isLoggedUserValid() {
            let user = AccountManager.sharedInstance.getLoggedUser()
            if let userId = user?.id {
                loadNotificationHistory(userId: userId)
            } else {
                print("로그인에 문제가 있습니다.")
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            present(loginViewController, animated: true, completion: nil)
        }
    }
    
    func loadNotificationHistory(userId: String) {
        let api = HttpHelper.init()
        api.getPushHistory(userId: userId) { (result) in
            do {
                self.history = try result.unwrap()
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.history?.pushLogs.count ?? 0
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
