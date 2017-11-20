//
//  HomeViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit
import ASHorizontalScrollView

class HomeViewController: UIViewController {
    @IBOutlet weak var updateCountLabel: UILabel!
    @IBOutlet var horizontalScrollView: ASHorizontalScrollView!

    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        horizontalScrollView.defaultMarginSettings = MarginSettings(leftMargin: 15, miniMarginBetweenItems: 8, miniAppearWidthOfLastItem: 24)
        horizontalScrollView.uniformItemSize = CGSize(width: 328, height: 184)
        //this must be called after changing any size or margin property of this class to get acurrate margin
        horizontalScrollView.setItemsMarginOnce()
        for _ in 0...3{
            let button = UIButton(frame: CGRect.zero)
            button.backgroundColor = UIColor.purple
            horizontalScrollView.addItem(button)
        }

        
        // register push notification
//        UIApplication.shared.registerForRemoteNotifications()
        
//        accountKit.requestAccount { [weak self] (account, error) in
//            if let error = error {
//                print(error)
//            } else {
//                if let accountId = account?.accountID {
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
//                }
//            }
//        }
    }
}
