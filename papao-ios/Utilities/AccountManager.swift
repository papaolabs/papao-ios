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
    func loginIfNotLogged(successCallback: @escaping (Bool) -> (Void)) {
        if isLoggedUserValid() {
            successCallback(true)
        } else {
            // 새로 로그인
            accountKit.requestAccount({ (account, error) in
                if let phoneNumber = account?.phoneNumber?.phoneNumber,
                    let userId = account?.accountID,
                    let token = self.accountKit.currentAccessToken?.tokenString {
                    
                    self.getUserFromServer(userId: userId, callback: { (user) in
                        if let alreadySignedUser = user {
                            // 이미 가입되어있는 유저인 경우 로컬에 저장만 수행
                            self.setLoggedUser(alreadySignedUser)
                            successCallback(true)
                        } else {
                            // 처음 가입한 유저는 서버에 전송
                            let parameter = ["phone": phoneNumber, "userId": userId, "userToken": token] as [String: AnyObject]
                            self.postUserToServer(parameters: parameter, callback: { (cudResult) in
                                switch cudResult.rawValue {
                                case let code where code > 0:
                                    // 유저데이터 다시 받아서 저장
                                    self.getUserFromServer(userId: userId, callback: { (user) in
                                        if let newUser = user {
                                            self.setLoggedUser(newUser)
                                            successCallback(true)
                                        } else {
                                            successCallback(false)
                                        }
                                    })
                                default:
                                    successCallback(false)
                                }
                            })
                        }
                    })
                }
            })
        }
    }
    
    func setLoggedUser(_ user: User) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: user)
        defaults.set(encodedData, forKey: UserDefaultsKeys.loggedUser.rawValue)
    }
    
    func getLoggedUser() -> User? {
        guard isLoggedUserValid() else {
            return nil
        }
        
        guard let decodedData: Data = defaults.object(forKey: UserDefaultsKeys.loggedUser.rawValue) as? Data else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? User
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
    
    func logout() {
        accountKit.logOut()
        removeUserFromDefaults()
        // Todo: - 서버에 userId로 들어간 디바이스토큰 삭제 요청
    }
    
    private func isUserExistInDefaults() -> Bool {
        return defaults.object(forKey: UserDefaultsKeys.loggedUser.rawValue) != nil
    }
    
    private func removeUserFromDefaults() {
        defaults.removeObject(forKey: UserDefaultsKeys.loggedUser.rawValue)
    }
    
    // Device Token
    func setDeviceToken(_ token: String? = nil) {
        // 기존 토큰도 새 토큰도 nil이면 리턴
        let currentToken = getDeviceToken()
        if currentToken == nil && token == nil {
            return
        }

        // 전송할 token 변수
        var tokenToPost: String
        if let newToken = token {
            // 새 토큰이 존재하는 경우
            if let currentToken = currentToken, currentToken == newToken {
                // 기존 토큰이 존재하고 새 토큰과 같으면 더이상 진행하지 않고 리턴
                return
            } else {
                // 새 토큰 전송
                tokenToPost = token!
            }
        } else {
            // 새 토큰이 없는 경우: - 기존 토큰 전송
            tokenToPost = currentToken!
        }
        
        // 기존 토큰 서버에 푸시
        if isLoggedUserValid() {
            // 로그인 유저 정보가 있으면 user 인스턴스에 deviceToken 추가
            if var user = getLoggedUser() {
                user.devicesToken.append(tokenToPost)
                // 중복 제거
                user.devicesToken = Array(Set(user.devicesToken))
                
                // 다시 저장
                setLoggedUser(user)
            }
        } else {
            // 비회원
        }
        // 로컬에 저장
        setDeviceTokenInDefaults(tokenToPost)
        
        // 서버에 전송
        postDeviceTokenToServer(token: tokenToPost, callback: { (result) in
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

    private func postUserToServer(parameters: [String: AnyObject], callback: @escaping (CUDResult) -> Void) {
        api.join(parameters: parameters) { (result) in
            do {
                let cudResult = try result.unwrap()
                callback(cudResult)
            } catch {
                print(error)
                callback(.unknown)
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
