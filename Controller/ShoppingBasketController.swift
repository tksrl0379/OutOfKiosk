//
//  ShoppingListController.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/14/20.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit
import Alamofire

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
    
    var shoppingBasket_numOfProducts : Int = 0
    
    var shoppingBasket_productName : Array<String>! = []//["초콜렛 스무디","초콜레 프라푸치노","자바칩 프라푸치노"] //test용도
    var shoppingBasket_productSize : Array<String>! = []//["Large","Small","Medium"] //test용도
    var shoppingBasket_productCount : Array<Int>! = []//[3, 1 ,2] //test용도
    var shoppingBasket_productEachPrice : Array<Int>! = []//[3000,5000,4500]
    var shoppingBasket_productSugarContent : Array<String>! = []//[3000,5000,4500]
    var shoppingBasket_productIsWhippedCream : Array<String>! = []//[3000,5000,4500]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shoppingBasket_numOfProducts
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ShoppingBasketTableView.dequeueReusableCell(withIdentifier: "ShoppingBasket", for: indexPath ) as! ShoppingBasket
        
        cell.shoppingBasketProductName_Label.text = shoppingBasket_productName[indexPath.row]
        cell.shoppingBasketProductSize_Label.text = shoppingBasket_productSize[indexPath.row]+"사이즈"
        cell.shoppingBasketNumberOfProduct_Label.text =
            String(shoppingBasket_productCount[indexPath.row])+"개"
        cell.shoppingBasketProductTotalPrice_Label.text =
            String( shoppingBasket_productEachPrice[indexPath.row]*shoppingBasket_productCount[indexPath.row])+"원"
        
        return cell
    }
    
    
    @IBAction func orderItems_Btn(_ sender: Any) {
        
        /* 주문 정보 전송 */
        /* php - mysql 서버로 주문 정보 전송 후 receivedMsg_Label에 Dialogflow message 출력 및 TTS*/
        /*
        self.speechAndText(textResponse)
        
        
        /* 아래의 parameter 넣는 곳이 강제 unwrapping인 !이기 때문에 nil이 들어가면 안됨. 따라서 문자열 값 넣어줌 */
        if self.sugar == nil {
            self.sugar = "NULL"
        }
        
        if self.whippedcream == nil {
            self.whippedcream = "NULL"
        }
        */
        //creating parameters for the post request
        /*
        let parameters: Parameters=[
            "name": self.name! ,
            "count": self.count!,
            "size": self.size!,
            "sugar": self.sugar!,
            "whippedcream": self.whippedcream!
        ]
        
        /* php 서버 위치 */
        let URL_ORDER = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/order/api/order.php"
        //Sending http post request
        Alamofire.request(URL_ORDER, method: .post, parameters: parameters).responseString
            {
                response in
                
                print("응답",response)
                
                /* 재주문하는 경우를 대비하여 nil로 초기화 해줘야 함. 아니면 query가 여러번 날라감 */
                self.name = nil
                self.count = nil
                self.size = nil
                self.sugar = nil
                self.whippedcream = nil
                
                
        }
    }*/
    
    
    
}





override func viewDidLoad() {
    
    super.viewDidLoad()
    
    ShoppingBasketTableView.delegate=self
    ShoppingBasketTableView.dataSource=self
    self.ShoppingBasketTableView.rowHeight = 150.0
    
    /*
     Appdelegate를 사용하여, 챗봇을 통해 주문한 정보를 AppDelegate에서 불러오는 작업. 이후 각 Array에 넣어준다.
     */
    let ad = UIApplication.shared.delegate as? AppDelegate
    
    if let numOfProducts = ad?.numOfProducts{
        shoppingBasket_numOfProducts = numOfProducts
    }
    
    if let menuNameArray = ad?.menuNameArray {
        
        shoppingBasket_productName = menuNameArray
        
    }
    if let menuSizeArray = ad?.menuSizeArray {
        
        shoppingBasket_productSize = menuSizeArray
        
    }
    if let menuCountArray = ad?.menuCountArray {
        
        shoppingBasket_productCount = menuCountArray
        
    }
    if let menuEachPriceArray = ad?.menuEachPriceArray {
        
        shoppingBasket_productEachPrice = menuEachPriceArray
    }
    if let menuSugarContent = ad?.menuSugarContent {
        
        shoppingBasket_productSugarContent = menuSugarContent
    }
    if let menuIsWhippedCream = ad?.menuIsWhippedCream {
        
        shoppingBasket_productIsWhippedCream = menuIsWhippedCream
    }
    
    
}

}
