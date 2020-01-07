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

/* 다이어로그 플로우 넣는 곳 */
class CafeDetailController : UIViewController{
    
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
        
        rvc.willgetCategroyName = "coffee"
        
        self.navigationController?.pushViewController(rvc, animated: true)
        
        //"coffee"란 문자열을 전송시켜야한다.
        /*if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }*/
        
    }
    
    
    @IBAction func smoothie_Btn(_ sender: Any) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    /*
     TabView 를 이용하여, 선택한 메뉴가 모두 뜨게끔 할 수도 있다.
     */
    
    
    
    
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
