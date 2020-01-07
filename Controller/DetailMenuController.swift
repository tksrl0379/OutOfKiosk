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
    
    
    
    //php통신으로 product의 이름들을 가져와서 append시켜줘야한다.
    var productName = ["a","b"]
    
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
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*
         ProdcutTableView의 delgate , datasource = self
         */
        ProductTableView.delegate = self
        ProductTableView.dataSource = self
        
    }
    
}
