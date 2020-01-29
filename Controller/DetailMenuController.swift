//
//  MenuOfCoffee.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/6/20.
//  Copyright © 2020 OOK. All rights reserved.
//

/* 이곳에서 사용자가 favorite 설정한 메뉴는 PHP통신으로 데이터를 전송하여 DB에 쏘아서 후에
    FavoriteMenuController에서 받을 수 있다.
 */
import UIKit
import Alamofire


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
        cell.addFavoriteItem_Btn.layer.cornerRadius = 5
        //cell.cell_view.accessibilityTraits = UIAccessibilityTraits.none
        
//        cell.cellBorder_View.layer.borderWidth = 0.5
//        cell.cellBorder_View.layer.borderColor = UIColor.gray.cgColor
//
        
        
        
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
    
    /*
     아이템을 즐겨찾기 창에 추가시키는 버튼
     php통신이 요구됨,DB Table 만들어야함.(user_ID,menu)전송)
     */
    @IBAction func addFavoriteItem_Btn(_ sender: UIButton) {
        
        /* 현재 cell의 위치를 알기 위해서 사용한다.*/
        let point = sender.convert(CGPoint.zero, to: ProductTableView)
        guard let indexPath = ProductTableView.indexPathForRow(at: point)else{return}
        
        
//        ProductTableView.reloadData()
//        self.addFavoriteItem_Btn[indexPath.row].set
                
        let userId = UserDefaults.standard.string(forKey: "id")!
        
//        print(willgetCategroyName[indexPath.row] , " and ", userId)
        
        let parameters: Parameters = [
            "name" : willgetCategroyName[indexPath.row],
            "userID" : userId
        ]
        /* php 서버에 해당하는 아이템을 즐겨찾기로 추가한다.
         하지만 이미 즐겨찾기에 저장된 아이템이 있을시 즐겨찾기가 추가되는것이아니라 해제가 되어야한다.
         플래그를 이용하여 일단 즐겨찾기가 된 상황에서는 버튼을 누르면 다시 해제가 되게 하기.
         
         1. 해당 id에 등록된 즐겨찾기 아이템을 모두 검색하고 있으면 '즐겨찾기추가'를 '즐겨찾기해제'로 변경하게 한다.
         2. 즐겨찾기추가를 누를 시 추가가 되고 동시에 즐겨찾기 해제로 변경하게 함.
         3. 즐겨찾기해제를 누를 시 삭제가 되고 동시에 즐겨찾기 추가로 변경하게 함.
         
         위 방법은 현재 안하기로함. 메뉴정보도 받아야하고, 사용자별 즐겨찾기 한 메뉴도 받아와서 비교하여 버튼을 즐겨찾기 추가/해제를 알려주어야 하므로
         더욱 복잡하고 효율적으로 보이지도 않다.
         
         *지금은 추가하는대로 추가하되 즐겨찾기에서는 보여줄 때 distinct 쿼리문으로 보여주며, 삭제 시 중복 추가된 모든 메뉴를 한번에 삭제 해버리게 함.
         */
        let URL_ORDER = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/favoriteMenu/api/addFavoriteMenu.php"
        //Sending http post request
        Alamofire.request(URL_ORDER, method: .post, parameters: parameters).responseString
        {
                response in
                print("응답",response)
        }
        
    }
    
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /* backButton 커스터마이징 */
        let addButton = UIBarButtonItem(image:UIImage(named:"left"), style:.plain, target:self, action:#selector(DetailMenuController.buttonAction(_:)))
        addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        
        
        ProductTableView.delegate = self
        ProductTableView.dataSource = self
        self.ProductTableView.rowHeight = 93.0
        
        
        
        
        
        
    }
    
}
