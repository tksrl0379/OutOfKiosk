//
//  LoginController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//



/*
 1. 프로퍼티(Property): 저장 프로퍼티 / 연산 프로퍼티(get, set)
 : 저장 프로퍼티는 var, let을 이용. 클래스나 구조체에 소속되어 사용되는 변수
 
 2. Outlet / Action
Outlet -> 객체 참조 : 화면상의 객체를 소스코드에서 참조
Action -> 객체 이벤트 제어 : 특정 객체에 이벤트가 발생시 이를 처리하기 위함
 
 2. 화면 추가 방법
 -1. present / dismiss : 뷰 컨트롤러에서 다른 컨트롤러 호출.
 -2. push / pop : 네비게이션 컨트롤러 이용 (back button 달림)
 
  다른 2가지 방법도 있으나 권장되지 않음.
*/

import UIKit

class LoginController: UIViewController{
    
    @IBOutlet weak var id_Textfield: UITextField!
    @IBOutlet weak var pwd_Textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func login_Btn(_ sender: Any) {
        if (id_Textfield.text == "text" && pwd_Textfield.text == "text"){
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Main_NavigationController"){
                controller.modalTransitionStyle = .coverVertical
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
}
