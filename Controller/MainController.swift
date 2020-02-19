//
//  MainController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit
import Alamofire

class MainController : UIViewController{
    
    /* 사용자 정보 변수 */
    private var userId: String?
    private var purchaseCount: Float = 0
    
    
    @IBOutlet weak var title_View: UIView!
    //@IBOutlet weak var title_View: UIView!
    @IBOutlet weak var sub_View: UIView!
    @IBOutlet weak var sub2_View: UIView!
    @IBOutlet weak var progressBar_view: UIView!
    
    @IBOutlet weak var storeSelect_Btn: UIButton!
    @IBOutlet weak var favorite_Btn: UIButton!
    
    
    //@IBOutlet weak var purchaseCount_Label: UILabel!
    //@IBOutlet weak var grade_Label: UILabel!
    
    @IBOutlet weak var userProfileImage_View: UIImageView!
    //@IBOutlet weak var userName_Label: UILabel!
    @IBOutlet weak var welcomeMessage_Label: UILabel!
    @IBOutlet weak var profileSetting_Btn: UIButton!
    
    @IBOutlet weak var progress_View: UIView!
    @IBOutlet weak var progressComment_Label: UILabel!
    
    @IBAction func profileSetting_Btn(_ sender: Any) {
            guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "SettingController") as? SettingController else {return}
        
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(rvc, animated: true)
        }
    }
    
    
    /* 가게 선택 버튼 */
    @IBAction func storeSelect_Btn(_ sender: Any) {

        var storeNameArray: Array<String>?  = []
        var storeCategoryArray: Array<String>? = []
        var storeEnNameArray: Array<String>? = []
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "StoreListController") as? StoreListController else { return }
        
        CustomHttpRequest().phpCommunication(url: "getStoreInfo.php", postString: ""){
            responseString in
            
            let dict = CustomConvert().convertStringToDictionary(text: responseString)!
            
            for i in 0..<dict.count{
                storeNameArray?.append(Array(dict)[i].key as! String)
                
                let sub_info = Array(dict)[i].value as! NSDictionary
                storeCategoryArray?.append(sub_info["category"] as! String)
                storeEnNameArray?.append(sub_info["en_name"] as! String)
                
            }
            
            rvc.storeNameArray = storeNameArray!
            rvc.storeCategoryArray = storeCategoryArray!
            rvc.storeEnNameArray = storeEnNameArray!
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(rvc, animated: true)
            }
            
            
        }
        
    }
    
    /* 즐겨찾기 버튼 */
    @IBAction func favoriteMenu_Btn(_ sender: Any) {
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteMenuController") as? FavoriteMenuController else {return}
        
        
        let defaults = UserDefaults.standard
        let favoriteMenuArray = defaults.stringArray(forKey: "favoriteMenuArray") ?? [String]()
        if favoriteMenuArray.count != 0 {
            rvc.willgetFavoriteMenuName = favoriteMenuArray
            self.navigationController?.pushViewController(rvc, animated: true)
            
        }else{
            self.alertMessage("오류","즐겨찾기 메뉴가 없어요.")
        }
        
    }
    
    
    /* 즐겨찾기가 비어있을 시 경고 메시지 함수*/
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
    
    /* 버튼 그림자 넣기 */
    func addShadow(view : UIView){
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 10
        
    }
    
    
    /*
     phpGetFavoriteData는 Alamofire.request의 Return값을 전달해 주어야 한다. 그런데 Alamofire.request는 비동기 함수이므로
     함수의 절차적인 실행이 보장되지 않는다. 따라서 Alamfire.request의 수행이 완료 된 후 화면전환이 되도록 Escaping Closure를
     사용한다.(@escaping)
     즐겨찾기(favoriteMenus) 테이블에 있는 메뉴들을 해당 사용자에 맞게 갖고 온다.
     */
    func phpGetFavoriteData(handler: @escaping (Array<String>)->Void ){
        let userID = UserDefaults.standard.string(forKey: "id")!
        
        let parameter: Parameters=[
            "userID":userID
        ]
        
        let URL_GET_FAVORITE = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/favoriteMenu/api/getFavoriteMenu.php"
        
        Alamofire.request(URL_GET_FAVORITE, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseString{
            response in
            
            print("\n\n\n\nsponse is: \(response)")
            
            switch response.result{
                
            case .success:
                
                if response.result.value != nil {
                    
                    /*
                     각각의 타입형에 맞게 배열을 선언하며 dict.allValue[i]를 사용하여 인덱스의 맞는 value값을 뽑는다.
                     데이터는 각각의 배열에 저장되어 DetailMenuController로 전송.
                     */
                    var willgetFavoriteMenuName : Array<String> = []
                    
                    let jsonData = response.result.value
                    
                    
                    /* php 통신으로 가져온 데이터가 empty일 경우(즉, 즐겨찾기에 추가된 메뉴가 없을 경우)
                     -> 빈 배열을 전달하여, 즐겨찾기가 없다는 것을 알림메세지로 알려주게 함.
                     */
                    if jsonData == "[]"{
                        
                        handler(willgetFavoriteMenuName)
                        
                        /* 한개 이상의 즐겨찾기 메뉴가 추가되었을 경우 배열로 변환하여 return 한다.*/
                    }else{
                        let dict = CustomConvert().convertStringToDictionary(text: jsonData!)! //as NSDictionary
                        //
                        for i in 0..<dict.count{
                            let productdata = dict.allValues[i] as! NSArray
                            //
                            let menuName = productdata[0] as! String
                            willgetFavoriteMenuName.append(menuName)
                            
                        }
                        
                        handler(willgetFavoriteMenuName)
                    }
                }
                
            default :
                fatalError("received non-dictionary JSON response")
            }
            
        }
    }
    
    func makeCircularShape(view: UIView){
        view.layer.cornerRadius = view.frame.height/2
        view.layer.masksToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        sub2_View.layer.cornerRadius = sub2_View.frame.height/2
        
        makeCircularShape(view: progress_View)
        
        makeCircularShape(view: userProfileImage_View)
        
        storeSelect_Btn.layer.cornerRadius = 40
        favorite_Btn.layer.cornerRadius = 40
        
        
        
        /* 원형 애니메이션 */
        let cp = CircularProgressView(frame: CGRect(x: 31, y: 14.0, width: 119.5, height: 119.5))
        cp.trackColor = UIColor(red: 230.0/255.0, green: 188.0/255.0, blue: 188.0/255.0, alpha: 0.3)
        cp.progressColor = UIColor.systemOrange
        cp.tag = 101
        self.sub2_View.addSubview(cp)
        
        
        
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
        
        //self.userName_Label.text = userId
        self.welcomeMessage_Label.text = "\(userId!)님"
        //id_Label.text = userId! + " 님은"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController!.isNavigationBarHidden = true
        
//        CustomHttpRequest().phpCommunication(url: "getUserInfo.php", postString: "id=\(self.userId!)"){
//            responseString in
//
//            DispatchQueue.main.async {
//                //self.purchaseCount_Label.text = (responseString) as String + " / 25"
//                self.purchaseCount = Float(responseString)! / 25.0
//
//                //self.grade_Label.text = "Bronze"
//                //self.grade_Label.accessibilityLabel = "현재 브론즈 단계이시며 실버 단계까지 주문 \(25 - Int(responseString! as String)!)번 남았습니다"/* 구매 횟수 애니메이션 바 갱신 */
//                self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
//
//
//
//            }
//        }
        /* 구매 횟수 애니메이션 바 갱신 */
        self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
        progressComment_Label.alpha = 0
        UIView.animate(withDuration: 1.5) {
            self.progressComment_Label.alpha = 1.0
            
        }
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.isNavigationBarHidden = false
    }
    
    
    @objc func animateProgress() {
        let cP = self.view.viewWithTag(101) as! CircularProgressView
        cP.setProgressWithAnimation(duration: 0.4, value: 0.25)
        
    }
    
}
