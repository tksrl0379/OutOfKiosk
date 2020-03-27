//
//  SettingController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class SettingController : UIViewController{
    
    @IBOutlet weak var speechSpeedControl_Slider: UISlider!
    
    
    @IBAction func speechSpeedControl_Slider(_ sender: UISlider) {
        print(sender.value)
        UserDefaults.standard.set(sender.value, forKey: "speechSpeedRate")
        
        
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
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        /* backButton 커스터마이징 */
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        backBtn.setImage(UIImage(named:"left_image"), for: .normal)
        backBtn.addTarget(self, action: #selector(SettingController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "메인으로 가는 뒤로가기"
        
        /* 말하기 속도 조절 */
        if let rate = UserDefaults.standard.string(forKey: "speechSpeedRate"){
            speechSpeedControl_Slider.value = Float(rate)!
        }else{
            speechSpeedControl_Slider.value = 0.5

        }
        
        
    }
    
    
    
    
    
}

