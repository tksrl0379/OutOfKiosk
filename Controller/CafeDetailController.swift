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
class CafeDetailController : UIViewController{
    
    
    var receivedValueFromBeforeVC : Int?
    
    /* DialogFlow 로 주문하기 버튼 */
    @IBOutlet weak var orderMenuByAI_Btn: UIButton!
    
    
    /* DialogFlowPopUpController로 넘어감 */
    @IBAction func orderMenuByAI_Btn(_ sender: Any) {
        /* 영민이 버젼 코드.
         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyBoard.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as! DialogFlowPopUpController
         
         vc.modalPresentationStyle = .pageSheet
         self.present(vc, animated: true, completion: nil)
         */
        
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as? DialogFlowPopUpController else {
            return}
        
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    
    
    
    
    /*
     커피에 관련된 메뉴로 전환. mysql php 통신을 통해
     phpGetData() 함수를 통해 DetailMenuController 에 메뉴에 대한 value를 Array type에 담아서 전송.
     */
    @IBAction func coffee_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            //아니면 종료
            return}
        
        /* phpGetData는 Escaping closure 사용. 따라서 phpGetData 실행 후 대괄호 안의 코드 실행 */
        phpGetData(1){ //1은 coffee의 대한 카테코리 넘버.
            
            (willgetCategroyName,willgetCategroyPrice) in
            
            rvc.willgetCategroyName = willgetCategroyName
            rvc.willgetCategroyPrice = willgetCategroyPrice
            self.navigationController?.pushViewController(rvc, animated: true)
        }
        
    }
    
    @IBAction func smoothie_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            //아니면 종료
            return}
        
        phpGetData(7){ //7은 smoothie의 대한 카테코리 넘버이다.
            
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
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingBasketController") as? ShoppingBasketController else {

            return}
        
        //rvc.testshoppingList = ["a","b","c"]
        

        self.navigationController?.pushViewController(rvc, animated: true)
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
            "category":category
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
                        
                        willgetCategroyName.append(name)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderMenuByAI_Btn.setTitle("테스트", for: .normal)
        
        
        //print(receivedValueFromBeforeVC)
        //        test_Text.text = String(receivedValueFromBeforeVC!)
        
        
        
        /*ORIGINAL : DialogFlow 팝업창 띄우기
         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyBoard.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as! DialogFlowPopUpController
         
         /*블러 효과 주는 이펙트
         let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
         let blurEffectView = UIVisualEffectView(effect: blurEffect)
         blurEffectView.frame = view.bounds
         blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         view.addSubview(blurEffectView)
         vc.blurEffectView = blurEffectView
         vc.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
         */
         vc.modalPresentationStyle = .pageSheet
         self.present(vc, animated: true, completion: nil)
         
         */
        
    }
    
    
}
