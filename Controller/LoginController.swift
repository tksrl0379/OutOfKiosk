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
//import CoreLocation


/* 로그인, 회원가입 기능: php, mysql server와 통신하여 로그인, 회원가입 구현 */
class LoginController: UIViewController, UITextFieldDelegate{//}, CLLocationManagerDelegate{
    
    @IBOutlet weak var id_Textfield: UITextField!
    @IBOutlet weak var pwd_Textfield: UITextField!
    @IBOutlet weak var autoLogIn_Switch: UISwitch!
    @IBOutlet weak var login_Btn: UIButton!
    
//    var locationManager: CLLocationManager! //responsible for requesting location permission from users
    
    func alertMessage(_ title: String, _ description: String){
        
        /* Alert는 MainThread에서 실행해야 함 */
        DispatchQueue.main.async{
            
            /* Alert message 설정 */
            let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
            
            /* 버튼 설정 및 추가*/
            let defaultAction = UIAlertAction(title: "OK", style: .destructive) { (action) in
                
            }
            alert.addAction(defaultAction)

            
            /* Alert Message 띄우기 */
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    /* php 서버를 통해 mysql 서버와 통신하는 함수 */
    func phpCommunication(_ mode: String){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/app_login.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "mode=\(mode)&id=\(id_Textfield.text!)&pwd=\(pwd_Textfield.text!)"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString!)")
            
            /* php서버와 통신 시 NSString에 생기는 개행 제거 */
            responseString = responseString?.trimmingCharacters(in: .newlines) as NSString?
            
            
            /* Alert Message 띄우는 부분 */
            /* 회원가입 성공 시 */
            if(responseString == "signup success"){
                
                self.alertMessage("회원가입 성공", "환영합니다")
                
            /* 회원가입 실패 시 */
            }else if(responseString == "signup fail"){
                
                self.alertMessage("회원가입 실패", "이미 존재하는 아이디입니다")
                
            /* 로그인 실패 시 */
            }else if(responseString == "login fail"){
                
                self.alertMessage("로그인 실패", "아이디 및 비밀번호를 확인해주세요")
                
            }
            
            
            /* 로그인 성공 시 화면 전환 */
            if (responseString! == "login success") {
                DispatchQueue.main.async{
                    if(self.autoLogIn_Switch.isOn){
                        UserDefaults.standard.set(self.id_Textfield.text!, forKey: "id")
                        UserDefaults.standard.set(self.pwd_Textfield.text!, forKey: "pwd")

                        /* UserDefaults 에 favoirteMenu를 설정한다.*/
                        let favoirteMenuArray : Array<String> = []
                        UserDefaults.standard.set(favoirteMenuArray, forKey: "favoirteMenuArray")

                    }
                }
                
                
                /* 화면 전환은 main 쓰레드에서만 가능하므로 main 쓰레드에서 돌아가도록 설정 */
                DispatchQueue.main.async{
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Main_NavigationController"){
                        controller.modalTransitionStyle = .coverVertical
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
        //실행
        task.resume()
    }
    
    @IBAction func login_Btn(_ sender: Any) {
        phpCommunication("login")
    }
    
    
    @IBAction func signUp_Btn(_ sender: Any) {
        phpCommunication("signup")
    }
    
    
    @objc func keyboardWillShow(_ sender: Notification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {

        self.view.frame.origin.y = 0 // Move view to original position
    }

    /* UITextFieldDelegate 함수 오버라이딩 : return을 누르면 수행할 작업 기재 */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // textField의 상태를 포기 -> 키보드 내려감
            textField.resignFirstResponder()

            return true
    }
    
    
    
    @IBAction func autoLogIn_Switch(_ sender: Any) {
        if autoLogIn_Switch.isOn{
            self.login_Btn.setTitle("자동 로그인", for: .normal)
            
            self.autoLogIn_Switch.accessibilityLabel = "자동 로그인 기능이 켜졌습니다"
            self.autoLogIn_Switch.accessibilityValue = nil
           
        }else{
            self.login_Btn.setTitle("로그인", for: .normal)
            UserDefaults.standard.set(nil, forKey: "id")
            UserDefaults.standard.set(nil, forKey: "pwd")
            
            self.autoLogIn_Switch.accessibilityLabel = "자동 로그인 기능이 꺼졌습니다"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //         비콘 권한 설정하기
//        locationManager = CLLocationManager()   // locationManager 초기화.
//        locationManager.delegate = self // locationManager 초기화.
//        locationManager.requestAlwaysAuthorization()    // 위치 권한 받아옴.
//        locationManager.allowsBackgroundLocationUpdates
        
        autoLogIn_Switch(self)
        
        /* textfield 선택 시 키보드 크기만큼 view를 올리기 위함 */
        id_Textfield.delegate = self
        pwd_Textfield.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)


        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        /* 자동 로그인 기능 */
        if let userId = UserDefaults.standard.string(forKey: "id"){
            //print(userId)
            self.id_Textfield.text = userId
            self.pwd_Textfield.text = UserDefaults.standard.string(forKey: "pwd")!
            
            login_Btn(self)
        }
        
        
        

    }
}




