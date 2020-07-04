//
//  StoreListController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class StoreListController : UIViewController, UITableViewDelegate , UITableViewDataSource{
    
    // MARK: - Propery
    // MARK: Custom Property
    
    // Cell 에 띄울 가게 상세 정보 관련 변수
    var storeKorNameArray : Array<String> = []
    var storeTypeArray : Array<String> = []
    var storeEnNameArray : Array<String> = []
    
    // MARK: IBOutlet
    @IBOutlet weak var CafeTableView: UITableView!
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeBackBtn()
        self.initializeTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setUpNavigationBar()
        self.setUpStoreList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.topItem?.title = "가게 목록"
    }
    
    
    // MARK: - Method
    // MARK: Table Method
    
    // Cell 반복 횟수 관리
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return storeKorNameArray.count
    }
    
    // Cell 편집
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 재사용할 수 있는 cell을 CafeTableView 에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = CafeTableView.dequeueReusableCell(withIdentifier: "StoreList", for: indexPath ) as! StoreList
        
        // StoreList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능: 가게 이름(name), 가게 종류(type) 명시
        cell.storeName_Label.text = storeKorNameArray[indexPath.row]
        cell.storeType_Label.text = storeTypeArray[indexPath.row]
        
        return cell
    }
    
    // 특정 Cell 클릭 이벤트 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // view controller 간 데이터 교환: instantiateViewController를 통해 생성된 객체는 UIViewController타입이기 때문에 StoreDetailController 타입으로 다운캐스팅. */
        let rvc = self.storyboard?.instantiateViewController(identifier: "StoreDetailController") as! StoreDetailController
        
        /* 해당 가게의 한글이름, 영어이름을 넘겨줌 */
        rvc.storeKorName = self.storeKorNameArray[indexPath.row]
        rvc.storeEnName = self.storeEnNameArray[indexPath.row]
        
        DispatchQueue.main.async {
            
            self.navigationController?.pushViewController(rvc, animated: true) // StoreDetailController 로 화면 전환
        }
        
    }
    
    
    // MARK: Custom Method
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func initializeBackBtn() {
        
        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "메인으로 뒤로가기"
    }
    
    func initializeTableView() {
        self.CafeTableView.delegate = self
        self.CafeTableView.dataSource = self
        self.CafeTableView.rowHeight = 100
    }
    
    func setUpNavigationBar() {
        
        self.navigationController?.navigationBar.prefersLargeTitles = false // TableView 타이틀 자동 사이즈 조절(사용안함)
        self.navigationController?.navigationBar.topItem?.title = "가게 목록"
        self.navigationController?.navigationBar.topItem?.accessibilityLabel = "가게 목록"
        self.navigationController?.navigationBar.topItem?.accessibilityTraits = .header
        
    }
    
    func setUpStoreList() {
        
        // 가게 정보 받기
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
    }
    
}
