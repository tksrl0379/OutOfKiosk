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
    
    //var willgetCategroyName : String!
    var willgetCategroyName : Array<String>!
    var willgetCategroyPrice : Array<Int>!
    
    //var willgetCategroyPrice : Array<Int>!
    
    /*php통신으로 product의 이름들을 가져와서 append시켜줘야한다.*/
    /*php통신에 menu의 대분류가 coffee 인지 smoothie 인지를 알수 있는 방법이 필요하다.*/
    
    
        
    
//    var productName = ["a","b"]
    
    /*php*/
    
    @IBOutlet weak var ProductTableView: UITableView!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return willgetCategroyName.count
        //return productName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* 재사용할 수 있는 cell을 ProductTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = ProductTableView.dequeueReusableCell(withIdentifier: "ProductList", for: indexPath ) as! ProductList
        
//        print("indexPath si ", indexPath.row)
        /* ProductList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능 */
        //cell.productName_Label.text = productName[indexPath.row]
        cell.productName_Label.text = willgetCategroyName[indexPath.row]
        cell.productPrice_Label.text = String(willgetCategroyPrice[indexPath.row]) + "원"
        
        cell.cellBorder_View.layer.borderWidth = 0.5
        cell.cellBorder_View.layer.borderColor = UIColor.gray.cgColor
        
        
        
        
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
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /* backButton 커스터마이징 */
        let addButton = UIBarButtonItem(image:UIImage(named:"left"), style:.plain, target:self, action:#selector(DetailMenuController.buttonAction(_:)))
        addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로"
        
        
        
        /*
         ProdcutTableView의 delgate , datasource = self
         */
//        print(self.willgetCategroyName) //optional로 먹힘.
        
        ProductTableView.delegate = self
        ProductTableView.dataSource = self
        self.ProductTableView.rowHeight = 93.0
    }
    
}
