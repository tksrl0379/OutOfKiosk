//
//  CustomButton.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/07/04.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class CustomizedButton: UIButton {
    
    // 밖에서 CustomButton() 으로 불러도 init(frame: CGRect)는 호출됨
    // Code
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initializeBtn()
    }
    
    // Storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initializeBtn()
    }
    
    func initializeBtn() {
        self.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        self.setImage(UIImage(named:"left_image"), for: .normal)
        
    }
    
    
}

class BackButton: UIBarButtonItem {
    var button: UIButton!
    weak var controller: UIViewController!
    
    // Code
    init(controller: UIViewController) {
        super.init()
        
        self.controller = controller
        self.initializeBackBtn(controller: controller)
        
    }
    
    // Storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func initializeBackBtn(controller: UIViewController) {
        let button = CustomizedButton(frame: .zero)
        button.addTarget(controller, action: #selector(SettingController.buttonAction(_:)), for: UIControl.Event.touchUpInside)

        self.customView = button
        self.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        self.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
}


