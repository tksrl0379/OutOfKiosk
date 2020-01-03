//
//  StoreDetailController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

//Dialogflow
//testtest jinseo

//fhgfhfhf
import UIKit

/* 다이어로그 플로우 넣는 곳 */
class CafeDetailController : UIViewController{
    
    var receivedValueFromBeforeVC : Int?
    
    @IBOutlet weak var test_Text: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(receivedValueFromBeforeVC)
        test_Text.text = String(receivedValueFromBeforeVC!) 
       
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
