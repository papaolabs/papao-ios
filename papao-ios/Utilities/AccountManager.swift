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
    private let api = HttpHelper.init()

    private init() {}
    
    // User
    func loginIfNotLogged() {
        if isLoggedUserValid() {
            // Todo: - 로그인 컨트롤러 팝업
        } else {
            // 새로 로그인
            accountKit.requestAccount({ (account, error) in
                if let phoneNumber = account?.phoneNumber?.phoneNumber, let userId = account?.accountID, let token = self.accountKit.currentAccessToken?.tokenString {
                    let parameter = ["phone": phoneNumber, "userId": userId, "userToken": token] as [String: AnyObject]
                    self.postUserToServer(parameters: parameter, callback: { (user) in
                        
                    })
                }
            })
        }
    }
    
    func setLoggedUser(_ user: User) {
        defaults.set(user, forKey: UserDefaultsKeys.loggedUser.rawValue)
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
    
    // Device Token
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
        } else {
            // 비회원
        }
        // 로컬에 저장
        setDeviceTokenInDefaults(token)
        
        // 서버에 전송
        postDeviceTokenToServer(token: token, callback: { (result) in
            guard let result = result else {
                print("post device token error")
                return
            }
            print(result)
        })
    }
    
    private func setDeviceTokenInDefaults(_ token: String) {
        defaults.set(token, forKey: UserDefaultsKeys.deviceToken.rawValue)
    }
    
    func getDeviceToken() -> String? {
        return defaults.object(forKey: UserDefaultsKeys.deviceToken.rawValue) as? String
    }

    private func postUserToServer(parameters: [String: AnyObject], callback: @escaping (User?) -> Void) {
        api.join(parameters: parameters) { (result) in
            do {
                let user = try result.unwrap()
                // 로컬에 새로운 유저 데이터 저장
                self.setLoggedUser(user)
                callback(user)
            } catch {
                print(error)
                callback(nil)
            }
        }
    }
    
    private func getUserFromServer(userId: String, callback: @escaping (User?) -> Void) {
        // 서버에 저장된 유저 데이터 조회
        api.profile(userId: userId) { (result) in
            do {
                let user = try result.unwrap()
                callback(user)
            } catch {
                print(error)
                callback(nil)
            }
        }
    }
    
    private func postDeviceTokenToServer(token: String, callback: @escaping ([String: Any]?) -> Void) {
        var parameters = ["deviceId": token]
        
        if let user = getLoggedUser() {
            // 로그인된 유저인 경우
            parameters["type"] = PushType.USER.rawValue
            parameters["userId"] = user.id
        } else {
            // 비회원
            parameters["type"] = PushType.GUEST.rawValue
        }
        
        api.setPush(parameters: parameters as [String: AnyObject], completion: { (result) in
            do {
                let result = try result.unwrap()
                print(result)
                callback(result)
            } catch {
                print(error)
                callback(nil)
            }
        })
    }
}
