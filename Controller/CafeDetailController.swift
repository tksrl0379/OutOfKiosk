//
//  StoreDetailController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

//Dialogflow
//testtest jinseo

//This is IOS_branch
import UIKit
import Alamofire

/* 다이어로그 플로우 넣는 곳 */
class CafeDetailController : UIViewController{
    
    /*
     Alamofire통하여 php통신으로 DetailMenuController에 Array값을 줄 것이다.
     Detail에서는 Array
     */
    var arrayOfProduct : [String] = []
    
    var receivedValueFromBeforeVC : Int?
    
    @IBOutlet weak var coffee: UIButton! //
    //    @IBOutlet weak var test_Text: UILabel!
    
 
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
        
        /*ORIGINAL*/
        /*phpGetData("coffee"){
            (returnArray) in //returnarrray는 @escaping을 통해 나온 return 값이다.
            
//            self.arrayOfProduct = returnArray
            rvc.willgetCategroyName = returnArray//self.arrayOfProduct
            //rvc.willgetCategroyName = returnArray//self.arrayOfProduct
            self.navigationController?.pushViewController(rvc, animated: true)
        }*/
        

        phpGetData("coffee"){
                    (jsonData) in //jsonData는 @escaping을 통해 나온 return 값이다.
                    
                    var willgetCategroyName : Array<String> = []
                    var willgetCategroyPrice : Array<Int> = []
//                    var willgetCategroyPrice : Array<String> = []
        
        
                    /*Productdata에는 json형식으로 받은데이터 Name, Price가 저장되어 있다.*/
                    for i in 0..<jsonData.count{
                        let productdata = jsonData.allValues[i] as! NSArray
                        //                    print(type(of: a[0]))
                        
                        let name = productdata[0] as! String
                        let price = productdata[1] as! Int
                        
                        willgetCategroyName.append(name)
                        willgetCategroyPrice.append(price)
                    }
            
//                    print(willgetCategroyPrice)
            
                    rvc.willgetCategroyName = willgetCategroyName//self.arrayOfProduct
                    rvc.willgetCategroyPrice = willgetCategroyPrice//self.arrayOfProduct
                    self.navigationController?.pushViewController(rvc, animated: true)
                }
        
            
//        print(self.arrayOfProduct)
            
        //["coffee","test"]
 
//        rvc.willgetCategroyName = self.arrayOfProduct
        //print("Befor send", self.arrayOfProduct)
        
//        rvc.willgetCategroyName = phpGetData("coffee")
        
        //self.navigationController?.pushViewController(rvc, animated: true)
        
        //"coffee"란 문자열을 전송시켜야한다.
        /*if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }*/
        
    }
    
    
    @IBAction func smoothie_Btn(_ sender: Any) {
        
      //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
                guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
                    //아니면 종료
                    return}
                
                phpGetData("smoothie"){
                            (jsonData) in //jsonData는 @escaping을 통해 나온 return 값이다.
                            var willgetCategroyName : Array<String>!
                            var willgetCategroyPrice : Array<Int>!
                //            self.arrayOfProduct = returnArray
                            for i in 0..<jsonData.count{
                                let a = jsonData.allValues[i] as! NSArray
                                willgetCategroyName.append(a[0] as! String)
                                willgetCategroyPrice.append(a[1] as! Int)
                            }
                            rvc.willgetCategroyName = willgetCategroyName//self.arrayOfProduct
//                            rvc.willgetCategroyPrice = willgetCategroyPrice//self.arrayOfProduct
                            self.navigationController?.pushViewController(rvc, animated: true)
                        }
    }
    
    
    
    //String 배열을 escaping 하여 받겠다.
    //func phpGetData(_ category : String, handler: @escaping ([String])->Void ){
    
    func phpGetData(_ category : String, handler: @escaping (NSDictionary)->Void ){
    
        
        let parameter: Parameters=[
            "category": category
        ]
        
        let URL_GET_PRODUCT = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/detailMenu/api/category.php"
        /*
         callback 함수기에 여기서는 등록만 되고, 실행은 나중에 된다.
         따라서, 동기 처리하여 request가 먼저 되도록 설정.
        
         */
        
        
        Alamofire.request(URL_GET_PRODUCT, method: .post, parameters: parameter).responseJSON{
            response in
            
            switch response.result{
                
//                print(response.result)
            case .success:
                
                if let result = response.result.value {
                    
//                    var arrayOfProductJSON : [String] = []
                    
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    print(jsonData)
                    //                        print("data is " ,jsonData)
                    //displaying the message in label
                    //                self.coffeesName.text = jsonData.value(forKey: "message") as! String?
                    
                    /* jsonData의 allValue를 Array<String>으로 받는다.*/
                    //array = jsonData.allValues as! [String]
                    
//                    arrayOfProductJSON = jsonData.allValues as! [String]
                    
//                    print("Inside of alamofire", arrayOfProductJSON)
                    
//                    handler(arrayOfProductJSON)
                    handler(jsonData)
                    
                    
//                    print("INSide alamofire", arrayOfProductJSON)
//                    arrayOfProduct = arrayOfProductJSON
                    
                    //                    print("when?",arrayOfProduct)
                    //                        return arrayOfProduct
                    
                }
                //completion(result)
            default :
                fatalError("received non-dictionary JSON response")
            }
            
            
        }
        
        /*Alamofire.request(URL_GET_PRODUCT, method: .post, parameters: parameter).responseJSON{
            response in
            
            if let result = response.result.value {
                
                var arrayOfProductJSON : [String] = []
                
                //converting it as NSDictionary
                let jsonData = result as! NSDictionary
                //                        print("data is " ,jsonData)
                //displaying the message in label
                //                self.coffeesName.text = jsonData.value(forKey: "message") as! String?
                
                /* jsonData의 allValue를 Array<String>으로 받는다.*/
                //array = jsonData.allValues as! [String]
                arrayOfProductJSON = jsonData.allValues as! [String]
                print("INSide alamofire", arrayOfProductJSON)
                arrayOfProduct = arrayOfProductJSON
                
                //                    print("when?",arrayOfProduct)
                //                        return arrayOfProduct
                
            }
            
        }*/
        
        //dispatchGroup.wait(timeout: .distantFuture)
        
            
//        print("Outside alamofire", arrayOfProduct)
        
//        print("when?",arrayOfProduct)
//        return arrayOfProduct
        
//        print("test", arrayOfProduct)
        // as! Array<String>;
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
