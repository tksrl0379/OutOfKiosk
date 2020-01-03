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
       
        //DialogueFlow 팝업창 띄우기
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DialogueFlowPopUpController") as! DialogueFlowPopUpController

        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
        //vc.view.backgroundColor = UIColor.clear


        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
