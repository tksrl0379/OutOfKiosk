//
//  StoreDetailController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//


import UIKit

class StoreDetailController : UIViewController{
    
    var receivedValueFromBeforeVC : Int?
    
    @IBOutlet weak var test_Text: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(receivedValueFromBeforeVC)
        test_Text.text = String(receivedValueFromBeforeVC!) 
       
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
