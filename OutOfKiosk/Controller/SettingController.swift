//
//  SettingController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class SettingController : UIViewController{
    
    // MARK: - Property
    // MARK: IBOutlet
    @IBOutlet weak var speechSpeedControl_Slider: UISlider!
    
    @IBOutlet weak var settingTitle_View: UIView!
    @IBOutlet weak var setting_View: UIView!
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.initializeBackBtn()
        self.initializeView()
        self.initializeSpeechRate()
    }
    
    
    // MARK: - Method
    // MARK: Custom Method
    
    // view 둥글게 만들기
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
    
    func initializeBackBtn() {
        
        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "메인으로 뒤로가기"
        self.navigationItem.title = "프로필"
    }
    
    func initializeView() {
        
        self.settingTitle_View.layer.borderWidth = 0.35
        self.settingTitle_View.layer.borderColor = UIColor.gray.cgColor
        
        self.setting_View.layer.borderWidth = 0.35
        self.setting_View.layer.borderColor = UIColor.gray.cgColor
    }
    
    func initializeSpeechRate() {
        
        // 말하기 속도 조절
        if let rate = UserDefaults.standard.string(forKey: "speechSpeedRate"){
            speechSpeedControl_Slider.value = Float(rate)!
        }else{
            speechSpeedControl_Slider.value = 0.5

        }
    }
    
    
    // MARK: IBAction
    @IBAction func speechSpeedControl_Slider(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "speechSpeedRate")
    }
}

