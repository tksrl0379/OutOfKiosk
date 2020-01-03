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
    
    @IBOutlet weak var test_Text: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(receivedValueFromBeforeVC)
        test_Text.text = String(receivedValueFromBeforeVC!) 
       
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
