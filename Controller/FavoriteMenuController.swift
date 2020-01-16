//
//  FavoriteMenuController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class FavoriteMenuController : UIViewController{
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* backButton 커스터마이징 */
        let addButton = UIBarButtonItem(image:UIImage(named:"left"), style:.plain, target:self, action:#selector(FavoriteMenuController.buttonAction(_:)))
        addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
       
    }
    
    
    
}
