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
    
    
    //    @IBOutlet weak var ProductName_Label: UILabel!
    
    @IBOutlet weak var ShoppingBasketTableView: UITableView!
    
    
    /* 주문하기, 삭제하기 UI oultet*/
    @IBOutlet weak var orderItems_Btn: UIButton!
//    @IBOutlet weak var deleteShoppingBasketProduct_Btn: UIButton!
    
    /* 주문을 하면서 CafeDetailController의 UIBtn을 초기화 해주어야한다.*/
    var willGetShoppingBasket_Btn : UIButton!
    
    /* Table의 Cell을 위한 변수들로써, 음성주문한 메뉴들의 정보를 갖고와 저장하여 출력이 가능하다.*/
    var shoppingBasket_numOfProducts : Int = 0
    
    var shoppingBasket_productName : Array<String>! = []//["초콜렛 스무디","초콜레 프라푸치노","자바칩 프라푸치노"] //test용도
    var shoppingBasket_productSize : Array<String>! = []//["Large","Small","Medium"] //test용도
    var shoppingBasket_productCount : Array<Int>! = []//[3, 1 ,2] //test용도
    var shoppingBasket_productEachPrice : Array<Int>! = []//[3000,5000,4500]
    var shoppingBasket_productSugarContent : Array<String>! = []//[3000,5000,4500]
    var shoppingBasket_productIsWhippedCream : Array<String>! = []//[3000,5000,4500]
    
    var totlaPrice : Int = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shoppingBasket_numOfProducts
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ShoppingBasketTableView.dequeueReusableCell(withIdentifier: "ShoppingBasket", for: indexPath ) as! ShoppingBasket
        
        cell.shoppingBasketProductName_Label.text = shoppingBasket_productName[indexPath.row]+" "+shoppingBasket_productSize[indexPath.row]
        //cell.shoppingBasketProductSize_Label.text = shoppingBasket_productSize[indexPath.row]+"사이즈"
        cell.shoppingBasketNumberOfProduct_Label.text =
            String(shoppingBasket_productCount[indexPath.row])+"개"
//        let stepper = UIStepper()
        cell.shoppingBasketProductTotalPrice_Label.text =
            String( shoppingBasket_productEachPrice[indexPath.row]*shoppingBasket_productCount[indexPath.row])+"원"
        
        /* 주문하기 버튼 옆에 총액수 표현*/
        
        totlaPrice += shoppingBasket_productEachPrice[indexPath.row]*shoppingBasket_productCount[indexPath.row]
        
        orderItems_Btn.setTitle("주문하기 "+String(totlaPrice)+"원", for: .normal)
        
        /* Stepper 초기값 */
        cell.shoppingBasketProductSize_Stepper.value = Double(shoppingBasket_productCount[indexPath.row])
        
        /* delete customizing*/
        cell.deleteShoppingBasket_Btn.layer.cornerRadius = 5
        
        /* option(당도 or 휘핑크림) 보여주기
         NUll이면 hidden.
         */
        if (shoppingBasket_productSugarContent[indexPath.row] == "NULL") {
            if (shoppingBasket_productIsWhippedCream[indexPath.row] == "없이") {
                cell.ProductSugar_Label.isHidden = true                
                cell.ProductWhippedCream.text = "휘핑크림 추가 안함"
            }else if(shoppingBasket_productIsWhippedCream[indexPath.row] == "올려서"){
                cell.ProductSugar_Label.isHidden = true
                cell.ProductWhippedCream.text = "휘핑크림 추가"
            }
            
        }else if (shoppingBasket_productIsWhippedCream[indexPath.row] == "NULL"){
            cell.ProductWhippedCream.isHidden = true
            cell.ProductSugar_Label.text = "당도 : " + String(shoppingBasket_productSugarContent[indexPath.row]) + "%"
        }
        
        
        
        return cell
    }
    
    
    
    /* 해당 Cell의 Index에 맞게 수량 증감이 가능하도록 한다.*/
    @IBAction func changeNumberOfProduct_Stepper(_ sender: UIStepper) {
        
        /*Index를 찾는다.*/
        let point = sender.convert(CGPoint.zero, to: ShoppingBasketTableView)
        guard let indexPath = ShoppingBasketTableView.indexPathForRow(at: point)else{return}
        
//        print(sender.value)
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        shoppingBasket_productCount[indexPath.row] = Int(sender.value)
        ad?.menuCountArray[indexPath.row] = Int(sender.value)
        
        totlaPrice = 0 //개수가 바뀔때마다 0으로 초기화
        ShoppingBasketTableView.reloadData()
                
    }
    
    
    
    /*
     TableView의 해당 Cell을 지우는 버튼.
     버튼 클릭시 메뉴가 삭제된다.
     shoppoingBasket_xx의 remove는 현재 테이블에 보여주는 셀을 지운다
     ad?.menuXXX는 Appdelegate에 실제로 저장되어있는 데이터이므로 지운다.
     */
    @IBAction func deleteShoppingBasketProduct_Btn(_ sender : UIButton) {
        
        //print("삭제삭제")
        let point = sender.convert(CGPoint.zero, to: ShoppingBasketTableView)
        guard let indexPath = ShoppingBasketTableView.indexPathForRow(at: point)else{return}
        
        shoppingBasket_numOfProducts -= 1
        shoppingBasket_productName.remove(at: indexPath.row)
        shoppingBasket_productSize.remove(at: indexPath.row)
        shoppingBasket_productCount.remove(at: indexPath.row)
        shoppingBasket_productEachPrice.remove(at: indexPath.row)
        shoppingBasket_productSugarContent.remove(at: indexPath.row)
        shoppingBasket_productIsWhippedCream.remove(at: indexPath.row)
        
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        ad?.numOfProducts -= 1
        self.willGetShoppingBasket_Btn.setTitle("장바구니 : " + String(ad!.numOfProducts) + " 개", for: .normal)
        ad?.menuNameArray.remove(at: Int(indexPath.row))
        ad?.menuSizeArray.remove(at: Int(indexPath.row))
        ad?.menuCountArray.remove(at: Int(indexPath.row))
        ad?.menuEachPriceArray.remove(at: Int(indexPath.row))
        ad?.menuSugarContent.remove(at: Int(indexPath.row))
        ad?.menuIsWhippedCream.remove(at: Int(indexPath.row))
        
        
        ShoppingBasketTableView.deleteRows(at: [indexPath], with: .fade)
        
    }
    
    
    @IBAction func orderItems_Btn(_ sender: Any) {
        
        /* AppDelegate에 저장된 모든 정보를 Dynamic하게 보내야하므로
         저장된 장바구니의 아이템 개수만큼 for loop를 돌려서 php통신을 이용하여 DB로 보낸다.
         보내는 아이템은 동시에 보내야 하므로 같은 date를 보낸다.
         */
        let now = Date()
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = date.string(from: now)
//        print(currentDate, type(of: currentDate))
        
            
        
        for i in 0...shoppingBasket_numOfProducts-1 {
            /*if let userId = UserDefaults.standard.string(forKey: "id"){
                
                    print("My ID : ", userId , "type : ", type(of: userId))
            }*/
            
            let userId = UserDefaults.standard.string(forKey: "id")!
            
            print("userID type is : ", type(of: userId))
            let parameters: Parameters=[
                "name" : shoppingBasket_productName[i]+" "+shoppingBasket_productSize[i],
                "count": shoppingBasket_productCount[i],
                "sugar": shoppingBasket_productSugarContent[i],
                "whippedcream": shoppingBasket_productIsWhippedCream[i],
                "currentDate" : currentDate,
                "userID" : userId//UserDefaults.standard.string(forKey: "id")
                //user Id또한 넣어주어야한다.
                //order ID는 DB에서 auto_increament 한다.
            ]
            
            /* php 서버 위치 */
            let URL_ORDER = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/order/api/order.php"
            //Sending http post request
            Alamofire.request(URL_ORDER, method: .post, parameters: parameters).responseString
                {
                    response in
                    print("응답",response)
                    
            }
        }
        
        
        
        
        self.navigationController?.popViewController(animated: true)
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        ad?.numOfProducts = 0
        /* 주문이 완료되면 현재 장바구니의 아이템을 삭제해야하므로 appdelegate의 모든 아이템을 초기화한다.*/
        self.willGetShoppingBasket_Btn.setTitle("장바구니 : " + String(ad!.numOfProducts) + " 개", for: .normal)
        
        ad?.menuNameArray = []
        ad?.menuSizeArray = []
        ad?.menuCountArray = []
        ad?.menuEachPriceArray = []
        ad?.menuSugarContent = []
        ad?.menuIsWhippedCream = []
        
    }
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /* UI : 버튼의 각을 줄인다*/
        orderItems_Btn.layer.cornerRadius = 5
//        deleteShoppingBasketProduct_Btn
//        deleteShoppingBasketProduct_Btn.layer.cornerRadius = 5
        
        
        ShoppingBasketTableView.delegate=self
        ShoppingBasketTableView.dataSource=self
        self.ShoppingBasketTableView.rowHeight = 200.0
        
        /* backButton 커스터마이징 */
        let addButton = UIBarButtonItem(image:UIImage(named:"left"), style:.plain, target:self, action:#selector(ShoppingBasketController.buttonAction(_:)))
        addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로"
        
        
        
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
