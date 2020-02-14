//
//  ShoppingListController.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/14/20.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

/*
 장바구니 뷰
 메뉴이름과 수량, 그리고 각 메뉴에 대한 가격정보가 적혀있다.
 
 필요기능 ->
 1. 각 테이블에 대한 아이템에 대하여 개수는 수정가능하고
 2. 아이템 자체를 삭제할 수 있도록 한다.
 3. 마지막에는 총 메뉴에 대한 가격을 알려주는 것이 좋다.
 
 프로세스
 
 1.임의로 메뉴이름, 수량, 가격을 라벨에 적어둔다. (Dictionary로 해야할지, 혹은 Array로 해야할지)
 
 1-1) 챗봇을 통해 메뉴가 생길때마다 append를 한다?
 rvc.blarblar = ddd
 Dictionary가 별 의미가 없는것이 한 아이템을 주문할때 순차적으로 모든값이 들어오고 rvc에 적재되므로 배열이 좋지 않을까 싶다.
 
 
 2.수량은 버튼등을 이용해 올리기?내리기?
 3.삭제버튼생성
 
 */
class ShoppingBasketController : UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    //    @IBOutlet weak var ProductName_Label: UILabel!
    
    @IBOutlet weak var ShoppingBasketTableView: UITableView!    
    
    /* 주문하기, 삭제하기 UI oultet*/
    @IBOutlet weak var orderItems_Btn: UIButton!
    
    /* 비콘으로 주문하기 UI outlet*/
    @IBOutlet weak var orderItemByBeacon: UIButton!
    
    
    
    //    @IBOutlet weak var deleteShoppingBasketProduct_Btn: UIButton!
    
    /* 주문을 하면서 CafeDetailController의 UIBtn을 초기화 해주어야한다.*/
    var willGetShoppingBasket_Btn : UIButton!
    
    /* Table의 Cell을 위한 변수들로써, 음성주문한 메뉴들의 정보를 갖고와 저장하여 출력이 가능하다.*/
    var shoppingBasket_numOfProducts : Int = 0
    
    var shoppingBasket_productName : Array<String>! = []//["초콜렛 스무디","초콜레 프라푸치노","자바칩 프라푸치노"] //test용도
    var shoppingBasket_productSize : Array<String>! = []//["Large","Small","Medium"] //test용도
    var shoppingBasket_productCount : Array<Int>! = []//[3, 1 ,2] //test용도
    var shoppingBasket_productEachPrice : Array<Int>! = []//[3000,5000,4500]
    var shoppingBasket_productSugarContent : Array<String>! = []//[3000,5000,4500]
    var shoppingBasket_productIsWhippedCream : Array<String>! = []//[3000,5000,4500]
    
    var basketItemInfo : String = String() //이 곳에 제품에 대한 이름, 가격, 수량, 옵션 텍스트를 넣을것이다.
    
    var totalPrice : Int = 0
    
    /* beacon variables
     1.locationManager : responsible for requesting location permission from users
     2.beaconConfrimFlag : 비콘버튼을 누르면 True가 되고 그 이후 비콘이 탐지가 되면 자동으로 전송한다.
     3.taksld : background에서도 orderItem()이 실행할 수 있도록 하게 하는 변수
     */
    var locationManager: CLLocationManager! //
    var beaconConfirmFlag : Bool = false //
//    var taskld : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shoppingBasket_numOfProducts
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ShoppingBasketTableView.dequeueReusableCell(withIdentifier: "ShoppingBasket", for: indexPath ) as! ShoppingBasket
        
        basketItemInfo = " " //다음 행의 Cell이 될 때마다 초기화를 시켜주어 재사용하게함.
        
        /* 주문하기 버튼 옆에 총액수 표현*/
        totalPrice += shoppingBasket_productEachPrice[indexPath.row]*shoppingBasket_productCount[indexPath.row]
        
        /* BasketItemInfo_Label 에 적을 내용 한번에 담기.
         메뉴이름은 시각장애인이 보기 편하도록 사이즈 =30, Bold Style로 함.
         */
        let productName = shoppingBasket_productName[indexPath.row]+" "+shoppingBasket_productSize[indexPath.row]+"\n"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)]
        let attributedString = NSMutableAttributedString(string:productName, attributes:attrs as [NSAttributedString.Key : Any])
        
        /* 메뉴의 수량, 가격, 그리고 옵션을 보여주는 변수*/
        var productInfo : String = String(shoppingBasket_productCount[indexPath.row])+"개"+"\t\t\t" + String(shoppingBasket_productEachPrice[indexPath.row]*shoppingBasket_productCount[indexPath.row])+"원"+"\n"
        
        orderItems_Btn.setTitle("주문하기 "+String(totalPrice)+"원", for: .normal)
        /* 접근성 */
        orderItems_Btn.accessibilityLabel = "주문하기 버튼. \(totalPrice)원 입니다"
        
        /* Stepper 초기값 */
        cell.shoppingBasketProductSize_Stepper.value = Double(shoppingBasket_productCount[indexPath.row])
      
        /* delete customizing*/
        cell.deleteShoppingBasket_Btn.layer.cornerRadius = 5
        
        /* option(당도 or 휘핑크림) 보여주기
         */
        if (shoppingBasket_productSugarContent[indexPath.row] == "NULL") {
            if (shoppingBasket_productIsWhippedCream[indexPath.row] == "없이") {
                
                productInfo += "휘핑크림 추가 안함"
            }else if(shoppingBasket_productIsWhippedCream[indexPath.row] == "올려서"){
                
                productInfo += "휘핑크림 추가"
            }
            
        }else if (shoppingBasket_productIsWhippedCream[indexPath.row] == "NULL"){
            
            productInfo += "당도 : "+String(shoppingBasket_productSugarContent[indexPath.row]) + "%"
        }
        
        /* 특정 글자 폰트 사이즈 조절.
         폰트는 나눔스퀘어B로 기본 설정이 되었기 때문에 바꿀 필요없다.
         */
        let normalString = NSMutableAttributedString(string:productInfo)
        attributedString.append(normalString)
        
        
        //행간 늘리는건 나중에
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.lineSpacing = 9
         attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
         
        
        /* 메뉴정보를 BasketItemInfo_Label에 저장 한다. 후에 출력 됨*/
        cell.BasketItemInfo_Label.attributedText = attributedString
        
        cell.BasketItemInfo_Label.textAlignment = .center
        
        /* accessbilityElements를 이용하면 수량 증/감 버튼과 삭제하기 버튼을 순서로 정할 수 있다.*/
        cell.accessibilityElements = [cell.BasketItemInfo_Label! , cell.shoppingBasketProductSize_Stepper!, cell.deleteShoppingBasket_Btn!]
        
        return cell
    }
    
    
    
    /* 해당 Cell의 Index에 맞게 수량 증감이 가능하도록 한다.*/
    @IBAction func changeNumberOfProduct_Stepper(_ sender: UIStepper) {
        
        /*Index를 찾는다.*/
        let point = sender.convert(CGPoint.zero, to: ShoppingBasketTableView)
        guard let indexPath = ShoppingBasketTableView.indexPathForRow(at: point)else{return}
        
        //        print(sender.value)
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        shoppingBasket_productCount[indexPath.row] = Int(sender.value)
        ad?.menuCountArray[indexPath.row] = Int(sender.value)
        
        totalPrice = 0 //개수가 바뀔때마다 0으로 초기화
        
        basketItemInfo = " " //ItemInfo_label 초기화
        
        ShoppingBasketTableView.reloadData()
        
    }
    
    
    
    /*
     TableView의 해당 Cell을 지우는 버튼.
     버튼 클릭시 메뉴가 삭제된다.
     shoppoingBasket_xx의 remove는 현재 테이블에 보여주는 셀을 지운다
     ad?.menuXXX는 Appdelegate에 실제로 저장되어있는 데이터이므로 지운다.
     */
    @IBAction func deleteShoppingBasketProduct_Btn(_ sender : UIButton) {
        
        //print("삭제삭제")
        let point = sender.convert(CGPoint.zero, to: ShoppingBasketTableView)
        guard let indexPath = ShoppingBasketTableView.indexPathForRow(at: point)else{return}
        
        shoppingBasket_numOfProducts -= 1
        shoppingBasket_productName.remove(at: indexPath.row)
        shoppingBasket_productSize.remove(at: indexPath.row)
        shoppingBasket_productCount.remove(at: indexPath.row)
        shoppingBasket_productEachPrice.remove(at: indexPath.row)
        shoppingBasket_productSugarContent.remove(at: indexPath.row)
        shoppingBasket_productIsWhippedCream.remove(at: indexPath.row)
        
        
        let ad = UIApplication.shared.delegate as? AppDelegate
        ad?.numOfProducts -= 1
        //        self.willGetShoppingBasket_Btn.setTitle("장바구니 : " + String(ad!.numOfProducts) + " 개", for: .normal)
        ad?.menuNameArray.remove(at: Int(indexPath.row))
        ad?.menuSizeArray.remove(at: Int(indexPath.row))
        ad?.menuCountArray.remove(at: Int(indexPath.row))
        ad?.menuEachPriceArray.remove(at: Int(indexPath.row))
        ad?.menuSugarContent.remove(at: Int(indexPath.row))
        ad?.menuIsWhippedCream.remove(at: Int(indexPath.row))
        
        
        ShoppingBasketTableView.deleteRows(at: [indexPath], with: .fade)
        
        /* 장바구니에 담겨진 메뉴 개수가 0개면 알아서 popView 되기.*/
        if ad?.numOfProducts == 0 {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    /* 온라인 주문 및 비콘주문 시 필요한 함수*/
    func orderItem(){
        
        /* AppDelegate에 저장된 모든 정보를 Dynamic하게 보내야하므로
         저장된 장바구니의 아이템 개수만큼 for loop를 돌려서 php통신을 이용하여 DB로 보낸다.
         보내는 아이템은 동시에 보내야 하므로 같은 date를 보낸다.
         */
        let now = Date()
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = date.string(from: now)
        //        print(currentDate, type(of: currentDate))
        
        
        
        for i in 0...shoppingBasket_numOfProducts-1 {
            /*if let userId = UserDefaults.standard.string(forKey: "id"){
             
             print("My ID : ", userId , "type : ", type(of: userId))
             }*/
            
            let userId = UserDefaults.standard.string(forKey: "id")!
            
            print("userID type is : ", type(of: userId))
            let parameters: Parameters=[
                "name" : shoppingBasket_productName[i]+" "+shoppingBasket_productSize[i],
                "count": shoppingBasket_productCount[i],
                "sugar": shoppingBasket_productSugarContent[i],
                "whippedcream": shoppingBasket_productIsWhippedCream[i],
                "currentDate" : currentDate,
                "userID" : userId//UserDefaults.standard.string(forKey: "id")
                //user Id또한 넣어주어야한다.
                //order ID는 DB에서 auto_increament 한다.
            ]
            
            /* php 서버 위치 */
            let URL_ORDER = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/order/api/order.php"
            //Sending http post request
            Alamofire.request(URL_ORDER, method: .post, parameters: parameters).responseString
                {
                    response in
                    print("응답",response)
                    
            }
        }
        
        
        
        
        self.navigationController?.popViewController(animated: true)
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        ad?.numOfProducts = 0
        /* 주문이 완료되면 현재 장바구니의 아이템을 삭제해야하므로 appdelegate의 모든 아이템을 초기화한다.*/
        //self.willGetShoppingBasket_Btn.setTitle("장바구니 : " + String(ad!.numOfProducts) + " 개", for: .normal)
        
        ad?.menuNameArray = []
        ad?.menuSizeArray = []
        ad?.menuCountArray = []
        ad?.menuEachPriceArray = []
        ad?.menuSugarContent = []
        ad?.menuIsWhippedCream = []
        
    }
    @IBAction func orderItems_Btn(_ sender: Any) {
        orderItem()
    }
    
    @IBAction func orderItemByBeacon(_ sender: Any) {
        /* 현재 장바구니 정보를 비콘이 탐지되면 바로 쏘아지게 하는것이다.*/
        self.beaconConfirmFlag = true
        print(self.beaconConfirmFlag)
    }
    
    
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /* 비콘 관련 메소드 */
    /* 권환이 확인되었는지를 체크한다. 최초에 체크가 안되면 디버그난다.*/
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            
            /*background에서도 허용하기*/
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.allowsBackgroundLocationUpdates = true
            
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) { /* Monitoring은 Background에서도 실행가능하게 권한을 줌*/
                
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        
        /* 후에는 감지된 UUID를 UserDefaults에 저장하여 쓸 수 있게 하고싶다.
         현재 비콘정보
         MiniBecon_00353
         UUID : fda50693-a4e2-4fb1-afcf-c6eb07647825
         Major : 10001
         Minor : 19641
         */
        let uuid = UUID(uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825")! //UUID를 입력해야한다.
        //let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 10001, minor: 19641, identifier: "MyBeacon")//The major and minor values of the beacons are ignored.
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 10001, minor: 19641, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
    /* 상시 비콘을 탐색하는 프로토콜*/
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
                        
            print("found # of \(beacons.count) beacons")

            /* 비콘이 탐지가 되고 비콘전송을 누를시에 주문 전송이 되게 한다.*/
            /* 이슈 -> Background에서 감지가 되지만 계속 이 함수를 여러번 스택하고
             후에 foreground로 갔을 때 바로 쌓여저 있는 orderItem을 한꺼번에 쏜다.
             */
            if(self.beaconConfirmFlag == true){
                orderItem()
                self.beaconConfirmFlag = false //orderItem()을 보내면 다시 Flag를 false로 만들어서 비콘이 탐지가 되어도 더 이상 하지 못하도록 바꾼다.
            }
            //updateDistance(beacons[0].proximity)
        } else {
            print("Not found!")
            //updateDistance(.unknown)
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /* 비콘 권한 설정하기 */
        locationManager = CLLocationManager()   // locationManager 초기화.
        locationManager.delegate = self // locationManager 초기화.
        locationManager.requestAlwaysAuthorization()    // 위치 권한 받아옴.
        
        locationManager.startUpdatingLocation()                 // 위치 업데이트 시작
        locationManager.allowsBackgroundLocationUpdates = true  // 백그라운드에서도 위치를 체크할 것인지에 대한 여부. 필요없으면 false로 처리하자.
        locationManager.pausesLocationUpdatesAutomatically = false  // 이걸 써줘야 백그라운드에서 멈추지 않고 돈다
        
        

//        locationManager.allowsBackgroundLocationUpdates = true
        
        /* UI : 버튼의 각을 줄인다*/
        orderItems_Btn.layer.cornerRadius = 5
        //        deleteShoppingBasketProduct_Btn
        //        deleteShoppingBasketProduct_Btn.layer.cornerRadius = 5
        
        
        ShoppingBasketTableView.delegate=self
        ShoppingBasketTableView.dataSource=self
        self.ShoppingBasketTableView.rowHeight = 200.0
        
        /* backButton 커스터마이징 */
        let addButton = UIBarButtonItem(image:UIImage(named:"left"), style:.plain, target:self, action:#selector(ShoppingBasketController.buttonAction(_:)))
        addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
                        
        /*
         Appdelegate를 사용하여, 챗봇을 통해 주문한 정보를 AppDelegate에서 불러오는 작업. 이후 각 Array에 넣어준다.
         */
        let ad = UIApplication.shared.delegate as? AppDelegate
        
        if let numOfProducts = ad?.numOfProducts{
            shoppingBasket_numOfProducts = numOfProducts
        }
        
        if let menuNameArray = ad?.menuNameArray {
            
            shoppingBasket_productName = menuNameArray
            
        }
        if let menuSizeArray = ad?.menuSizeArray {
            
            shoppingBasket_productSize = menuSizeArray
            
        }
        if let menuCountArray = ad?.menuCountArray {
            
            shoppingBasket_productCount = menuCountArray
            
        }
        if let menuEachPriceArray = ad?.menuEachPriceArray {
            
            shoppingBasket_productEachPrice = menuEachPriceArray
        }
        if let menuSugarContent = ad?.menuSugarContent {
            
            shoppingBasket_productSugarContent = menuSugarContent
        }
        if let menuIsWhippedCream = ad?.menuIsWhippedCream {
            
            shoppingBasket_productIsWhippedCream = menuIsWhippedCream
        }
        
      
        
        
    }
    
}
