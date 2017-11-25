//
//  AccountManager.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 25..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit

final class AccountManager {
    static let sharedInstance = AccountManager()
    
    private var accountKit = AKFAccountKit(responseType: .accessToken)
    private let defaults = UserDefaults.standard

    private init() {}
    
    func setLoggedUser(_ user: User) {
        defaults.set(user, forKey: UserDefaultsKeys.loggedUser.rawValue)
    }
    
    func getLoggedUser() -> User? {
        return defaults.object(forKey: UserDefaultsKeys.loggedUser.rawValue) as? User
    }
}
