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
    
    private var userId: String?
    private var purchaseCount: Float = 0
    
    @IBOutlet weak var title_View: UIView!
    @IBOutlet weak var sub_View: UIView!
    @IBOutlet weak var sub2_View: UIView!
    @IBOutlet weak var progressBar_view: UIView!
    
    @IBOutlet weak var storeSelect_Btn: UIButton!
    @IBOutlet weak var favorite_Btn: UIButton!
    
    
    @IBOutlet weak var purchaseCount_Label: UILabel!
    @IBOutlet weak var grade_Label: UILabel!
    
    
    
    /* 가게 선택 버튼 */
    @IBAction func storeSelect_Btn(_ sender: Any) {

        var storeNameArray: Array<String>?  = []
        var storeCategoryArray: Array<String>? = []
        var storeEnNameArray: Array<String>? = []
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "StoreListController") as? StoreListController else { return }
        
        self.phpGetStoreInfo(){
            dict in
            
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
    func addShadow(btn : UIButton){
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 5, height: 5)
        btn.layer.shadowRadius = 0.5
        
        btn.layer.cornerRadius = 1
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
    
    func getPurchaseCount(handler: @escaping (_ responseStrng : NSString?) -> Void){
        /* php 통신 */
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/getUserInfo.php")! as URL)
        request.httpMethod = "POST"
        
        //        let postString = "name=\(self.name!)&size=\(self.size!)&count=\(self.count!)"
        let postString = "id=\(self.userId!)"
        print(self.userId!)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            /* php서버와 통신 시 NSString에 생기는 개행 제거 */
            responseString = responseString?.trimmingCharacters(in: .newlines) as NSString?
            
            print("responseString = \(responseString!)")
            
            /* UI 변경은 메인쓰레드에서만 가능 */
            
            //self.speechAndText(textResponse + " 총 \(responseString!)원입니다. 주문하시겠습니까 ?")
            handler(responseString)
            
        }
        task.resume()
    }
    
    func phpGetStoreInfo(handler: @escaping (_ storeInfoDic : NSDictionary)->Void){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/getStoreInfo.php")! as URL)
        request.httpMethod = "POST"
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString!)")
            
            
            let dict = CustomConvert().convertStringToDictionary(text: responseString as! String)
            
            handler(dict!)
        }
        
        //실행
        task.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.6)
        self.navigationController?.navigationBar.layer.shadowRadius = 4
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        
        title_View.layer.shadowColor = UIColor.black.cgColor
        title_View.layer.shadowOpacity = 0.3
        title_View.layer.shadowOffset = .zero
        title_View.layer.shadowRadius = 4
        title_View.layer.cornerRadius = 5
        
        sub_View.layer.shadowColor = UIColor.black.cgColor
        sub_View.layer.shadowOpacity = 0.3
        sub_View.layer.shadowOffset = .zero
        sub_View.layer.shadowRadius = 4
        sub_View.layer.cornerRadius = 5
        
        sub2_View.layer.shadowColor = UIColor.black.cgColor
        sub2_View.layer.shadowOpacity = 0.3
        sub2_View.layer.shadowOffset = .zero
        sub2_View.layer.shadowRadius = 4
        sub2_View.layer.cornerRadius = 5
        
        storeSelect_Btn.layer.cornerRadius = 5
        
        favorite_Btn.layer.cornerRadius = 5
        
        
        let cp = CircularProgressView(frame: CGRect(x: 35.5, y: 16.5, width: 120.0, height: 120.0))
        cp.trackColor = UIColor(red: 188.0/255.0, green: 188.0/255.0, blue: 188.0/255.0, alpha: 0.3)
        cp.progressColor = UIColor.systemYellow
        cp.tag = 101
        self.sub2_View.addSubview(cp)
        //cp.center = self.progressBar_view.center
        
        //CircularProgress.trackColor = UIColor.white
        //CircularProgress.progressColor = UIColor.purple
        //CircularProgress.setProgressWithAnimation(duration: 1.0, value: 0.3)
        
        
        userId = UserDefaults.standard.string(forKey: "id")!
        
        //id_Label.text = userId! + " 님은"
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController!.isNavigationBarHidden = true
        
        
        self.getPurchaseCount(){
            responseString in
            DispatchQueue.main.async {
                self.purchaseCount_Label.text = (responseString! as String) as String + " / 25"
                self.purchaseCount = Float(responseString! as String)! / 25.0
                
                self.grade_Label.text = "Bronze"
                self.grade_Label.accessibilityLabel = "현재 브론즈 단계이시며 실버 단계까지 주문 \(25 - Int(responseString! as String)!)번 남았습니다"
                
                
                self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
                
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.isNavigationBarHidden = false
    }
    
    
    @objc func animateProgress() {
        let cP = self.view.viewWithTag(101) as! CircularProgressView
        cP.setProgressWithAnimation(duration: 0.4, value: self.purchaseCount)
        
    }
    
}
