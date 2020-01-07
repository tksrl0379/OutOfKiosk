//
//  MenuOfCoffee.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/6/20.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit


/*
 TableViewDataSources의 오버라이딩 함수들. numberOfRowsInSection , cellForRowAt indexPath
 */
class DetailMenuController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //var receivedValueFromBeforeVC : Int?
    
    var willgetCategroyName : String!
    
    /*php통신으로 product의 이름들을 가져와서 append시켜줘야한다.*/
    /*php통신에 menu의 대분류가 coffee 인지 smoothie 인지를 알수 있는 방법이 필요하다.*/
    
    let URL_ORDER = "http://ec2-54-180-119-142.ap-northeast-2.compute.amazonaws.com/order/api/order.php"
    var productName = ["a","b"]
    
    /* */
    
    @IBOutlet weak var ProductTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* 재사용할 수 있는 cell을 ProductTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = ProductTableView.dequeueReusableCell(withIdentifier: "ProductList", for: indexPath ) as! ProductList
        
        /* ProductList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능 */
        cell.productName_Label.text = productName[indexPath.row]
        
        
        return cell
    }
    
    /*
    /* 특정 Cell 클릭 이벤트 처리 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        /* view controller 간 데이터 교환
        : instantiateViewController를 통해 생성된 객체는 UIViewController타입이기 때문에 StoreDetailController 타입으로 다운캐스팅. */
        let vc = self.storyboard?.instantiateViewController(identifier: "DetailMenuController") as! DetailMenuController
        vc.receivedValueFromBeforeVC = indexPath.row
        //print(indexPath.row)
        
        /* StoreDetailController 로 화면 전환 */
        //self.present(vc, animated: true, completion: nil) // present 방식
        self.navigationController?.pushViewController(vc, animated: true) // navigation controller 방식
        
        
    }*/
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*
         ProdcutTableView의 delgate , datasource = self
         */
        print(self.willgetCategroyName)
        
        ProductTableView.delegate = self
        ProductTableView.dataSource = self
        
    }
    
}
