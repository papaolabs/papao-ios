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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            present(loginViewController, animated: true, completion: nil)
        }
    }
}
