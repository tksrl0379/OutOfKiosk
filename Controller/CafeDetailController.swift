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

/* 다이어로그 플로우 넣는 곳 */
class CafeDetailController : UIViewController{
    
    
    var receivedValueFromBeforeVC : Int?
    
    
    /*coffee_btn누를시 커피에 관련된 메뉴가 나와야한다.
     mysql php 통신이 필요함.
     이곳에선 dictionary로 키,밸류 {0:coffee, 1:smoothie }처럼 만들고
     DetailMenuController에 키를 전달한다.
     DetailMenuController에서는 밸류값을 php통신으로 mysql에 있는
     값을 관련 데이터값들을 불러온다.
     */
    
    @IBAction func coffee_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            //아니면 종료
            return}
        
        //phpGetData("coffee"){
        phpGetData("1"){ //"1"은 coffee의 대한 카테코리 넘버이다.
            
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
        
        phpGetData("2"){ //"2"은 smoothie의 대한 카테코리 넘버이다.
            
            (willgetCategroyName,willgetCategroyPrice) in
            
            rvc.willgetCategroyName = willgetCategroyName
            rvc.willgetCategroyPrice = willgetCategroyPrice
            self.navigationController?.pushViewController(rvc, animated: true)
        }
    }
        
    /*
     phpGetData는 Alamofire의 통신(비동기)의 Return값을 전달해 주어야 한다.
     따라서 @escaping 방식을 사용하여, NSDictionary에서 파싱한 여러 Array값을 받는다면 그 때, Btn_Method의 값을 전달한다.
     */
    
    //func phpGetData(_ category : String, handler: @escaping (Array<String>,Array<Int>)->Void ){
    func phpGetData(_ category : String, handler: @escaping (Array<String>,Array<Int>)->Void ){
        
        let parameter: Parameters=[
            "category":category
        ]
        
        let URL_GET_PRODUCT = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/detailMenu/api/category.php"
        
        Alamofire.request(URL_GET_PRODUCT, method: .post, parameters: parameter).responseJSON{
            response in
            
            switch response.result{
                
            case .success:
                
                if let result = response.result.value {
                    
                    var willgetCategroyName : Array<String> = []
                    var willgetCategroyPrice : Array<Int> = []
                    
                    /*
                     jsonData=Dictionary값이며  key:[name, price] 형식이다.(1/9)
                     각각의 타입형에 맞게 배열을 선언하며 jsonData.allValue[i]를 사용하여 인덱스의 맞는 value값을 뽑는다.
                     데이터를 각각의 배열에 저장하며, 저장된 배열 데이터들은 rvc를 통해 다음 View에 navigation형식으로 보내진다.
                     */
                    
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    for i in 0..<jsonData.count{
                        let productdata = jsonData.allValues[i] as! NSArray
                        
                        let name = productdata[0] as! String
                        let price = productdata[1] as! Int
                        
                        willgetCategroyName.append(name)
                        willgetCategroyPrice.append(price)
                    }
                    handler(willgetCategroyName,willgetCategroyPrice)
                }
                
            default :
                fatalError("received non-dictionary JSON response")
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(receivedValueFromBeforeVC)
        //        test_Text.text = String(receivedValueFromBeforeVC!)
        
        //DialogFlow 팝업창 띄우기
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as! DialogFlowPopUpController
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        vc.blurEffectView = blurEffectView
        vc.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        vc.modalPresentationStyle = .pageSheet
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    
}
