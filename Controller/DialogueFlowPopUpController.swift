//
//  DialogueFlowPopUpController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/03.
//  Copyright © 2020 OOK. All rights reserved.
//

//Start
import UIKit

class DialogueFlowPopUpController: UIViewController{
    
    override func viewDidLoad() {
           super.viewDidLoad()
    }
    
    @IBAction func close_Btn(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        
    }
}
