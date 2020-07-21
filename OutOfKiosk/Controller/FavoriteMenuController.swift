//
//  FavoriteMenuController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class FavoriteMenuController : UIViewController, UITableViewDelegate , UITableViewDataSource{
    
    // MARK: - Propery
    
    // MARK: 찜한 메뉴의 이름 / 가게이름
    var favoriteMenuNameArray: Array<String> = []
    var favoriteStoreKorNameArray: Array<String> = []
    
    // MARK: View
    @IBOutlet weak var shoppingBasket_Btn: UIButton!
    @IBOutlet weak var favoriteMenuTableView: UITableView!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteMenuTableView.delegate=self
        favoriteMenuTableView.dataSource=self
        self.favoriteMenuTableView.rowHeight = 100.0
        
        self.initializeNavigationItem()
        self.initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 장바구니 개수 표시
        let ad = UIApplication.shared.delegate as? AppDelegate
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
    }
    
    
    // MARK: - Method
    // MARK: Table Method
    
    // Cell 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favoriteMenuNameArray.count
    }
    
    // Cell 편집
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 재사용할 수 있는 cell을 FavoriteMenuTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅
        let cell = favoriteMenuTableView.dequeueReusableCell(withIdentifier: "FavoriteList", for: indexPath ) as! FavoriteList
        
        cell.favoriteMenuName_Label.text = favoriteMenuNameArray[indexPath.row]
        cell.orderFavoriteMenu_Btn.layer.cornerRadius = 5
        cell.deleteFavoriteMenu_Btn.layer.cornerRadius = 5
        
        return cell
    }
    
    
    // MARK: Custom Method
    
    func initializeNavigationItem() {
        
        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "메인으로 뒤로가기"
        self.navigationItem.title = "찜한 메뉴"
        self.navigationItem.accessibilityLabel = "찜한 메뉴 목록"
    }
    
    func initializeUI() {
        
        // 장바구니 버튼 둥글게
        shoppingBasket_Btn.layer.cornerRadius = 5
        
        // TableView 최초 갱신
        let favoriteMenuInfoDict = UserDefaults.standard.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        
        self.favoriteMenuNameArray = Array(favoriteMenuInfoDict!.keys)
        self.favoriteStoreKorNameArray = Array(favoriteMenuInfoDict!.values)
        
        DispatchQueue.main.async {
            self.favoriteMenuTableView.reloadData()
        }
    }
    
    func alertMessage(_ title: String, _ description: String) {
        
        DispatchQueue.main.async{
            
            let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
            
            let defaultAction = UIAlertAction(title: "확인", style: .destructive) { (action) in }
            alert.addAction(defaultAction)
            
            // Alert Message 띄우기
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: IBAction
    
    // 음성주문 버튼 : 즐겨찾기한 메뉴 바로 음성주문 할 수 있음
    @IBAction func orderFavoriteProduct_Btn(_ sender: UIButton) {
        
        // 선택한 Cell을 알기 위해 indexPath 구함
        let point = sender.convert(CGPoint.zero, to: favoriteMenuTableView)
        guard let indexPath = favoriteMenuTableView.indexPathForRow(at: point)else{return}
        
        // 음성주문(DialogflowPopUpController)로 넘어감
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as? DialogFlowPopUpController else { return }
        
        // 선택한 메뉴의 이름 및 한글 이름을 DialogFlow 에 전송
        rvc.favoriteMenuName = favoriteMenuNameArray[indexPath.row]
        rvc.storeKorName = favoriteStoreKorNameArray[indexPath.row]
        
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    
    // 메뉴삭제 버튼: 즐겨찾기한 메뉴를 삭제할 수 있음
    @IBAction func deleteFavoriteProduct_Btn(_ sender: UIButton) {
        
        // 선택한 Cell을 알기 위해 indexPath 를 구함
        let point = sender.convert(CGPoint.zero, to: favoriteMenuTableView)
        guard let indexPath = favoriteMenuTableView.indexPathForRow(at: point) else { return }
        
        let defaults = UserDefaults.standard
        var favoriteMenuInfoDict = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        
        // 삭제 내용 반영하여 즐겨찾기 관련된 자료구조 갱신: 1. UserDefault의 즐겨찾기(favoriteMenuInfoDict), 2. 테이블 뷰의 메뉴이름 출력하는 배열(favoriteMenuNameArray)
        favoriteMenuInfoDict?.removeValue(forKey: favoriteMenuNameArray[indexPath.row])
        UserDefaults.standard.set(favoriteMenuInfoDict, forKey: "favoriteMenuInfoDict")
        favoriteMenuNameArray.remove(at: indexPath.row)
        
        // UI적으로 TableViewCell을 삭제하기 위한 작업
        favoriteMenuTableView.deleteRows(at: [indexPath], with: .fade)
        
        // 즐겨찾기에 담겨진 메뉴 개수가 0개면 popView
        if favoriteMenuNameArray.count == 0 {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // 장바구니 기능
    @IBAction func shoppingList_Btn(_ sender: Any) {
        
        // 장바구니가 비어있지 않은 경우 화면이 전환. 비어있을 시 경고 메시지 뜸
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        if let count = ad?.numOfProducts{
            if count != 0 {
                guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingBasketController") as? ShoppingBasketController else { return }
                
                rvc.prevViewName = "찜한 메뉴"
                self.navigationController?.pushViewController(rvc, animated: true)
            }else{
                self.alertMessage(" ","장바구니가 비어있어요")
            }
            
        }
    }
    
    
    
    
    
    
    
}
