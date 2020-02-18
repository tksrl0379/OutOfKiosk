//
//  SettingController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class SettingController : UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    /* 로그아웃 버튼 */
    @IBAction func logout_Btn(_ sender: Any) {
        KOSession.shared()?.logoutAndClose { [weak self] (success, error) -> Void in
            UserDefaults.standard.set(nil, forKey: "id")
            UserDefaults.standard.set(nil, forKey: "pwd")
            UserDefaults.standard.set(nil, forKey: "profileImageUrl")
            /* present 한 화면 해제 */
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
}

