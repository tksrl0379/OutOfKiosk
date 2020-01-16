//
//  MainController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class MainController : UIViewController{
    
    @IBOutlet weak var title_View: UIView!
    
    
    @IBOutlet weak var cafe_Btn: UIButton!
    @IBOutlet weak var chicken_Btn: UIButton!
    @IBOutlet weak var koreaFood_Btn: UIButton!
    @IBOutlet weak var pizza_Btn: UIButton!
    
    @IBOutlet weak var favorite_Btn: UIButton!
    
    func addShadow(btn : UIButton){
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 5, height: 5)
        btn.layer.shadowRadius = 0.5
        
        btn.layer.cornerRadius = 1
    }
    
    
    @IBOutlet weak var sub_View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        navigationItem.hidesBackButton = true // hide button
        //        self.tabBarController?.tabBar.isHidden = false
        //        self.tabBarController?.viewControllers?.remove(at: 0)
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        
        title_View.layer.shadowColor = UIColor.black.cgColor
        title_View.layer.shadowOpacity = 0.3
        title_View.layer.shadowOffset = .zero
        title_View.layer.shadowRadius = 4
        title_View.layer.cornerRadius = 5
        
        sub_View.layer.shadowColor = UIColor.black.cgColor
        sub_View.layer.shadowOpacity = 0.3
        sub_View.layer.shadowOffset = .zero
        sub_View.layer.shadowRadius = 4
        sub_View.layer.cornerRadius = 5
        
        cafe_Btn.layer.cornerRadius = 5
        pizza_Btn.layer.cornerRadius = 5
        koreaFood_Btn.layer.cornerRadius = 5
        chicken_Btn.layer.cornerRadius = 5
        favorite_Btn.layer.cornerRadius = 5
        
        
        
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
