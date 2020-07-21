//
//  ShoppingListController.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/14/20.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit
import CoreLocation

class ShoppingBasketController : UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    // MARK: - Property
    // MARK: Custom Property
    
    var prevViewName: String?
    var totalPrice : Int = 0
    
    // cell 관련
    var basket_productNum : Int = 0
    var basket_productName : Array<String>! = []
    var basket_productSize : Array<String>! = []
    var basket_productCount : Array<Int>! = []
    var basket_productPrice : Array<Int>! = []
    var basket_productSugar : Array<String>! = []
    var basket_productWhippedCream : Array<String>! = []
    
    // 비콘 관련
    var locationManager: CLLocationManager!
    var beaconConfirmFlag : Bool = false // 비콘버튼을 누르면 True가 되고 그 이후 비콘이 탐지가 되면 자동으로 전송
    
    // MARK: IBOutlet
    @IBOutlet weak var basket_TableView: UITableView!
    @IBOutlet weak var onlineOrder_Btn: UIButton!    // 즉시 주문
    @IBOutlet weak var beaconOrder_Btn: UIButton!    // 현장 주문
    
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initializeNavigationItem()
        self.initializeBeacon()
        self.initializeView()
        self.initializeOrderInfo()     // 주문 정보 불러오기
        self.initializeTableView()
    }
    
    // MARK: - Method
    // MARK: Table Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return basket_productNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = basket_TableView.dequeueReusableCell(withIdentifier: "ShoppingBasket", for: indexPath ) as! ShoppingBasket
        
        // 속성 문자열 제작 및 적용
        cell.BasketItemInfo_Label.attributedText = self.makeAttributedString(row: indexPath.row)   // 속성 문자열 제작
        cell.BasketItemInfo_Label.textAlignment = .center
        
        // Stepper 초기화
        cell.shoppingBasketProductSize_Stepper.value = Double(basket_productCount[indexPath.row])
        cell.deleteShoppingBasket_Btn.layer.cornerRadius = 5
        cell.deleteShoppingBasket_Btn.accessibilityLabel = basket_productName[indexPath.row] + " " + basket_productSize[indexPath.row] + "삭제하기"
        
        // 주문 버튼 초기화
        self.totalPrice += basket_productPrice[indexPath.row] * basket_productCount[indexPath.row]
        
        self.beaconOrder_Btn.setTitle("현장 주문 " + String(totalPrice)+"원", for: .normal)
        self.beaconOrder_Btn.accessibilityLabel = "현장 주문 \(totalPrice)원"
        
        self.onlineOrder_Btn.setTitle("즉시 주문 " + String(totalPrice)+"원", for: .normal)
        self.onlineOrder_Btn.accessibilityLabel = "즉시 주문 \(totalPrice)원"
        
        // Cell의 IBOutlet Foucs 순서 조절
        cell.accessibilityElements = [cell.BasketItemInfo_Label! , cell.shoppingBasketProductSize_Stepper!, cell.deleteShoppingBasket_Btn!]
        
        return cell
    }
    
    
    // MARK: Custom Method
    
    func initializeNavigationItem() {
        
        self.navigationItem.title = "장바구니"
        
        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = self.prevViewName! + "로 뒤로가기"
    }
    
    func initializeBeacon() {
        
        // 비콘 권할 설정
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()                // 위치 권한 받기
        
        self.locationManager.startUpdatingLocation()                     // 위치 업데이트 시작
        self.locationManager.allowsBackgroundLocationUpdates = true      // true: 백그라운드에서도 위치 체크, 필요없으면 false
        self.locationManager.pausesLocationUpdatesAutomatically = false  // 백그라운드에서 작동하기 위함
    }
    
    
    func initializeTableView() {
        
        self.basket_TableView.delegate = self
        self.basket_TableView.dataSource = self
        self.basket_TableView.rowHeight = 200.0
    }
    
    func initializeView() {
        
        self.onlineOrder_Btn.layer.cornerRadius = 5
        self.beaconOrder_Btn.layer.cornerRadius = 5
        
        self.onlineOrder_Btn.accessibilityTraits = .button
        self.beaconOrder_Btn.accessibilityTraits = .button
    }
    
    // 주문한 정보 불러오기
    func initializeOrderInfo() {
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        if let numOfProducts = ad?.numOfProducts{
            self.basket_productNum = numOfProducts
        }
        if let menuNameArray = ad?.menuNameArray {
            self.basket_productName = menuNameArray
        }
        if let menuSizeArray = ad?.menuSizeArray {
            self.basket_productSize = menuSizeArray
        }
        if let menuCountArray = ad?.menuCountArray {
            self.basket_productCount = menuCountArray
        }
        if let menuEachPriceArray = ad?.menuEachPriceArray {
            self.basket_productPrice = menuEachPriceArray
        }
        if let menuSugarContent = ad?.menuSugarContent {
            self.basket_productSugar = menuSugarContent
        }
        if let menuIsWhippedCream = ad?.menuIsWhippedCream {
            self.basket_productWhippedCream = menuIsWhippedCream
        }
    }
    
    func makeAttributedString(row: Int) -> NSMutableAttributedString {
        
        // 1. 메뉴 이름
        let productName = basket_productName[row]+" "+basket_productSize[row]+"\n"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)]
        let attributedString = NSMutableAttributedString(string: productName, attributes: attrs)
        
        // 2. 메뉴 개수, 가격, 옵션(당도, 휘핑크림)
        var productInfo = String(basket_productCount[row])+"개\t\t\t" + String(basket_productPrice[row] * basket_productCount[row])+"원\n"
        
        if self.basket_productSugar[row] == "NULL" {
            if self.basket_productWhippedCream[row] == "없이" {
                productInfo += "휘핑크림 추가 안함"
            }else if self.basket_productWhippedCream[row] == "올려서" {
                productInfo += "휘핑크림 추가"
            }
        }else if self.basket_productWhippedCream[row] == "NULL" {
            productInfo += "당도 : "+String(basket_productSugar[row])+"%"
        }
        
        let normalString = NSMutableAttributedString(string:productInfo)
        attributedString.append(normalString)
        
        // 3. 행 간격 조절
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 9
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
    func orderItem(){
        
        let taskGroup = DispatchGroup()
        
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = date.string(from: Date()) // Date(): 현재 날짜
        
        for i in 0..<basket_productNum {
            
            let userId = UserDefaults.standard.string(forKey: "id")!
            let token = UserDefaults.standard.string(forKey: "token")
            
            taskGroup.enter()
            CustomHttpRequest().phpCommunication(url: "order/api/order.php", postString: "name=\(basket_productName[i]+" "+basket_productSize[i])&count=\(basket_productCount[i])&sugar=\(basket_productSugar[i])&whippedcream=\(basket_productWhippedCream[i])&currentDate=\(currentDate)&userID=\(userId)&token=\(token!)"){ responseString in
                
                taskGroup.leave()
            }
        }
        
        // 주문(비동기 작업)이 모두 끝나면 작동
        taskGroup.notify(queue: .main) {
            
            let ad = UIApplication.shared.delegate as? AppDelegate
            
            // Main에 보여줄 정보 저장
            UserDefaults.standard.set(self.basket_productName[0], forKey: "mainProgressMenuName")
            UserDefaults.standard.set(ad?.numOfProducts, forKey: "mainProgressMenuCount")
            UserDefaults.standard.set(ad?.menuStoreName, forKey: "mainProgressStoreName")
            UserDefaults.standard.set("주문 확인 중", forKey: "pushMSG")
            UserDefaults.standard.set(0.33, forKey: "progressNumber")
            
            // 주문이 완료됐으므로 App delegate 정보 삭제
            ad?.numOfProducts = 0
            ad?.menuNameArray = []
            ad?.menuSizeArray = []
            ad?.menuCountArray = []
            ad?.menuEachPriceArray = []
            ad?.menuSugarContent = []
            ad?.menuIsWhippedCream = []
            
            self.alertMessage("주문 성공", "주문한 메뉴가 나올 때까지 기다려 주세요.")
            
            // 주문이 끝나면 이전 View 로 돌아감
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // 비콘 관련 메소드
    
    /*
     
    현재 비콘정보
    MiniBecon_00353
    UUID : fda50693-a4e2-4fb1-afcf-c6eb07647825
    Major : 10001
    Minor : 19641
     
    */
    
    func startScanning() {
        
        let uuid = UUID(uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 10001, minor: 19641, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    // 1. 권한 여부 체크
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            
            // background에서도 허용
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.allowsBackgroundLocationUpdates = true
            
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) { // Background에서도 실행가능하게 권한 부여
                
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    // 2. 비콘 탐색
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            
            print("found # of \(beacons.count) beacons")
            
            if self.beaconConfirmFlag == true {
                orderItem()
                
                // 주문이 완료 시 비콘 탐지 중지
                let uuid = UUID(uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825")! //UUID를 입력해야한다.
                let beaconRegion = CLBeaconRegion(uuid: uuid, major: 10001, minor: 19641, identifier: "MyBeacon")
                
                locationManager.stopUpdatingLocation()
                locationManager.stopMonitoringSignificantLocationChanges()
                locationManager.allowsBackgroundLocationUpdates = false
                locationManager.stopMonitoring(for: beaconRegion)
                locationManager.stopRangingBeacons(in: beaconRegion)
            }
        } else {
            print("Not found!")
        }
    }
    
    func alertMessage(_ title: String, _ description: String){
        
        DispatchQueue.main.async{
            
            let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertController.Style.alert)
            
            let defaultAction = UIAlertAction(title: "확인", style: .destructive) { (action) in }
            alert.addAction(defaultAction)
            
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: IBAction
    
    @IBAction func changeNumberOfProduct_Stepper(_ sender: UIStepper) {
        
        if sender.value == 0{
            
            self.totalPrice = 0 //개수가 바뀔때마다 0으로 초기화
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: "1개 이상만 가능합니다")
            }
            sender.value = 1.0
        }else{
            self.totalPrice = 0 //개수가 바뀔때마다 0으로 초기화
            
            let point = sender.convert(CGPoint.zero, to: basket_TableView)
            guard let indexPath = basket_TableView.indexPathForRow(at: point)else { return }
            
            let ad = UIApplication.shared.delegate as? AppDelegate
            self.basket_productCount[indexPath.row] = Int(sender.value)
            ad?.menuCountArray[indexPath.row] = Int(sender.value)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: self.basket_productName[indexPath.row] + " " + self.basket_productSize[indexPath.row] + String(Int(sender.value)) + "개")
            }
        }
        
        print("개수:", sender.value)
        self.basket_TableView.reloadData()
    }
    
    @IBAction func deleteProduct_Btn(_ sender : UIButton) {
        
        let point = sender.convert(CGPoint.zero, to: basket_TableView)
        guard let indexPath = basket_TableView.indexPathForRow(at: point) else { return }
        
        // Table View cell 관련 Property의 데이터 삭제
        self.basket_productNum -= 1
        self.basket_productName.remove(at: indexPath.row)
        self.basket_productSize.remove(at: indexPath.row)
        self.basket_productCount.remove(at: indexPath.row)
        self.basket_productPrice.remove(at: indexPath.row)
        self.basket_productSugar.remove(at: indexPath.row)
        self.basket_productWhippedCream.remove(at: indexPath.row)
        
        self.basket_TableView.deleteRows(at: [indexPath], with: .fade)
        
        // App delegate 의 데이터 삭제
        let ad = UIApplication.shared.delegate as? AppDelegate
        ad?.numOfProducts -= 1
        ad?.menuNameArray.remove(at: Int(indexPath.row))
        ad?.menuSizeArray.remove(at: Int(indexPath.row))
        ad?.menuCountArray.remove(at: Int(indexPath.row))
        ad?.menuEachPriceArray.remove(at: Int(indexPath.row))
        ad?.menuSugarContent.remove(at: Int(indexPath.row))
        ad?.menuIsWhippedCream.remove(at: Int(indexPath.row))
        
        // 개수 0 되면 PopView
        if ad?.numOfProducts == 0 {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func orderItems_Btn(_ sender: Any) {
        orderItem()
    }
    
    @IBAction func orderItemByBeacon(_ sender: Any) {
        self.beaconConfirmFlag = !self.beaconConfirmFlag
        
        if self.beaconConfirmFlag == true {
            beaconOrder_Btn.setTitle("현장 주문 취소하기", for: .normal)
            beaconOrder_Btn.accessibilityLabel = "현장 주문 취소하기"
        } else {
            beaconOrder_Btn.setTitle("현장 주문 "+String(totalPrice)+"원", for: .normal)
            beaconOrder_Btn.accessibilityLabel = "현장 주문 "+String(totalPrice)+"원"
        }
    }
    
    
    
    
    
    
    
    
}
