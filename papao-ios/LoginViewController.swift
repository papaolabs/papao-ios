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
    @IBOutlet weak var loginButton: PPOBadge!
    
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var pendingLoginViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    fileprivate let api = HttpHelper.init()

    // MARK: - view management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.setBackgroundColor(color: UIColor.init(named: "warmPink") ?? .purple)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setRadius(radius: 24)
        
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
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginWithPhone(_ sender: AnyObject) {
        let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: nil)
        prepareLoginViewController(viewController)
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK: - helpers
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController) {
        loginViewController.delegate = self
        loginViewController.enableSendToFacebook = true
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
        AccountManager.sharedInstance.loginIfNotLogged { (isSuccess) -> (Void) in
            if isSuccess {
                // 저장된 푸시디바이스토큰이 있으면 서버로 전송
                AccountManager.sharedInstance.setDeviceToken()
                
                // 로그인창 닫기
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                print("로그인 실패")
                // Todo: - 로그인 재시도 안내 팝업
            }
        }
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
    }
    
    fileprivate func sendDeviceToken(userId: String, callback: @escaping () -> Void) {
        guard let storedDeviceToken = UserDefaults.standard.object(forKey: UserDefaultsKeys.deviceToken.rawValue) else {
            return
        }
        
        let parameters = ["deviceId": storedDeviceToken, "type": PushType.USER.rawValue, "userId": userId]

        self.api.setPush(parameters: parameters as [String: AnyObject], completion: { (result) in
            do {
                let result = try result.unwrap()
                print(result)
                callback()
            } catch {
                print(error)
                callback()
            }
        })
    }
}
