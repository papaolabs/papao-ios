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
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var showLoginViewOnAppear = false
    var history: NotificationHistory?
    
    override func viewDidLoad() {
        showLoginViewOnAppear = accountKit.currentAccessToken != nil
        if showLoginViewOnAppear {
            showLoginViewOnAppear = false
            if let userId = accountKit.currentAccessToken?.accountID {
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
                print(self.history)
            } catch {
                print(error)
            }
        }
    }
}
