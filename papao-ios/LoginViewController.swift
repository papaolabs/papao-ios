//
//  LoginViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 13..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit

class LoginViewController: UIViewController {
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var pendingLoginViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    
    // MARK: - view management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAccountOnAppear = accountKit.currentAccessToken != nil
        pendingLoginViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showAccountOnAppear {
            showAccountOnAppear = false
            presentWithSegueIdentifier("loginSegue", animated: animated)
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
        if let viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: nil) as? AKFViewController {
            prepareLoginViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - helpers
    
    fileprivate func prepareLoginViewController(_ loginViewController: AKFViewController) {
        loginViewController.delegate = self
    }
    
    fileprivate func presentWithSegueIdentifier(_ segueIdentifier: String, animated: Bool) {
        if animated {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        } else {
            UIView.performWithoutAnimation {
                self.performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
    }
}

// MARK: - AKFViewControllerDelegate extension

extension LoginViewController: AKFViewControllerDelegate {
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        // Todo: - 서버로 account token post 해줘야함.
        presentWithSegueIdentifier("loginSegue", animated: false)
    }
    
    func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
    }
}
