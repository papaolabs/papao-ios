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

    // MARK: - view management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.setBackgroundColor(color: UIColor.ppWarmPink)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setRadius(radius: 24)
        
        pendingLoginViewController = accountKit.viewControllerForLoginResume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationSetting()
        
        if AccountManager.sharedInstance.isLoggedUserValid() {
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
    
    func setNavigationSetting() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.ppTextBlack
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.ppTextBlack]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .default
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
                // Todo: - 콜백처리 안하고 제대로 전송 됐는지 확인할 방법 찾기.
                AccountManager.sharedInstance.setDeviceToken()
                
                // 로그인창 닫기
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                self.alert(message: "로그인이 문제가 발생했습니다. 다시 시도해주세요.")
            }
        }
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
        self.alert(message: "로그인에 문제가 발생했습니다. 다시 시도해주세요.")
    }
}
