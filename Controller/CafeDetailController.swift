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
    
//    @IBOutlet weak var test_Text: UILabel!
    
 
    /*coffee_btn누를시 커피에 관련된 메뉴가 나와야한다.
    mysql php 통신이 필요함.
     이곳에선 dictionary로 키,밸류 {0:coffee, 1:smoothie }처럼 만들고
     DetailMenuController에 키를 전달한다.
     DetailMenuController에서는 밸류값을 php통신으로 mysql에 있는
     값을 관련 데이터값들을 불러온다.
    */
    @IBAction func coffee_Btn(_ sender: Any) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    
    @IBAction func smoothie_Btn(_ sender: Any) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController"){
            self.navigationController?.pushViewController(controller, animated: true)
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
