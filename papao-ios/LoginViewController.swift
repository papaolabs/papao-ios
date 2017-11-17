//
//  LoginViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 13..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit

final class LoginViewController: UIViewController {
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var pendingLoginViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    
    // MARK: - view management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAccountOnAppear = accountKit.currentAccessToken != nil
        pendingLoginViewController = accountKit.viewControllerForLoginResume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showAccountOnAppear {
            showAccountOnAppear = false
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
        } else if let viewController = pendingLoginViewController {
            prepareLoginViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: animated, completion: nil)
                pendingLoginViewController = nil
            }
        }
    }
    
    // MARK: - actions
    
    @IBAction func loginWithPhone(_ sender: AnyObject) {
        let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: nil)
        prepareLoginViewController(viewController)
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK: - helpers
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController) {
        loginViewController.delegate = self
    }
    
    
    fileprivate func alert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
}

// MARK: - AKFViewControllerDelegate extension

extension LoginViewController: AKFViewControllerDelegate {
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        accountKit.requestAccount { [weak self] (account, error) in
            if let error = error {
                self?.alert(message: "사용자 데이터를 받는데 실패하였습니다. 다시 시도해주세요.")
            } else {
                if let phoneNumber = account?.phoneNumber?.phoneNumber {
                    let api = HttpHelper.init()
                    let parameter = ["phone": phoneNumber, "userId": accessToken.accountID, "userToken": accessToken.tokenString] as [String: AnyObject]
                    api.join(parameters: parameter, completion: { (result) in
                        do {
                            // Todo: - 앱에 사용자 정보를 저장해야하나?
                            let user = try result.unwrap()
                            print(user)
                            DispatchQueue.main.async(execute: {
                                self?.dismiss(animated: true, completion: nil)
                            })
                        } catch {
                            print(error)
                        }
                    })
                }
            }
        }
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
    }
}
