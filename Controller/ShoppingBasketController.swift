//
//  ShoppingListController.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/14/20.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

/*
 장바구니 뷰
 메뉴이름과 수량, 그리고 각 메뉴에 대한 가격정보가 적혀있다.
 
 필요기능 ->
 1. 각 테이블에 대한 아이템에 대하여 개수는 수정가능하고
 2. 아이템 자체를 삭제할 수 있도록 한다.
 3. 마지막에는 총 메뉴에 대한 가격을 알려주는 것이 좋다.

 프로세스
 
 1.임의로 메뉴이름, 수량, 가격을 라벨에 적어둔다. (Dictionary로 해야할지, 혹은 Array로 해야할지)
 
 1-1) 챗봇을 통해 메뉴가 생길때마다 append를 한다?
 rvc.blarblar = ddd
 Dictionary가 별 의미가 없는것이 한 아이템을 주문할때 순차적으로 모든값이 들어오고 rvc에 적재되므로 배열이 좋지 않을까 싶다.
 
 
 2.수량은 버튼등을 이용해 올리기?내리기?
 3.삭제버튼생성
 
 */
class ShoppingBasketController : UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var ShoppingBasketTableView: UITableView!
    
    //var testDic : Dictionary! =
    
    var shoppingBasket_name : Array<String>! = ["초콜렛 스무디","초콜레 프라푸치노","자바칩 프라푸치노"] //test용도
    
    var shoppingBasket_size : Array<String>! = ["Large","Small","Medium"] //test용도
    var shoppingBasket_count : Array<Int>! = [3, 1 ,2] //test용도

    var shoppingBasket_eachPrice : Array<Int>! = [3000,5000,4500]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shoppingBasket_name.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ShoppingBasketTableView.dequeueReusableCell(withIdentifier: "ShoppingBasket", for: indexPath ) as! ShoppingBasket
                
        cell.shoppingBasketProductName_Label.text = shoppingBasket_name[indexPath.row]
        cell.shoppingBasketProductSize_Label.text = shoppingBasket_size[indexPath.row]
        cell.shoppingBasketNumberOfProduct_Label.text =
            String(shoppingBasket_count[indexPath.row])
        cell.shoppingBasketProductTotalPrice_Label.text =
            String( shoppingBasket_eachPrice[indexPath.row]*shoppingBasket_count[indexPath.row])
        
        //cell.shoppingListMenuName_Label.text = testshoppingList[indexPath.row]
        //cell.shoppingListMenuName_Label.text = testshoppingList[indexPath.row]
        //cell.productPrice_Label.text = String(willgetCategroyPrice[indexPath.row])
                
        return cell
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ShoppingBasketTableView.delegate=self
        ShoppingBasketTableView.dataSource=self
        self.ShoppingBasketTableView.rowHeight = 150.0
        
        
        
    }
    
}
