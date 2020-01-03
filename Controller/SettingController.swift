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
        /* present 한 화면 해제 */
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    
}

