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

    override func viewDidLoad() {
        showLoginViewOnAppear = accountKit.currentAccessToken != nil
        if showLoginViewOnAppear {
            showLoginViewOnAppear = false
            // Todo: - 노티 데이터 요청 및 표시
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            present(loginViewController, animated: true, completion: nil)
        }
    }
}
