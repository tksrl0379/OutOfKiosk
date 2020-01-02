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
 
 3. 화면 추가 방법
 -1. present / dismiss : 뷰 컨트롤러에서 다른 컨트롤러 호출.
 -2. push / pop : 네비게이션 컨트롤러 이용 (back button 달림)
 
  다른 2가지 방법도 있으나 권장되지 않음.
 
 4. instantiateViewController
 : (보통 controller의) id를 이용하여 view controller를 만듦.
 
 5. as! vs as?
 : as? 면 다운캐스팅 불가 시 nil 반환. 또한 nil인지 아닌지 확신할 수 없기 때문에 vc? 로 사용해야 함. as!면 다운캐스팅 불가 시 error 발생하며 nil이 아님이 확실하므로 vc로 사용 가능
 예시는 StoreListController에 있음
 
 6. delegate
 : 대신 해달라고 부탁하는 객체(프로토콜). 대신 처리해주는 객체(대리자)가 존재.
 TableView의 경우 TableView가 대신 해달라고 부탁하는 객체. TableView를 사용하는 ViewController가 대신 처리해주는 객체가 됨.
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
