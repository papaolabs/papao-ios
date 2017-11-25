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
    
    func setDeviceToken(_ token: String) {
        if isLoggedUserValid() {
            // 로그인 유저 정보가 있으면 user 인스턴스에 deviceToken 추가
            if var user = getLoggedUser() {
                user.devicesToken.append(token)
                // 중복 제거
                user.devicesToken = Array(Set(user.devicesToken))
                
                // 다시 저장
                setLoggedUser(user)
            }
        }
        // 유저 인스턴스에 저장과 별개로 디바이스 토큰 로컬에 저장 (for 비회원)
        defaults.set(token, forKey: UserDefaultsKeys.deviceToken.rawValue)
    }
    
    func getLoggedUser() -> User? {
        guard isLoggedUserValid() else {
            return nil
        }
        
        return defaults.object(forKey: UserDefaultsKeys.loggedUser.rawValue) as? User
    }
    
    func isLoggedUserValid() -> Bool {
        // 로컬에 유저가 없으면 false
        guard isUserExistInDefaults() else {
            return false
        }
        
        // access token이 유효하지 않으면 false
        guard accountKit.currentAccessToken != nil else {
            // 로컬에 저장된 user 삭제 (더이상 유효하지 않음)
            removeUserFromDefaults()
            
            return false
        }

        return true
    }
    
    private func isUserExistInDefaults() -> Bool {
        return defaults.object(forKey: UserDefaultsKeys.loggedUser.rawValue) != nil
    }
    
    private func removeUserFromDefaults() {
        defaults.removeObject(forKey: UserDefaultsKeys.loggedUser.rawValue)
    }
}
