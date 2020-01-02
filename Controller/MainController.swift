//
//  MainController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class MainController : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        //        navigationItem.hidesBackButton = true // hide button
        //        self.tabBarController?.tabBar.isHidden = false
        //        self.tabBarController?.viewControllers?.remove(at: 0)
        
    }
    
    /* 카페 버튼 */
    @IBAction func cafe_Btn(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "StoreListController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    /* 즐겨찾기 버튼 */
    @IBAction func favoriteMenu_Btn(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteMenuController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
