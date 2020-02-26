//
//  StoreDetailController.swift
//  OutOfKiosk
//
//  Created by a1111,Jinseo Park on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit


/* 가게 접속하면 뜨는 메인 화면 */
class StoreDetailController : UIViewController{
    
    /* 가게 상세 정보 관련 변수들 */
    var storeKorName: String?
    var storeEnName : String?
    var storeMenuNameArray: Array<String> = [String](repeating: "0", count: 6)
    
    /* voiceover 접근성 전용 */
    @IBOutlet weak var menu_Label: UILabel!
    @IBOutlet weak var storeName_Label: UILabel!
    
    /* DialogFlow 로 주문하기 버튼 */
    @IBOutlet weak var orderMenuByAI_Btn: UIButton!
    
    /* 리뷰로 넘어가는 버튼 */
    @IBOutlet weak var reviewBtn: UIButton!
    
    /* 메뉴 버튼 관련 변수들 */
    @IBOutlet weak var firstCategory_Btn: UIButton!
    @IBOutlet weak var secondCategory_Btn: UIButton!
    
    /* 경계선 UI 관련 변수들 */
    @IBOutlet weak var border_View: UIView!
    @IBOutlet weak var border2_View: UIView!
    
    /* 챗봇으로 주문할 때마다 숫자 증가*/
    @IBOutlet weak var shoppingBasket_Btn: UIButton!
    
    /* 음성주문 버튼: DialogFlowPopUpController로 넘어감 */
    @IBAction func orderMenuByAI_Btn(_ sender: Any) {
        
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
        
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(rvc, animated: true)
        }
        
    }
    
    
    /* 첫번째 메뉴 버튼: DetailMenuController로 넘어감 */
    @IBAction func firstMenu_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            return}
        
        /* 가게 영어, 한글 이름 전송 */
        rvc.storeEnName = storeEnName
        rvc.storeKorName = storeKorName
        
        /* 카테고리 번호 전송: 첫번째 메뉴라는 것을 알려주기 위함 */
        rvc.categoryNumber = 1
        
        
        self.navigationController?.pushViewController(rvc, animated: true)
        
    }
    
    
    @IBAction func secondMenu_Btn(_ sender: Any) {
        
        //rvc 가 옵셔널 타입이므로 guard 구문을 통해서 옵셔널 바인딩 처리
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailMenuController") as? DetailMenuController else {
            //아니면 종료
            return}
        
        /* 가게 영어, 한글 이름 전송 */
        rvc.storeEnName = storeEnName
        rvc.storeKorName = storeKorName
        
        /* 카테고리 번호 전송: 첫번째 메뉴라는 것을 알려주기 위함 */
        rvc.categoryNumber = 2
        
        
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
                
                
                self.navigationController?.pushViewController(rvc, animated: true)
            }else{
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
        
        print(self.storeMenuNameArray)
        
        /* backButton 커스터마이징 */
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        backBtn.setImage(UIImage(named:"left_image"), for: .normal)
        backBtn.addTarget(self, action: #selector(StoreDetailController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        //addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        ///////
        self.orderMenuByAI_Btn.imageView?.contentMode = .scaleAspectFit
        self.orderMenuByAI_Btn.imageEdgeInsets = UIEdgeInsets(top: 70,left: 70,bottom: 70,right: 70)
        self.orderMenuByAI_Btn.frame = CGRect(x: -37, y: 99, width: 180, height: 90)
        orderMenuByAI_Btn.setTitle("                음성주문", for: .normal)
        
        
        
        /* 테두리 만들기 */
        border_View.layer.borderWidth = 0.5
        border_View.layer.borderColor = UIColor.gray.cgColor
        
        border2_View.layer.borderWidth = 0.5
        border2_View.layer.borderColor = UIColor.gray.cgColor
        
        /* 테두리 둥글게 만들기 */
        firstCategory_Btn.layer.cornerRadius = 5
        firstCategory_Btn.layer.borderWidth = 0.2
        firstCategory_Btn.layer.borderColor = UIColor.gray.cgColor
        
        secondCategory_Btn.layer.cornerRadius = 5
        secondCategory_Btn.layer.borderWidth = 0.2
        secondCategory_Btn.layer.borderColor = UIColor.gray.cgColor
        
        shoppingBasket_Btn.layer.cornerRadius = 5
        
        /* 접근성 */
        orderMenuByAI_Btn.accessibilityLabel = "스타벅스 음성주문"
        menu_Label.accessibilityLabel = "아래에 스타벅스 메뉴가 있습니다"
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        /* 가게 이름, 카테고리 이름들 받아와서 UI 갱신 */
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
            }
        }
        
        /* 장바구니 개수 갱신 */
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        //        ad?.numOfProducts = 1
        //        ad?.menuNameArray = ["모카스무디"]
        //        ad?.menuSizeArray = ["스몰"]
        //        ad?.menuCountArray = [3]
        //        ad?.menuEachPriceArray = [5300]
        //        ad?.menuSugarContent = ["40%"]
        //        ad?.menuIsWhippedCream = ["NULL"]
        
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        /* 장바구니 개수 갱신 */
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        shoppingBasket_Btn.setTitle("장바구니 : "+String(ad!.numOfProducts) + " 개", for: .normal)
        shoppingBasket_Btn.accessibilityLabel = "장바구니 버튼. 현재 \(ad!.numOfProducts)개 담겨있습니다."
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController!.navigationBar.shadowImage = nil
        
    }
    
}
