//
//  ShoppingListController.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/14/20.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class ShoppingListController : UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var ShoppingListTableView: UITableView!
    
    
    var testshoppingList : Array<String>!// = ["a","b","c"] //test용도
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return testshoppingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ShoppingListTableView.dequeueReusableCell(withIdentifier: "ShoppingList", for: indexPath ) as! ShoppingList
                
        cell.shoppingListMenuName_Label.text = testshoppingList[indexPath.row]
        //cell.productPrice_Label.text = String(willgetCategroyPrice[indexPath.row])
                
        return cell
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ShoppingListTableView.delegate=self
        ShoppingListTableView.dataSource=self
        self.ShoppingListTableView.rowHeight = 93.0
        
        
        
    }
    
}
