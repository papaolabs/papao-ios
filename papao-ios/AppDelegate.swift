//
//  AppDelegate.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import UserNotifications
import AccountKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let defaults = UserDefaults.standard
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Override point for customization after application launch.
        let googleMapAPIKey = valueForAPIKey(keyname: "GOOGLE_MAP_API_KEY")
        GMSServices.provideAPIKey(googleMapAPIKey)
        
        // register push
        registerPushNotification(application)
        
        UIApplication.shared.applicationIconBadgeNumber = 0

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "papao_ios")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Push Notification
    
    func registerPushNotification(_ application: UIApplication) {
        // iOS 11 support
        if #available(iOS 11, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 10 support
        else if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // 로컬에 디바이스토큰이 존재하지 않거나 현재 디바이스토큰과 다른 경우 저장 & 서버에 전송
        if let storedDeviceToken = defaults.object(forKey: UserDefaultsKeys.deviceToken.rawValue) {
            if deviceTokenString != storedDeviceToken as! String {
                storeDeviceToken(deviceTokenString)
                sendDeviceToken(deviceTokenString)
            }
        } else {
            storeDeviceToken(deviceTokenString)
            sendDeviceToken(deviceTokenString)
        }
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 앱에 들어와있을 때 들어온 푸시
        print("PUsh")
        let aps = userInfo["aps"] as! [String: AnyObject]
        if let type = aps["type"] as? String {
            print(type)
        }
        if let postId = userInfo["postId"] as? String {
            print(postId)
        }
    }
    
    fileprivate func storeDeviceToken(_ deviceToken: String) {
        defaults.set(deviceToken, forKey: UserDefaultsKeys.deviceToken.rawValue)
    }
    
    fileprivate func sendDeviceToken(_ deviceToken: String) {
        let api = HttpHelper.init()
        var parameters = ["deviceId": deviceToken, "type": PushType.GUEST.rawValue]
        
        accountKit.requestAccount { (account, error) in
            if let error = error {
                // 문제가 있거나 비회원일 때
                print(error)
            } else {
                if let accountId = account?.accountID {
                    // 회원일 때, 파라미터의 userId와 type을 변경해준다.
                    parameters["userId"] = accountId
                    parameters["type"] = PushType.USER.rawValue
                }
            }
            // api call
            api.setPush(parameters: parameters as [String: AnyObject], completion: { (result) in
                do {
                    let result = try result.unwrap()
                    print(result)
                } catch {
                    print(error)
                }
            })
        }
        
        // 회원일 때
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // 푸시메세지 터치해서 진입
        let userInfo = response.notification.request.content.userInfo
        if let type = userInfo["type"] as? String,
            let postIdString = userInfo["postId"] as? String,
            let postId = Int(postIdString),
            let messageType = MessageType(rawValue: type) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            switch messageType {
            case .alarm, .post:
                if let previewViewController = storyboard.instantiateViewController(withIdentifier: "PostDetail") as? PostDetailViewController {
                    previewViewController.postId = Int(postId)
                    let navigationViewController = UINavigationController(rootViewController: previewViewController)
                    window?.rootViewController?.present(navigationViewController, animated: true, completion: nil)
                }
            case .search:
                if let imageSearchTableViewController = storyboard.instantiateViewController(withIdentifier: "ImageSearchTable") as? ImageSearchTableViewController {
                    imageSearchTableViewController.postId = Int(postId)
                    let navigationViewController = UINavigationController(rootViewController: imageSearchTableViewController)
                    window?.rootViewController?.present(navigationViewController, animated: true, completion: nil)
                }
                break
            }
            completionHandler()
        }
    }
}


