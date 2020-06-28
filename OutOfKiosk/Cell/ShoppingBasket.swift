//
//  ShoppingBasket.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/14/20.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit
/* TableView의 Cell관련 Oultet은 모두 여기서 선언 후에 관련된 개채를 설정한다.*/
class ShoppingBasket : UITableViewCell{
    
    
    @IBOutlet weak var BasketItemInfo_Label: UILabel!
    
    
    @IBOutlet weak var shoppingBasketProductSize_Stepper: UIStepper!    
        
    @IBOutlet weak var deleteShoppingBasket_Btn: UIButton!

}
