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
    
    var storeName = ["스타벅스", "역전우동"]
    
   
    /* Cell 반복 횟수 관리 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return storeName.count

    }
    
    /* Cell 편집 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* 재사용할 수 있는 cell을 CafeTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = CafeTableView.dequeueReusableCell(withIdentifier: "StoreList", for: indexPath ) as! StoreList
        
        /* StoreList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능 */
        cell.storeName_Label.text = storeName[indexPath.row]
        
        return cell
    }
    
    /* 특정 Cell 클릭 이벤트 처리 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* Switch로특정 row 접근 가능
        switch indexPath.row {
        case 0:
            vc.receivedValueFromBeforeVC = indexPath.row //해당 뷰와 관련된 .swift 파일의 변수에 값 전달
        case 1:
            vc.receivedValueFromBeforeVC = indexPath.row //해당 뷰와 관련된 .swift 파일의 변수에 값 전달
        case 2:
            vc
        default:
            print("nothing")
        } */
        
        /* view controller 간 데이터 교환
        : instantiateViewController를 통해 생성된 객체는 UIViewController타입이기 때문에 StoreDetailController 타입으로 다운캐스팅. */
        let vc = self.storyboard?.instantiateViewController(identifier: "CafeDetailController") as! CafeDetailController
        vc.receivedValueFromBeforeVC = indexPath.row
        
        /* StoreDetailController 로 화면 전환 */
        //self.present(vc, animated: true, completion: nil) // present 방식
        self.navigationController?.pushViewController(vc, animated: true) // navigation controller 방식
        
        
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
        backBtn.addTarget(self, action: #selector(FavoriteMenuController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
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
