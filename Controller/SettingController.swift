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
    
    @IBOutlet weak var userProfileImage_View: UIImageView!
    
    @IBOutlet weak var userProfileName_Label: UILabel!
    
    
    @IBOutlet weak var profile_View: UIView!
    
    @IBOutlet weak var settingTitle_View: UIView!
    
    @IBOutlet weak var setting_View: UIView!
    
    
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
    
    /* view 둥글게 만들기 */
    func makeCircularShape(view: UIView){
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
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
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "메인으로 뒤로가기"
        self.navigationItem.title = "프로필"
        
        /* 말하기 속도 조절 */
        if let rate = UserDefaults.standard.string(forKey: "speechSpeedRate"){
            speechSpeedControl_Slider.value = Float(rate)!
        }else{
            speechSpeedControl_Slider.value = 0.5

        }
        
        /* 사용자 프로필 이미지 */
        if let imageUrl = UserDefaults.standard.string(forKey: "profileImageUrl"){
            let url = URL(string: imageUrl)
            do {
                let data = try Data(contentsOf: url!)
                self.userProfileImage_View.image = UIImage(data: data)
            }catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
        
        /* 사용자 아이디 */
        self.userProfileName_Label.text = "안녕하세요. \(UserDefaults.standard.string(forKey: "id")!)님"
        
        self.makeCircularShape(view: self.userProfileImage_View) 
        
        /* 테두리 */
        
        
        self.profile_View.layer.borderWidth = 0.35
        self.profile_View.layer.borderColor = UIColor.gray.cgColor
        
        self.settingTitle_View.layer.borderWidth = 0.35
        self.settingTitle_View.layer.borderColor = UIColor.gray.cgColor
        
        self.setting_View.layer.borderWidth = 0.35
        self.setting_View.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    
    
    
}

