//
//  LoginController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate{
    
    // MARK: - Propery
    // MARK: IBOutlet
    @IBOutlet weak var id_Textfield: UITextField!
    @IBOutlet weak var pwd_Textfield: UITextField!
    @IBOutlet weak var autoLogIn_Switch: UISwitch!
    @IBOutlet weak var login_Btn: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeLogin()
        self.initializeKeyboard()
        
    }
    
    
    // MARK: - Method
    // MARK: Custom Method
    
    func initializeLogin() {
        
        autoLogIn_Switch.isHidden = true // 자동로그인 버튼 숨기기
        autoLogIn_Switch(self) // 자동 로그인: 항상 ON 되있음
    }
    
    // Textfield 선택 시 키보드 크기만큼 view를 올리기 위한 초기 설정
    func initializeKeyboard() {
        
        id_Textfield.delegate = self
        pwd_Textfield.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
         self.view.frame.origin.y = -150 // view를 150 위로
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {

        self.view.frame.origin.y = 0 // view 를 원래 자리로 이동
    }
    
    // TextField 입력 시 화면이 올라가도록
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder() // textField의 상태를 포기 -> 키보드 내려감

        return true
    }
    
    // Alert Message 생성
    func alertMessage(_ title: String, _ description: String) {
        
        DispatchQueue.main.async{
            
            let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert) // Alert message 설정

            let defaultAction = UIAlertAction(title: "OK", style: .destructive) // 버튼 설정
            alert.addAction(defaultAction)                                      // 및 추가

            self.present(alert, animated: false, completion: nil) // Alert Message 띄우기
        }
    }
    
    
    // MARK: IBAction
    @IBAction func loginBtn(_ sender: Any) {
        
        CustomHttpRequest().phpCommunication(url: "app_login.php", postString: "mode=login&id=\(id_Textfield.text!)&pwd=\(pwd_Textfield.text!)"){
            responseString in
            
            // 로그인 성공 시
            if (responseString == "login success") {

                DispatchQueue.main.async{
                    if self.autoLogIn_Switch.isOn {
                        
                        UserDefaults.standard.set(self.id_Textfield.text!, forKey: "id")
                        UserDefaults.standard.set(self.pwd_Textfield.text!, forKey: "pwd")
                        
                        // UserDefaults 에 favoirteMenu를 설정
                        let favoirteMenuArray : Array<String> = []
                        UserDefaults.standard.set(favoirteMenuArray, forKey: "favoirteMenuArray")
                        
                        // 메인 메뉴로 전환
                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Main_NavigationController") {
                            controller.modalTransitionStyle = .coverVertical
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
                
            // 로그인 실패 시
            }else if responseString == "login fail" {
                
                self.alertMessage("로그인 실패", "아이디 및 비밀번호를 확인해주세요")
            }
            
        } // [End of phpCommunication]
    }
    
    @IBAction func signUp_Btn(_ sender: Any) {
        
        CustomHttpRequest().phpCommunication(url: "app_login.php", postString: "mode=signup&id=\(id_Textfield.text!)&pwd=\(pwd_Textfield.text!)") {
            responseString in
                        
            // 회원가입 성공 시
            if responseString == "signup success" {
                self.alertMessage("회원가입 성공", "환영합니다")
                
            // 회원가입 실패 시
            }else if responseString == "signup fail" {
                self.alertMessage("회원가입 실패", "이미 존재하는 아이디입니다")
            }
            
        }
    }
    
    @IBAction func autoLogIn_Switch(_ sender: Any) {
        
        // 자동 로그인 ON
        if autoLogIn_Switch.isOn {
            
            self.autoLogIn_Switch.accessibilityLabel = "자동 로그인 기능이 켜졌습니다"
            self.autoLogIn_Switch.accessibilityValue = nil
            
            // KaKao 간편 로그인
            guard let isOpened = KOSession.shared()?.isOpen() else { return }
            
            // 카카오 간편 로그인되있는 경우
            if isOpened {
                // 화면 전환
                DispatchQueue.main.async {
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Main_NavigationController") {
                        controller.modalTransitionStyle = .coverVertical
                        self.present(controller, animated: true, completion: nil)
                    }
                }
                
            // 일반 로그인이 되있는 경우: 서비스 자체 계정으로 로그인
            }else if let userId = UserDefaults.standard.string(forKey: "id") {
                
                self.id_Textfield.text = userId
                self.pwd_Textfield.text = UserDefaults.standard.string(forKey: "pwd")!
                
                loginBtn(self)
            }
            
        // 자동 로그인 OFF
        }else {
                
            self.login_Btn.setTitle("로그인", for: .normal)
            UserDefaults.standard.set(nil, forKey: "id")
            UserDefaults.standard.set(nil, forKey: "pwd")
            
            self.autoLogIn_Switch.accessibilityLabel = "자동 로그인 기능이 꺼졌습니다"
        }
    }

    @IBAction func kakaoLogin(_ sender: Any) {
        
        //이전 카카오톡 세션 열려있으면 닫기
        guard let session = KOSession.shared() else { return }
        
        if session.isOpen() {
            session.close()
        }
        
        session.open(completionHandler: { (error) -> Void in
            if error == nil {
                if session.isOpen() {
                    
                    // AccessToken
                    print("토큰:", session.token?.accessToken)
                    KOSessionTask.userMeTask(completion: { (error, user) in
                        
                        print("에러:", error)
//                        print("유저:", user)
                        
                        guard let nickname = user?.account?.profile?.nickname else {return}
                        guard let profileImageUrl = user?.account?.profile?.profileImageURL else {return}
                        print("닉네임:", nickname)
                        print("프로필 사진 주소:", profileImageUrl)
                        
                        // 프로필 이미지 설정
                        UserDefaults.standard.set(profileImageUrl.absoluteString, forKey: "profileImageUrl")
//                        print(UserDefaults.standard.string(forKey: "profileImageUrl"))
                        
                        
                        CustomHttpRequest().phpCommunication(url: "app_login.php", postString: "mode=signup&id=\(nickname)&pwd=nil"){
                            _ in
                            
                            UserDefaults.standard.set(nickname, forKey: "id")
                            
                            DispatchQueue.main.async{
                                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Main_NavigationController"){
                                    controller.modalTransitionStyle = .coverVertical
                                    self.present(controller, animated: true, completion: nil)
                                }
                            }
                            
                        }
                    })
                    
                } else {
                    print("Login failed")
                }
            } else {
                print("Login error : \(String(describing: error))")
            }
            
            if !session.isOpen() {
                if let error = error as NSError? {
                    
                    switch error.code {
                    case Int(KOErrorCancelled.rawValue):
                        break
                    default:
                        //간편 로그인 취소
                        print("error : \(error.description)")
                    }
                }
            }
        })
        
    }
}
