//
//  MainController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class MainController : UIViewController{
    
    /* 사용자 정보 변수 */
    private var userId: String?
    private var purchaseCount: Float = 0
    
    
    @IBOutlet weak var title_View: UIView!
    @IBOutlet weak var sub_View: UIView!
    @IBOutlet weak var sub2_View: UIView!
    
    
    @IBOutlet weak var storeSelect_Btn: UIButton!
    @IBOutlet weak var favorite_Btn: UIButton!
    
    @IBOutlet weak var userProfileImage_View: UIImageView!
    @IBOutlet weak var userProfileName_Label: UILabel!
    @IBOutlet weak var profileSetting_Btn: UIButton!
    
    @IBOutlet weak var progressBar_view: UIView!
    @IBOutlet weak var progress_View: UIView!
    @IBOutlet weak var progressImage_ImageView: UIImageView!
    
    @IBOutlet weak var progressTitle_Label: UILabel!
    @IBOutlet weak var progressComment_Label: UILabel!
    @IBOutlet weak var progressComment2_Label: UILabel!
    @IBOutlet weak var progressComment3_Label: UILabel!
    
    
    
    
    @IBAction func profileSetting_Btn(_ sender: Any) {
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "SettingController") as? SettingController else {return}
        
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(rvc, animated: true)
        }
    }
    
    
    /* 가게 선택 버튼 */
    @IBAction func storeSelect_Btn(_ sender: Any) {

        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "StoreListController") as? StoreListController else { return }
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(rvc, animated: true)
        }
        
    }
    
    /* 즐겨찾기 버튼 */
    @IBAction func favoriteMenu_Btn(_ sender: Any) {
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteMenuController") as? FavoriteMenuController else {return}
        
        var favoriteMenuInfoDict = UserDefaults.standard.object(forKey: "favoriteMenuInfoDict") as? [String:String]

        
        if favoriteMenuInfoDict!.count != 0 {
            
            self.navigationController?.pushViewController(rvc, animated: true)
            
        }else{
            self.alertMessage("오류","즐겨찾기 메뉴가 없어요.")
        }
        
    }
    
    
    /* 즐겨찾기가 비어있을 시 경고 메시지 */
    func alertMessage(_ title: String, _ description: String){
        
        /* Alert는 MainThread에서 실행해야 함 */
        DispatchQueue.main.async{
            
            /* Alert message 설정 */
            let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
            
            /* 버튼 설정 및 추가*/
            let defaultAction = UIAlertAction(title: "확인", style: .destructive) { (action) in
                
            }
            alert.addAction(defaultAction)
            
            /* Alert Message 띄우기 */
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    
    /* view 그림자 넣기 */
    func addShadow(view : UIView){
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        
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
    
    
    /* PushNotification에 반응 */
    @objc func changeProgressTitleView(_ notification: NSNotification){
        guard let alertMSG: String = notification.userInfo?["alert"] as? String else { return }
        
        print("alert :", alertMSG)
        
        /* 1. progress 관련 변수들 내용 변경 */
        if  (alertMSG == "주문이 접수되었습니다.") {
            progressTitle_Label.text = "메뉴 조리 중"
            UserDefaults.standard.set("메뉴 조리 중", forKey: "pushMSG")
            UserDefaults.standard.set(0.66, forKey: "progressNumber")
            animateProgress()
        }
        else if (alertMSG == "주문하신 메뉴가 나왔습니다.") {
            progressTitle_Label.text = "메뉴 완성"
            UserDefaults.standard.set("메뉴 완성", forKey: "pushMSG")
            UserDefaults.standard.set(1.0, forKey: "progressNumber")
            animateProgress()
        }
        else if (alertMSG == "음식을 수령하셨습니다.") {
            progressTitle_Label.text = "아직 주문이 없어요"
            progressComment_Label.text = ""
            progressComment2_Label.text = "진행 주문 없음"
            progressComment3_Label.text = ""
            UserDefaults.standard.set("아직 주문이 없어요", forKey: "pushMSG")
            UserDefaults.standard.set(0, forKey: "progressNumber")
            UserDefaults.standard.set(nil, forKey: "mainProgressStoreName")
            UserDefaults.standard.set("진행 주문 없음", forKey: "mainProgressMenuName")
            UserDefaults.standard.set(nil, forKey: "mainProgressMenuCount")

            animateProgress()
        }
        
        /* 2. VoiceOver 안내 변경 */
        /* 순서: 아직 주문이 없어요 -> 주문 확인 중 -> 메뉴 조리 중 -> 메뉴 완성 */
        if progressTitle_Label.text == "아직 주문이 없어요"{
            progressTitle_Label.accessibilityLabel = progressTitle_Label.text! + ". 주문 후 주문 현황과 주문 정보를 알 수 있어요"
        }
        else if progressTitle_Label.text == "주문 확인 중"{
            progressTitle_Label.accessibilityLabel = "매장에서 주문 확인 중입니다. 조금만 기다려 주세요."
        }
        else if progressTitle_Label.text == "메뉴 조리 중"{
            progressTitle_Label.accessibilityLabel = "매장에서 메뉴를 조리 중입니다. 음식이 나오면 알려드릴게요."
        }
        else if progressTitle_Label.text == "메뉴 완성"{
            progressTitle_Label.accessibilityLabel = "메뉴가 나왔습니다. 음식을 수령해주세요."
        }
        
        
        
    }
    
    /* 원형 애니메이션 */
    @objc func animateProgress() {
        var speed = UserDefaults.standard.float(forKey: "progressNumber")
        let cP = self.view.viewWithTag(101) as! CircularProgressView
        cP.setProgressWithAnimation(duration: 0.4, value: speed)
           
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 가장 최초에만 pushMSG를 nil로 한다.*/
        //UserDefaults.standard.set(nil, forKey: "pushMSG")
        
        
        
        /* 그림자 넣기, 둥글게 만들기 */
        self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.6)
        self.navigationController?.navigationBar.layer.shadowRadius = 4
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        addShadow(view: title_View)
        addShadow(view: sub_View)
        addShadow(view: sub2_View)
        
        title_View.layer.cornerRadius = 25
        sub_View.layer.cornerRadius = 40
        sub2_View.layer.cornerRadius = 40
        
        makeCircularShape(view: progress_View)
        makeCircularShape(view: userProfileImage_View)
        makeCircularShape(view: progressTitle_Label)
        
        storeSelect_Btn.layer.cornerRadius = 40
        favorite_Btn.layer.cornerRadius = 40
        
        
        
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
        userId = UserDefaults.standard.string(forKey: "id")!
        self.userProfileName_Label.text = "\(userId!)님"
        self.profileSetting_Btn.accessibilityLabel = "\(userId!)님 프로필 버튼"
        
        
        
        /* 원형 애니메이션 */
        let cp = CircularProgressView(frame: CGRect(x: 31, y: 14.0, width: 119.5, height: 119.5))
        cp.trackColor = UIColor(red: 230.0/255.0, green: 188.0/255.0, blue: 188.0/255.0, alpha: 0.3)
        cp.progressColor = UIColor.black
        cp.tag = 101
        self.sub2_View.addSubview(cp)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        self.navigationController!.isNavigationBarHidden = true
        
        
        /* 구매 횟수 애니메이션 바 갱신 */
        self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
        
        
        /* progress (주문현황) 관련 변수들 애니메이션 */
        progressComment_Label.alpha = 0
        progressComment2_Label.alpha = 0
        progressComment3_Label.alpha = 0
        progressImage_ImageView.alpha = 0
        
        UIView.animate(withDuration: 1.5) {
            self.progressComment_Label.alpha = 1.0
        }
        UIView.animate(withDuration: 1.5) {
            self.progressComment2_Label.alpha = 1.0
        }
        UIView.animate(withDuration: 1.5) {
            self.progressComment3_Label.alpha = 1.0
        }
        UIView.animate(withDuration: 1.5) {
            self.progressImage_ImageView.alpha = 1.0
        }
        
        /* 주문 현황 갱신하는 부분 */
        
        /* AppDelegate에서 받은 정보를 관찰하는 옵져버 (1. 주문 진행 정도 체크) */
        NotificationCenter.default.addObserver(self, selector: #selector(changeProgressTitleView(_:)), name: NSNotification.Name("TestNotification"), object: nil)
        
        /* progress (2. 주문 현황 갱신) 관련 변수들 : 가게이름, 메뉴 이름, 개수 설정 */
        if let progress = UserDefaults.standard.string(forKey: "pushMSG"){
            progressTitle_Label.text = progress
        }
        if let storeName = UserDefaults.standard.string(forKey: "mainProgressStoreName"){
            progressComment_Label.text = storeName
        }
        if let menuName = UserDefaults.standard.string(forKey: "mainProgressMenuName"){
            progressComment2_Label.text = menuName
        }
        if let numberOfMenu = UserDefaults.standard.string(forKey: "mainProgressMenuCount") {
            print(numberOfMenu)
            if (Int(numberOfMenu) == 1) {
                progressComment3_Label.text = ""
            }else{
                progressComment3_Label.text = "외 \(Int(numberOfMenu)! - 1) "
            }
        }
        
        /* 3. VoiceOver 안내 변경 */
        /* 순서: 아직 주문이 없어요 -> 주문 확인 중 -> 메뉴 조리 중 -> 메뉴 완성 */
        if progressTitle_Label.text == "아직 주문이 없어요"{
            progressTitle_Label.accessibilityLabel = progressTitle_Label.text! + ". 주문 후 주문 현황과 주문 정보를 알 수 있어요"
        }
        else if progressTitle_Label.text == "주문 확인 중"{
            progressTitle_Label.accessibilityLabel = "매장에서 주문 확인 중입니다. 조금만 기다려 주세요."
        }
        else if progressTitle_Label.text == "메뉴 조리 중"{
            progressTitle_Label.accessibilityLabel = "매장에서 메뉴를 조리 중입니다. 음식이 나오면 알려드릴게요."
        }
        else if progressTitle_Label.text == "메뉴 완성"{
            progressTitle_Label.accessibilityLabel = "메뉴가 나왔습니다. 음식을 수령해주세요."
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.isNavigationBarHidden = false
        
    }
    
    
    
}
