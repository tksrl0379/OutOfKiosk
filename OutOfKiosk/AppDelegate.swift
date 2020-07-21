//
//  AppDelegate.swift
//  OutOfKiosk
//
//  Created by a1111 on 2019/12/31.
//  Copyright © 2019 OOK. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate{
    
    var numOfProducts : Int = 0
    var menuNameArray: Array<String> = []
    var menuSizeArray: Array<String> = []
    var menuCountArray: Array<Int> = []
    var menuEachPriceArray: Array<Int> = []
    var menuSugarContent : Array<String> = []
    var menuIsWhippedCream : Array<String> = []
    var menuStoreName : String = ""
        
    var badgeCount : Int = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        let dictionary = [String:String]()
        let defaults = UserDefaults.standard
        
        
        var favoriteMenuInfoDict = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        
        // 비어 있을 시 초기화
        if favoriteMenuInfoDict == nil{
            defaults.set(dictionary, forKey: "favoriteMenuInfoDict")
        }
    
        Thread.sleep(forTimeInterval: 2.0)
        
        // pushNotification 권한 받기 (최초에 한 번 동작)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) {
            (granted, error) in
            
            if granted {
                print("사용자가 푸시를 허용했습니다")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("사용자가 푸시를 거절했습니다")
            }
        }
        
        return true
    }
    
    // 토큰 정상 등록(registerForRemoteNotifications()을 호출한 결과가 성공일 때)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        print("등록된 토큰은 \(deviceTokenString) 입니다.")
                
        UserDefaults.standard.set(deviceTokenString , forKey: "token")
    }
    
    // 토큰 등록 실패 (registerForRemoteNotifications()을 호출한 결과가 실패)
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("에러 발생 : \(error)")
    }
    
    // Push Notification 콜백
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == .active { // 포그라운드에서 pushNotification 받음
            print("포그라운드")
        }else if application.applicationState == .background {
            print("백그라운드")
            
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
                    
        print(UIApplication.shared.applicationIconBadgeNumber)
        
        let aps = data[AnyHashable("aps")] as? NSDictionary
        let alert = aps!["alert"] as? NSMutableString
        print("메시지 내용: ", alert)
        
        // AppDelegate에서 MainView로 Notification 전송 (alert MSG)
        let userInfo: [AnyHashable: Any] = ["alert": alert]
        NotificationCenter.default.post(name: NSNotification.Name("TestNotification"), object: nil, userInfo: userInfo)
    }
    
    // ForeGround 에서 알람이 오면 출력
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.handleOpen(url) {
            return true
        }
        return false
    }
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if KOSession.handleOpen(url) {
            return true
        }
        return false
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        KOSession.handleDidEnterBackground()
        print("background entered")
        
    }
    
}


