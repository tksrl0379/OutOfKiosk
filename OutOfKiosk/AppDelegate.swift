//
//  AppDelegate.swift
//  OutOfKiosk
//
//  Created by a1111 on 2019/12/31.
//  Copyright © 2019 OOK. All rights reserved.
//

import UIKit
/* Push Notification 을 받기 위한 모듈*/
import UserNotifications

/*
 모든 View 컨트롤러에서 접근이 가능하며 앱이 종료되지 않는 이상 데이터가 유지가 될 수 있다.
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    /*ORIGINAL*/
    
    var numOfProducts : Int = 0
    var menuNameArray: Array<String> = []
    var menuSizeArray: Array<String> = []
    var menuCountArray: Array<Int> = []
    var menuEachPriceArray: Array<Int> = []
    var menuSugarContent : Array<String> = []
    var menuIsWhippedCream : Array<String> = []
    
//    /*TEST*/
//
//    var numOfProducts : Int = 1
//    var menuNameArray: Array<String> = ["초콜렛스무디"]
//    var menuSizeArray: Array<String> = ["스몰"]
//    var menuCountArray: Array<Int> = [1]
//    var menuEachPriceArray: Array<Int> = [5000]
//    var menuSugarContent : Array<String> = ["30"]
//    var menuIsWhippedCream : Array<String> = ["NULL"]
    
    /* 즐겨찾기된 menu를 저장하는 배열.*/
//    var menuFavoriteArray: Array<String> = []
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /* 최초에 사용자로부터 pushNotification의 권환을 받기 위한 코드*/
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) {
            (granted, error) in
            // Enable or disable features based on authorization.
            if(granted){
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
    
    /* ======================================================================================================================== */
    
    /* Push Notification에 관련된 protocol */
     
        
    // 토큰 정상 등록(registerForRemoteNotifications()을 호출한 결과가 성공일 때)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("등록된 토큰은 \(deviceTokenString) 입니다.")
        //token = 16CD53C0702E06DE4CF1C8E1D7B8479576B4F55F3C4B46DD48BC56828184DDB6
    }
    
    // 토큰 등록 실패 (registerForRemoteNotifications()을 호출한 결과가 실패)
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("에러 발생 : \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        print("메시지 수신 : \(data)")
        UIApplication.shared.applicationIconBadgeNumber += 1
    }
    /* ======================================================================================================================== */
    
    
    
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
    func applicationDidBecomeActive(_ application: UIApplication) {
        KOSession.handleDidBecomeActive()
    }
    

}
