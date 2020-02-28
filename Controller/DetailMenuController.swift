//
//  MenuOfCoffee.swift
//  OutOfKiosk
//
//  Created by jinseo park on 1/6/20.
//  Copyright © 2020 OOK. All rights reserved.
//

/* 이곳에서 사용자가 favorite 설정한 메뉴는 PHP통신으로 데이터를 전송하여 DB에 쏘아서 후에
    FavoriteMenuController에서 받을 수 있다.
 */
import UIKit


/*
 TableViewDataSources의 오버라이딩 함수들. numberOfRowsInSection , cellForRowAt indexPath
 */
class DetailMenuController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //var receivedValueFromBeforeVC : Int?
    
    /*
     willGetCategoryName = PHP통신으로 받은 메뉴의 이름 변수이다.
     willgetCategroyPrice = PHP통신으로 받은 메뉴의 가격(스몰기준) 변수이다.
     favoriteTag = 메뉴가 즐겨찾기가 되었는지를 CafeDetailController에서 비교하여 Label에 표시할 변수이다..
     */
    var menuNameArray : Array<String> = []
    var menuPriceArray : Array<Int> = []
    var favoriteTagArray : Array<String> = []
    
    var storeNameArray : Array<String> = []
    var categoryNumber: Int?
    
    var storeKorName: String?
    var storeEnName: String?
    
    
    @IBOutlet weak var ProductTableView: UITableView!
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* 재사용할 수 있는 cell을 ProductTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = ProductTableView.dequeueReusableCell(withIdentifier: "ProductList", for: indexPath ) as! ProductList
        cell.productName_Label.text = menuNameArray[indexPath.row]
        cell.productPrice_Label.text = String(menuPriceArray[indexPath.row]) + "원"
        cell.productFavorite_Label.text = favoriteTagArray[indexPath.row]
        cell.addFavoriteItem_Btn.layer.cornerRadius = 5
        

        return cell
    }
    
    /*
     아이템을 즐겨찾기 창에 추가시키는 버튼
     php통신이 요구됨,DB Table 만들어야함.(user_ID,menu)전송)
     */
    @IBAction func addFavoriteItem_Btn(_ sender: UIButton) {
        
        /* 현재 cell의 위치를 알기 위해서 사용한다.*/
        let point = sender.convert(CGPoint.zero, to: ProductTableView)
        guard let indexPath = ProductTableView.indexPathForRow(at: point)else{return}
      
        let defaults = UserDefaults.standard
        var favoriteMenuInfoDict = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        //print(favoriteMenuInfoDict)
        
        
        /* 이미 즐겨찾기에 들어 있는 경우 */
        if let _ = favoriteMenuInfoDict![menuNameArray[indexPath.row]]{
            
            print("이미 존재")
            
            favoriteMenuInfoDict?.removeValue(forKey: menuNameArray[indexPath.row])
            
            defaults.set(favoriteMenuInfoDict, forKey: "favoriteMenuInfoDict")
            
            self.favoriteTagArray[indexPath.row] = ""
            self.ProductTableView.reloadRows(at: [indexPath], with: .automatic)

        }else{
            favoriteMenuInfoDict?[self.menuNameArray[indexPath.row]] = self.storeKorName!
            
            defaults.set(favoriteMenuInfoDict, forKey: "favoriteMenuInfoDict")
            
            
            self.favoriteTagArray[indexPath.row] = "즐겨찾기 됨"
            self.ProductTableView.reloadRows(at: [indexPath], with: .automatic)
            
        }
        
        let favoriteMenuInfoDict2 = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        print(favoriteMenuInfoDict2)
        
        
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
        backBtn.addTarget(self, action: #selector(DetailMenuController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        
        
        //addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        
        ProductTableView.delegate = self
        ProductTableView.dataSource = self
        self.ProductTableView.rowHeight = 93.0
        
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* phpGetData는 Escaping closure 사용. 따라서 phpGetData 실행 후 대괄호 안의 코드 실행 */
        CustomHttpRequest().phpCommunication(url: "detailMenu/api/category.php", postString: "category=\(self.categoryNumber!)&storeName=\(self.storeEnName!)"){ //1은 frapuccino의 대한 카테코리 넘버.
            
            responseString in
            
            print(responseString)
            
            let dict = CustomConvert().convertStringToDictionary(text: responseString)!
            
            for i in 0..<dict.count{
                let menuData = dict.allValues[i] as! NSArray
                
                let name = menuData[0] as! String // 이름
                let price = menuData[1] as! Int   // 가격
                
                
                // 서버로부터 스몰 사이즈 메뉴 정보만 받아옴. ( ex) 모카 프라푸치노 스몰, 모카 스무디 스몰 )
                self.menuNameArray.append(name.components(separatedBy: "스몰")[0])
                self.menuPriceArray.append(price)
                self.storeNameArray.append(self.storeKorName!)

                /* TableView를 생성하기 전, UserDefault에 저장된 메뉴이름(favoriteMenuArray) 데이터 값과 카테고리별 메뉴이름배열(willgetCategoryName)을 비교하여 이미 즐겨찾기가 되었는지 아닌지에 따라 즐겨찾기라벨(favoriteTag)에 text값을 설정해 준다.*/

                let defaults = UserDefaults.standard
                var favoriteMenuInfoDict = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]


                /* 일단 ""문자로 초기화를 시킨다. 그 이후, UserDefaults에 저장되어 있는 즐겨찾기 이름이 있다면
                    favoriteTag를 "이미 찜!" 으로 변경한다.
                 */
                for menuName in self.menuNameArray{
                    /* 이곳에서 UserDefault에 있는 문자와 비교하여 실제로 존재하면 favoriteTag의 값을 바꾼다.*/
                    self.favoriteTagArray.append("")
                    for favoriteMenuName in favoriteMenuInfoDict!.keys{
                        if(menuName == favoriteMenuName){
                            
                            self.favoriteTagArray[self.menuNameArray.firstIndex(of: menuName)!] = "즐겨찾기 됨!"
                            break
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.ProductTableView.reloadData()
                }
            }
        }
            
            
        
        
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
    }
    
}
