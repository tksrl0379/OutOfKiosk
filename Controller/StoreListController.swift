//
//  StoreListController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

/* TableView 구현 위해선 Delegate(, DataSource 두 프로토콜 상속 필요 */
/* Delegate와 DataSource 둘 다 델리게이트인데
 차이점은 DataSource는 자원을 담당하고, Delgate는 자원과 액션을 담당한다.*/
class StoreListController : UIViewController, UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var CafeTableView: UITableView!
    
    /* cell에 띄울 가게 상세 정보 관련 변수 */
    var storeKorNameArray : Array<String> = []
    var storeTypeArray : Array<String> = []
    var storeEnNameArray : Array<String> = []
    
    
    /* Cell 반복 횟수 관리 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return storeKorNameArray.count
    }
    
    /* Cell 편집 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* 재사용할 수 있는 cell을 CafeTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = CafeTableView.dequeueReusableCell(withIdentifier: "StoreList", for: indexPath ) as! StoreList
        
        /* StoreList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능: 가게 이름(name), 가게 종류(type) 명시 */
        cell.storeName_Label.text = storeKorNameArray[indexPath.row]
        cell.storeType_Label.text = storeTypeArray[indexPath.row]
        
        //cell.storeName_Label.accessibilityLabel = cell.storeName_Label.text + 
        
        return cell
    }
    
    /* 특정 Cell 클릭 이벤트 처리 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* view controller 간 데이터 교환
        : instantiateViewController를 통해 생성된 객체는 UIViewController타입이기 때문에 StoreDetailController 타입으로 다운캐스팅. */
        let rvc = self.storyboard?.instantiateViewController(identifier: "StoreDetailController") as! StoreDetailController
        
        /* 해당 가게의 한글이름, 영어이름을 넘겨줌 */
        rvc.storeKorName = self.storeKorNameArray[indexPath.row]
        rvc.storeEnName = self.storeEnNameArray[indexPath.row]
        
        
        
        DispatchQueue.main.async {
            /* StoreDetailController 로 화면 전환 */
            self.navigationController?.pushViewController(rvc, animated: true) // navigation controller 방식
        }
        
    }
    
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        /* focus order 정할 수 있음 */
        //self.view.accessibilityElements = [self.navigationItem.titleView, self.navigationItem.backBarButtonItem, self.CafeTableView]
        
        /* backButton 커스터마이징 */
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        backBtn.setImage(UIImage(named:"left_image"), for: .normal)
        backBtn.addTarget(self, action: #selector(StoreListController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "메인으로 뒤로가기"
        
        
        /* TableView의 대리자(delegate)는 self(StoreListController)가 됨 */
        CafeTableView.delegate = self
        CafeTableView.dataSource = self
        self.CafeTableView.rowHeight = 100
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* TableView 타이틀 자동 사이즈 조절(사용안함) */
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        /* 가게 정보 받기 */
        storeKorNameArray.removeAll()
        storeTypeArray.removeAll()
        storeEnNameArray.removeAll()
        
        CustomHttpRequest().phpCommunication(url: "getStoreInfo.php", postString: ""){
            responseString in
            
            let dict = CustomConvert().convertStringToDictionary(text: responseString)!
            
            for i in 0..<dict.count{
                self.storeKorNameArray.append(Array(dict)[i].key as! String)
                
                let sub_info = Array(dict)[i].value as! NSDictionary
                self.storeTypeArray.append(sub_info["category"] as! String)
                self.storeEnNameArray.append(sub_info["en_name"] as! String)
                
            }
            
            DispatchQueue.main.async {
                self.CafeTableView.reloadData()
            }
            
        }
        
        self.navigationController?.navigationBar.topItem?.title = "가게 목록"
        self.navigationController?.navigationBar.topItem?.accessibilityLabel = "가게 목록"
        self.navigationController?.navigationBar.topItem?.accessibilityTraits = .header
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "가게 목록"
        
    }
    
}
