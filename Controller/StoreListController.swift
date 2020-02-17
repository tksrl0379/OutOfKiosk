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
    var storeNameArray : Array<String> = []
    var storeCategoryArray : Array<String> = []
    var storeEnNameArray : Array<String> = []
    
    var storeMenuArray : Array<String> = [String](repeating: "0", count: 6)
    
    
    
    /* Cell 반복 횟수 관리 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return storeNameArray.count

    }
    
    /* Cell 편집 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* 재사용할 수 있는 cell을 CafeTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = CafeTableView.dequeueReusableCell(withIdentifier: "StoreList", for: indexPath ) as! StoreList
        
        /* StoreList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능 */
        cell.storeName_Label.text = storeNameArray[indexPath.row]
        cell.storeCategory_Label.text = storeCategoryArray[indexPath.row]
        
        return cell
    }
    
    /* 특정 Cell 클릭 이벤트 처리 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* view controller 간 데이터 교환
        : instantiateViewController를 통해 생성된 객체는 UIViewController타입이기 때문에 StoreDetailController 타입으로 다운캐스팅. */
        let rvc = self.storyboard?.instantiateViewController(identifier: "StoreDetailController") as! StoreDetailController
        
        
        phpGetStoreDetailInfo(storeEnNameArray[indexPath.row]){
            responseString in
            print(responseString)
            rvc.storeName = self.storeNameArray[indexPath.row]
            rvc.storeEnName = self.storeEnNameArray[indexPath.row]
            
            guard let dict = CustomConvert().convertStringToDictionary(text: responseString) else {return}
            for i in 0..<dict.count{
                //self.storeMenuArray.append(Array(dict)[i].value as! String)
                
                //print(Int(Array(dict)[i].key as! String)!)
                //print()
                self.storeMenuArray[Int(Array(dict)[i].key as! String)! - 1] = Array(dict)[i].value as! String
                rvc.storeMenuNameArray = self.storeMenuArray
                
            }
            print(self.storeMenuArray)
            
            DispatchQueue.main.async {
                /* StoreDetailController 로 화면 전환 */
                self.navigationController?.pushViewController(rvc, animated: true) // navigation controller 방식
            }
            
        }
                
    }
    
    
    func phpGetStoreDetailInfo(_ storeName : String, handler: @escaping (_ responseString : String )->Void){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/getStoreDetailInfo.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "store_name=\(storeName)"
        
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString!)")
            
            
            handler(responseString as! String)
        }
        
        //실행
        task.resume()
    }
    
    
    
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        //addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        /* TableView의 대리자(delegate)는 self(StoreListController)가 됨 */
        CafeTableView.delegate = self
        CafeTableView.dataSource = self
        self.CafeTableView.rowHeight = 100
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "가게"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "NanumSquare", size: 20)!]
        self.navigationController?.navigationBar.topItem?.accessibilityLabel = "가게 선택 메뉴입니다"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "가게"
        
        
    }
    
    
    
}
