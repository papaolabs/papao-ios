//
//  HomeViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit

class HomeViewController: UIViewController {
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register push notification
//        UIApplication.shared.registerForRemoteNotifications()
        
        accountKit.requestAccount { [weak self] (account, error) in
            if let error = error {
                print(error)
            } else {
                if let accountId = account?.accountID {
//                    let api = HttpHelper.init()
//                    let parameter = ["userId": accountId, "deviceId": deviceTokenString] as [String: AnyObject]
//                    api.setPush(parameters: parameter, completion: { (result) in
//                        do {
//                            // Todo: - 앱에 사용자 정보를 저장해야하나?
//                            let result = try result.unwrap()
//                            print(result)
//                        } catch {
//                            print(error)
//                        }
//                    })
                }
            }
        }
    }
}
