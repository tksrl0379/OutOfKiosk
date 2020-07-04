//
//  StoreDetailController.swift
//  OutOfKiosk
//
//  Created by a1111,Jinseo Park on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit



class StoreDetailController : UIViewController{
    
    // MARK: - Propery
    
    // MARK: 가게 정보
    var storeKorName: String?
    var storeEnName : String?
    var storeMenuNameArray: Array<String> = [String](repeating: "0", count: 6)
    
    // MARK: IBOutlet
    @IBOutlet weak var storeName_Label: UILabel!
    @IBOutlet weak var voiceOrder_Btn: UIButton!
    @IBOutlet weak var review_Btn: UIButton!
    
    @IBOutlet weak var menu_Label: UILabel!
    
    @IBOutlet weak var firstCategory_Btn: UIButton!
    @IBOutlet weak var secondCategory_Btn: UIButton!
    
    @IBOutlet weak var shoppingBasket_Btn: UIButton!
    
    @IBOutlet weak var border_View: UIView!
    @IBOutlet weak var border2_View: UIView!
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeNavigationItem()
        self.initializeView()
        self.getStoreInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // navigationbar title 동적 변경: navigationbar 안보이게 하려고 설정 ( viewWillAppear에서 동작)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.setUpShoppingBasket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    
    // MARK: - Method
    // MARK: Custom Method
    
    func initializeNavigationItem() {
        
        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "가게 목록 뒤로가기"
    }
    
    func initializeView() {
        
        // 음성주문 버튼 설정
        self.voiceOrder_Btn.imageView?.contentMode = .scaleAspectFit
        self.voiceOrder_Btn.imageEdgeInsets = UIEdgeInsets(top: 5,left: 10,bottom: 5,right: 80)
        voiceOrder_Btn.setTitle("음성주문", for: .normal)
        
        // 테두리 설정
        border_View.layer.borderWidth = 0.5
        border_View.layer.borderColor = UIColor.gray.cgColor
        
        border2_View.layer.borderWidth = 0.5
        border2_View.layer.borderColor = UIColor.gray.cgColor
        
        // 버튼 설정
        firstCategory_Btn.layer.cornerRadius = 5
        firstCategory_Btn.layer.borderWidth = 0.2
        firstCategory_Btn.layer.borderColor = UIColor.gray.cgColor
        
        secondCategory_Btn.layer.cornerRadius = 5
        secondCategory_Btn.layer.borderWidth = 0.2
        secondCategory_Btn.layer.borderColor = UIColor.gray.cgColor
        
        shoppingBasket_Btn.layer.cornerRadius = 5
        
        // 접근성
        voiceOrder_Btn.accessibilityLabel = self.storeKorName! + "음성주문"
        menu_Label.accessibilityLabel = "아래에 메뉴가 있습니다"
        
    }
    
    func getStoreInfo() {
        
        // 가게 이름, 카테고리 이름들 받아와서 UI 갱신
        CustomHttpRequest().phpCommunication(url: "getStoreDetailInfo.php", postString: "store_name=\(storeEnName!)"){
            
            responseString in
            print(responseString)
            
            guard let dict = CustomConvert().convertStringToDictionary(text: responseString) else {return}
            for i in 0..<dict.count{
                
                self.storeMenuNameArray[Int(Array(dict)[i].key as! String)! - 1] = Array(dict)[i].value as! String
                
            }
            DispatchQueue.main.async{
                self.storeName_Label.text = self.storeKorName
                self.firstCategory_Btn.setTitle(self.storeMenuNameArray[0], for: .normal)
                self.secondCategory_Btn.setTitle(self.storeMenuNameArray[1], for: .normal)
                
                self.firstCategory_Btn.accessibilityLabel = self.storeMenuNameArray[0] + "메뉴 버튼"
                self.secondCategory_Btn.accessibilityLabel = self.storeMenuNameArray[1] + "메뉴 버튼"
            }
        }
    }
    
    func setUpShoppingBasket() {
        
        // 장바구니 개수 갱신
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
    }
    
    
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
    
    
    // MARK: IBAction
    @IBAction func voiceOrder_Btn(_ sender: Any) {
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as? DialogFlowPopUpController else {
            return}
        
        rvc.storeKorName = self.storeKorName
        
        
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    
    /* 리뷰 버튼: ReviewController로 넘어감 */
    @IBAction func reviewMenu_Btn(_ sender: Any) {
        
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewController") as? ReviewController else {
            return}
        
        // 가게 영어이름 전송
        rvc.storeEnName = self.storeEnName
        rvc.storeKorName = self.storeKorName
        
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(rvc, animated: true)
        }
        
    }
    
    
    /* 첫번째 메뉴 버튼: DetailMenuController로 넘어감 */
    @IBAction func firstCategory_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            return}
        
        /* 가게 영어, 한글 이름 전송 */
        rvc.storeEnName = storeEnName
        rvc.storeKorName = storeKorName
        
        /* 카테고리 번호 전송: 첫번째 메뉴라는 것을 알려주기 위함 */
        rvc.categoryNumber = 1
        
        /* 메뉴 이름 넘기기 */
        rvc.menuKorName = self.storeMenuNameArray[0]
        
        
        self.navigationController?.pushViewController(rvc, animated: true)
        
    }
    
    
    @IBAction func secondCategory_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            //아니면 종료
            return}
        
        /* 가게 영어, 한글 이름 전송 */
        rvc.storeEnName = storeEnName
        rvc.storeKorName = storeKorName
        
        /* 카테고리 번호 전송: 첫번째 메뉴라는 것을 알려주기 위함 */
        rvc.categoryNumber = 2
        
        /* 메뉴 이름 넘기기 */
        rvc.menuKorName = self.storeMenuNameArray[1]
        
        
        self.navigationController?.pushViewController(rvc, animated: true)
        
    }
    
    
    /* 장바구니 버튼: ShoppingBasketController 로 넘어감 */
    @IBAction func shoppingList_Btn(_ sender: Any) {
        
        /* 장바구니가 비어있지 않은 경우 화면이 전환. 비어있을 시 경고 메시지 뜸 */
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        if let count = ad?.numOfProducts{
            if count != 0 {
                guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingBasketController") as? ShoppingBasketController else {
                    return}
                
                rvc.beforeControllerName = self.storeKorName
                self.navigationController?.pushViewController(rvc, animated: true)
            }else{
                self.alertMessage(" ","장바구니가 비어있어요")
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
}
