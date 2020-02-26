//
//  FavoriteMenuController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

/* PHP통신으로 Data를 받는다. 각 유저마다 원하는 정보의 Data를 받을것이다.*/
import UIKit

class FavoriteMenuController : UIViewController, UITableViewDelegate , UITableViewDataSource{
    
    /* 각 유저가 즐겨찾기한 메뉴의 이름, 가게이름 적재 */
    var favoriteMenuNameArray = [""]
    var favoriteStoreKorNameArray = [""]
    
    /* 장바구니 버튼 */
    @IBOutlet weak var shoppingBasket_Btn: UIButton!
    
    /* 테이블 뷰 */
    @IBOutlet weak var favoriteMenuTableView: UITableView!
    
    
    /* 음성주문 버튼 : 즐겨찾기한 메뉴 바로 음성주문 할 수 있음 */
    @IBAction func orderFavoriteProduct_Btn(_ sender: UIButton) {
        
        /* 선택한 Cell을 알기 위해 indexPath 를 구한다.*/
        let point = sender.convert(CGPoint.zero, to: favoriteMenuTableView)
        guard let indexPath = favoriteMenuTableView.indexPathForRow(at: point)else{return}
        
        /* 음성주문(DialogflowPopUpController)로 넘어감 */
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as? DialogFlowPopUpController else {
            return}
        
        // 선택한 메뉴의 이름 및 한글 이름을 DialogFlow에 전송한다.
        rvc.favoriteMenuName = favoriteMenuNameArray[indexPath.row]
        rvc.storeKorName = favoriteStoreKorNameArray[indexPath.row]
        
        print("즐겨찾기에서 가게이름 : ", favoriteStoreKorNameArray[indexPath.row])
        
        
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    
    /* 메뉴삭제 버튼: 즐겨찾기한 메뉴를 삭제할 수 있음 */
    @IBAction func deleteFavoriteProduct_Btn(_ sender: UIButton) {
        
        /* 선택한 Cell을 알기 위해 indexPath 를 구한다.*/
        let point = sender.convert(CGPoint.zero, to: favoriteMenuTableView)
        guard let indexPath = favoriteMenuTableView.indexPathForRow(at: point)else{return}
        
        
        let defaults = UserDefaults.standard
        var favoriteMenuInfoDict = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        
        /* 삭제 내용 반영하여 즐겨찾기 관련된 자료구조들 업데이트: 1. UserDefault의 즐겨찾기(favoriteMenuInfoDict), 2. 테이블 뷰의 메뉴이름 출력하는 배열(favoriteMenuNameArray) */
        favoriteMenuInfoDict?.removeValue(forKey: favoriteMenuNameArray[indexPath.row])
        UserDefaults.standard.set(favoriteMenuInfoDict, forKey: "favoriteMenuInfoDict")
        favoriteMenuNameArray.remove(at: indexPath.row)
        
        /* UI적으로 TableViewCell을 삭제하기 위한 작업*/
        favoriteMenuTableView.deleteRows(at: [indexPath], with: .fade)
        
        /* 즐겨찾기에 담겨진 메뉴 개수가 0개면 popView 되기 */
        if favoriteMenuNameArray.count == 0 {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    /* 장바구니 기능 */
    @IBAction func shoppingList_Btn(_ sender: Any) {
        
        /* 장바구니가 비어있지 않은 경우 화면이 전환. 비어있을 시 경고 메시지 뜸 */
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        if let count = ad?.numOfProducts{
            if count != 0 {
                guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingBasketController") as? ShoppingBasketController else {
                    return}
                
                self.navigationController?.pushViewController(rvc, animated: true)
            }else{
                /* 들어갈 기능 = message alert 혹은 팝업 cotroller를 뛰운다*/
                self.alertMessage(" ","장바구니가 비어있어요")
            }
            
        }
    }
    
    
    /* Cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favoriteMenuNameArray.count
    }
    
    /* Cell 편집 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        /* 재사용할 수 있는 cell을 FavoriteMenuTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = favoriteMenuTableView.dequeueReusableCell(withIdentifier: "FavoriteList", for: indexPath ) as! FavoriteList
        
        /* StoreList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능 */
        cell.favoriteMenuName_Label.text = favoriteMenuNameArray[indexPath.row]
        cell.orderFavoriteMenu_Btn.layer.cornerRadius = 5
        cell.deleteFavoriteMenu_Btn.layer.cornerRadius = 5
        
        return cell
    }
    
    
    
    
    
    /* 장바구니가 비어있을 시 경고 메시지 함수*/
    func alertMessage(_ title: String, _ description: String){
        
        /* Alert는 MainThread에서 실행해야 함 */
        DispatchQueue.main.async{
            
            /* Alert message 설정 */
            let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
            
            /* 버튼 설정 및 추가*/
            let defaultAction = UIAlertAction(title: "확인", style: .destructive) { (action) in
            }
            alert.addAction(defaultAction)
            
            
            /* Alert Message 띄우기 */
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    
    /* 버튼 관련 메소드 */
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /* Delegate: 위임자. 위임하지 않으면 절대로 표출되지 않는다.
         dataSource = DataSource는 데이터를 받아 뷰를 그려주는 역할
         delegate =  어떤 행동에 대한 "동작"을 제시
         출처: https://zeddios.tistory.com/137 [ZeddiOS]
         */
        
        favoriteMenuTableView.delegate=self
        favoriteMenuTableView.dataSource=self
        self.favoriteMenuTableView.rowHeight = 100.0
        
        /* backButton 커스터마이징 */
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        backBtn.setImage(UIImage(named:"left_image"), for: .normal)
        backBtn.addTarget(self, action: #selector(FavoriteMenuController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* 내비게이션바 이름 및 접근성 설정 */
        self.navigationController?.navigationBar.topItem?.title = "즐겨찾기"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "NanumSquare", size: 20)!]
        self.navigationController?.navigationBar.topItem?.accessibilityLabel = "즐겨찾기 메뉴입니다"
        
        
        /* TableView 최초에 갱신해주는 역할 */
        let defaults = UserDefaults.standard
        var favoriteMenuInfoDict = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        
        self.favoriteMenuNameArray = Array(favoriteMenuInfoDict!.keys)
        self.favoriteStoreKorNameArray = Array(favoriteMenuInfoDict!.values)
        
        DispatchQueue.main.async {
            self.favoriteMenuTableView.reloadData()
        }
        
        
        /* 장바구니 개수 표시 */
        let ad = UIApplication.shared.delegate as? AppDelegate
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /* 장바구니 개수 표시 */
        let ad = UIApplication.shared.delegate as? AppDelegate
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
        
    }
    
}
