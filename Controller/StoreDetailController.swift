//
//  StoreDetailController.swift
//  OutOfKiosk
//
//  Created by a1111,Jinseo Park on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

//Dialogflow
//testtest jinseo

//This is IOS_branch
import UIKit
import Alamofire

/* 가게 접속하면 뜨는 메인 화면 */
class StoreDetailController : UIViewController{
    
    /* 가게 상세 정보 관련 변수들 */
    var storeName: String?
    var storeEnName : String?
    var storeMenuNameArray: Array<String> = [String](repeating: "0", count: 6)
    
    /* voiceover 접근성 전용 */
    @IBOutlet weak var menu_Label: UILabel!
    @IBOutlet weak var storeName_Label: UILabel!
    
    /* php 카테고리별 메뉴 데이터를 가져와서 appDelegate에 속한지 비교 후 T/F값을 전달하는 배열.*/
    var willgetFavoriteTag : Array<String> = []
    
    /* DialogFlow 로 주문하기 버튼 */
    @IBOutlet weak var orderMenuByAI_Btn: UIButton!
    
    /* 리뷰로 넘어가는 버튼 */
    @IBOutlet weak var reviewBtn: UIButton!
    
    /* 메뉴 버튼 관련 변수들 */
    @IBOutlet weak var firstMenu_Btn: UIButton!
    @IBOutlet weak var secondMenu_Btn: UIButton!
    
    /* 경계선 UI 관련 변수들 */
    @IBOutlet weak var border_View: UIView!
    @IBOutlet weak var border2_View: UIView!
    
    /* 챗봇으로 주문할 때마다 숫자 증가*/
    @IBOutlet weak var shoppingBasket_Btn: UIButton!
    
    /* DialogFlowPopUpController로 넘어감 */
    @IBAction func orderMenuByAI_Btn(_ sender: Any) {
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as? DialogFlowPopUpController else {
            return}
        
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    
    @IBAction func reviewMenu_Btn(_ sender: Any) {
        var reviewUserId: Array<String>? = []
        var reviewContents: Array<String>? = []
        var reviewTime: Array<String>? = []
        
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewController") as? ReviewController else {
                   return}
        rvc.storeEnName = self.storeEnName
        phpGetReviewInfo(storeEnName!){
            dict in
            
            for i in 1...dict.count{
                let dict = dict[String(i)] as! NSDictionary
                reviewUserId?.append(dict["userId"] as! String)
                reviewContents?.append(dict["contents"] as! String)
                reviewTime?.append(dict["time"] as! String)
                
            }
        
            rvc.reviewUserId = reviewUserId!
            rvc.reviewContents = reviewContents!
            rvc.reviewTime = reviewTime!
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(rvc, animated: true)
            }
        }
        
    }
    
    
    func phpGetReviewInfo(_ storeEnName : String, handler: @escaping (_ dict : NSDictionary)->Void){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/getReviewInfo.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "storeEnName=\(storeEnName)"
        
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString!)")
            
            
            guard let dict = self.convertStringToDictionary(text: responseString as! String) else {return}
            
            handler(dict)
        }
        
        //실행
        task.resume()
    }
    
    
    
    
    
    /*
     프라푸치노에 관련된 메뉴로 전환. mysql php 통신을 통해
     phpGetData() 함수를 통해 DetailMenuController 에 메뉴에 대한 value를 Array type에 담아서 전송.
     */
    @IBAction func firstMenu_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            //아니면 종료
            return}
        
        /* phpGetData는 Escaping closure 사용. 따라서 phpGetData 실행 후 대괄호 안의 코드 실행 */
        phpGetData(1){ //1은 frapuccino의 대한 카테코리 넘버.
            
            (willgetCategroyName,willgetCategroyPrice) in
            
            rvc.willgetCategroyName = willgetCategroyName
            rvc.willgetCategroyPrice = willgetCategroyPrice

            self.navigationController?.pushViewController(rvc, animated: true)
        }
        
    }
    
    
    @IBAction func secondMenu_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            //아니면 종료
            return}
        
        phpGetData(2){ // 6은 smoothie의 대한 카테코리 넘버이다.
            
            (willgetCategroyName,willgetCategroyPrice) in
            
            rvc.willgetCategroyName = willgetCategroyName
            rvc.willgetCategroyPrice = willgetCategroyPrice
            self.navigationController?.pushViewController(rvc, animated: true)
        }
    }
    
    
    /*
     장바구니가 비어있으면 에러가 나기 때문에, 챗봇으로 인한 rvc값을 넣는다.
     */
    @IBAction func shoppingList_Btn(_ sender: Any) {
        
        /* 주문한 정보가 몇개인지를 알아서 0개일시 주문을 먼저 하라는 메시지를 보내기 위한 기능*/
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        if let count = ad?.numOfProducts{
            if count != 0 {
                guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingBasketController") as? ShoppingBasketController else {
                    return}
                
                
                self.navigationController?.pushViewController(rvc, animated: true)
            }else{
                /* 들어갈 기능 = message alert 혹은 팝업 cotroller를 뛰운다*/
                self.alertMessage(" ","장바구니가 비어있어요")
            }
            
        }
        
    }

    /* 장바구니가 비어있을 시 경고 메시지 함수*/
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
    
    
    
    
    /* Stiring -> Dictionary */
    func convertStringToDictionary(text: String) -> NSDictionary? {//[String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                /* jsonObject: String type json을 Foundation Object로 바꿔줌 */
                /* Foundation Object: NSArray, NSDictionary, NSNumber, NSDate, NSString or NSNull 로 변환 가능 */
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary //[String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    /*
     phpGetData는 Alamofire.request의 Return값을 전달해 주어야 한다. 그런데 Alamofire.request는 비동기 함수이므로
     함수의 절차적인 실행이 보장되지 않는다. 따라서 Alamfire.request의 수행이 완료 된 후 화면전환이 되도록 Escaping Closure를
     사용한다.(@escaping)
     */
    func phpGetData(_ category : Int, handler: @escaping (Array<String>,Array<Int>)->Void ){
        
        let parameter: Parameters=[
            "category":category,
            "storeName":storeEnName!
        ]
        
        let URL_GET_PRODUCT = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/detailMenu/api/category.php"
        
        Alamofire.request(URL_GET_PRODUCT, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseString{
            response in
            
            print("response: \(response)")
            
            switch response.result{
                
            case .success:
                
                if response.result.value != nil {
                    
                    /*
                     각각의 타입형에 맞게 배열을 선언하며 dict.allValue[i]를 사용하여 인덱스의 맞는 value값을 뽑는다.
                     데이터는 각각의 배열에 저장되어 DetailMenuController로 전송.
                     */
                    var willgetCategroyName : Array<String> = []
                    var willgetCategroyPrice : Array<Int> = []
                    
                    /* response는 DataResponse<String> 이므로 response.result.value 을 이용해 String type으로 받음 */
                    let jsonData = response.result.value
                    
                    let dict = self.convertStringToDictionary(text: jsonData!)! //as NSDictionary
                    
                    for i in 0..<dict.count{
                        let productdata = dict.allValues[i] as! NSArray
                        
                        let name = productdata[0] as! String
                        let price = productdata[1] as! Int
                        
                        
                        // 서버로부터 스몰 사이즈 메뉴 정보만 받아옴. ( ex) 모카 프라푸치노 스몰, 모카 스무디 스몰 )
                        willgetCategroyName.append(name.components(separatedBy: "스몰")[0])
                        willgetCategroyPrice.append(price)
                    }
                    /* 두 개의 배열을 handler 클로저 매개변수를 통해 탈출시킨다. */
                    
                    handler(willgetCategroyName,willgetCategroyPrice)
                }
                
            default :
                fatalError("received non-dictionary JSON response")
            }
            
        }
    }
    
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.storeMenuNameArray)
        /* 가게 상세 정보 설정 */
        storeName_Label.text = storeName
        firstMenu_Btn.setTitle(self.storeMenuNameArray[0], for: .normal)
        secondMenu_Btn.setTitle(self.storeMenuNameArray[1], for: .normal)
        
        
        
        
        /* backButton 커스터마이징 */
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        backBtn.setImage(UIImage(named:"left_image"), for: .normal)
        backBtn.addTarget(self, action: #selector(StoreDetailController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        //addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        ///////
        self.orderMenuByAI_Btn.imageView?.contentMode = .scaleAspectFit
        self.orderMenuByAI_Btn.imageEdgeInsets = UIEdgeInsets(top: 70,left: 70,bottom: 70,right: 70)
        self.orderMenuByAI_Btn.frame = CGRect(x: -37, y: 99, width: 180, height: 90)
        orderMenuByAI_Btn.setTitle("                음성주문", for: .normal)
       
        
        
        /* 테두리 만들기 */
        border_View.layer.borderWidth = 0.5
        border_View.layer.borderColor = UIColor.gray.cgColor
        
        border2_View.layer.borderWidth = 0.5
        border2_View.layer.borderColor = UIColor.gray.cgColor
        
        /* 테두리 둥글게 만들기 */
        firstMenu_Btn.layer.cornerRadius = 5
        firstMenu_Btn.layer.borderWidth = 0.2
        firstMenu_Btn.layer.borderColor = UIColor.gray.cgColor
        
        secondMenu_Btn.layer.cornerRadius = 5
        secondMenu_Btn.layer.borderWidth = 0.2
        secondMenu_Btn.layer.borderColor = UIColor.gray.cgColor
        
        shoppingBasket_Btn.layer.cornerRadius = 5
        
        /* 접근성 */
        orderMenuByAI_Btn.accessibilityLabel = "스타벅스 음성주문"
        menu_Label.accessibilityLabel = "아래에 스타벅스 메뉴가 있습니다"
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        //self.navigationController!.navigationBar.isTranslucent = true
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        
//        ad?.numOfProducts = 1
//        ad?.menuNameArray = ["모카스무디"]
//        ad?.menuSizeArray = ["스몰"]
//        ad?.menuCountArray = [3]
//        ad?.menuEachPriceArray = [5300]
//        ad?.menuSugarContent = ["40%"]
//        ad?.menuIsWhippedCream = ["NULL"]
        
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController!.navigationBar.shadowImage = nil
        
    }
    
}
