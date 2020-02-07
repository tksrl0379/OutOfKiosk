//
//  FavoriteMenuController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

/* PHP통신으로 Data를 받는다. 각 유저마다 원하는 정보의 Data를 받을것이다.*/
import Alamofire
import UIKit

class FavoriteMenuController : UIViewController, UITableViewDelegate , UITableViewDataSource{
    
    
    //    var willgetFavoriteMenuName = Array<String>!
    
    //각 유저가 즐겨찾기한 목록의 item을 Array들을 여기에 넣을 것이다.
    var willgetFavoriteMenuName = [""]
    
    
    @IBOutlet weak var shoppingBasket_Btn: UIButton!
    
    
    @IBOutlet weak var FavoriteMenuTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return willgetFavoriteMenuName.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        /* 재사용할 수 있는 cell을 FavoriteMenuTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = FavoriteMenuTableView.dequeueReusableCell(withIdentifier: "FavoriteList", for: indexPath ) as! FavoriteList
        
        /* StoreList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능 */
        cell.favoriteProductName_Label.text = willgetFavoriteMenuName[indexPath.row]
        cell.orderFavoriteProduct_Btn.layer.cornerRadius = 5
        cell.deleteFavoriteProduct_Btn.layer.cornerRadius = 5
        
        return cell
        
    }
        
    /* 즐겨찾기 추가한 아이템을 주문(챗봇음성안내)로 바로가게 하기.*/
    @IBAction func orderFavoriteProduct_Btn(_ sender: UIButton) {
        
        /* 해당 Cell의 이름을 얻기위해 indexPath를 구한다.*/
        let point = sender.convert(CGPoint.zero, to: FavoriteMenuTableView)
        guard let indexPath = FavoriteMenuTableView.indexPathForRow(at: point)else{return}
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as? DialogFlowPopUpController else {
            return}
        
        /* Cell의 이름을 DialogFlow에 전송한다. */
        rvc.favoriteMenuName = willgetFavoriteMenuName[indexPath.row]
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    
    
    @IBAction func deleteFavoriteProduct_Btn(_ sender: UIButton) {
        
        let point = sender.convert(CGPoint.zero, to: FavoriteMenuTableView)
        
        guard let indexPath = FavoriteMenuTableView.indexPathForRow(at: point)else{return}
        
        
        /*
            //PHP 통신으로 favoriteItem 삭제하기.
            //userID와 Name을 전송해야함.
        let userId = UserDefaults.standard.string(forKey: "id")!
        /* 해당 테이블 뷰의 이름을 얻기위해 indexPath.row를 사용함.*/
        let parameters: Parameters=[
            "name" : willgetFavoriteMenuName[indexPath.row],
            "userID" : userId
        ]
        /* php 서버 위치 */
        let URL_DELETE_FAVORITE = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/favoriteMenu/api/deleteFavoriteMenu.php"
        //Sending http post request
        Alamofire.request(URL_DELETE_FAVORITE, method: .post, parameters: parameters).responseString
            {
                response in
                print("응답",response)
        }
         */
        
        
        /* UserDefault에 저장된 즐겨찾기메뉴를 삭제한다.
            favoriteMenuArray로 UserDefault에 저장된 "favoriteMenuArray"키를 unwrap 한다.
         */
        let defaults = UserDefaults.standard
        var favoriteMenuArray = defaults.stringArray(forKey: "favoriteMenuArray") ?? [String]()
                
        
        /* 즐겨찾기 메뉴 배열에서 값에 대한 인덱스 값을 찾아 그 인덱스를 지우는 작업*/
        favoriteMenuArray.remove(at: favoriteMenuArray.firstIndex(of: willgetFavoriteMenuName[indexPath.row])!)
        
        UserDefaults.standard.set(favoriteMenuArray, forKey: "favoriteMenuArray")
        
        /* willgetFavoriteMenuName = 현재 즐겨찾기목록에 있는 메뉴들의 이름 배열.*/
        /* UI적으로 TableViewCell을 삭제하기 위한 작업*/
        willgetFavoriteMenuName.remove(at: indexPath.row)
        FavoriteMenuTableView.deleteRows(at: [indexPath], with: .fade)
        
        /* 즐겨찾기에 담겨진 메뉴 개수가 0개면 popView 되기.*/
        if willgetFavoriteMenuName.count == 0 {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    /* 장바구니 기능 */
    @IBAction func shoppingList_Btn(_ sender: Any) {
        
        /* 주문한 정보가 몇개인지를 알아서 0개일시 주문을 먼저 하라는 메시지를 보내기 위한 기능*/
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
    
    
    

    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /* Delegate 위임하지 않으면 절대로 표출되지 않는다.
         dataSource = DataSource는 데이터를 받아 뷰를 그려주는 역할
         delegate =  어떤 행동에 대한 "동작"을 제시
         출처: https://zeddios.tistory.com/137 [ZeddiOS]
         */
        
        FavoriteMenuTableView.delegate=self
        FavoriteMenuTableView.dataSource=self
        self.FavoriteMenuTableView.rowHeight = 100.0
        
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
        
        
        
        //addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80.0)
        
        self.navigationController?.navigationBar.topItem?.title = "즐겨찾기"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "NanumSquare", size: 20)!]
        self.navigationController?.navigationBar.topItem?.accessibilityLabel = "즐겨찾기 메뉴입니다"
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let ad = UIApplication.shared.delegate as? AppDelegate
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
        
    }
    
    
    
    
    
}
