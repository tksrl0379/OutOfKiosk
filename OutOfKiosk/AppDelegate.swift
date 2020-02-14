//
//  AppDelegate.swift
//  OutOfKiosk
//
//  Created by a1111 on 2019/12/31.
//  Copyright © 2019 OOK. All rights reserved.
//

import UIKit

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
    
    /*TEST*/
    
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
        
        /*ApiAi를 사용하여, 구글 다이얼로그플로우의 토큰을 받는 과정이다. 초기설정.*/
        /*let configuration = AIDefaultConfiguration()
        configuration.clientAccessToken = "d94411c80a7e46b7bcac2efb46698353"
        */
        
        
        return true
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
        print("background entered")
    }

}

