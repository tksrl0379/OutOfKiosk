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

class DetailMenuController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - Property
    // MARK: Custom Property
    var menuNameArray : Array<String> = []
    var menuPriceArray : Array<Int> = []
    var favoriteTagArray : Array<String> = []
    
    var storeNameArray : Array<String> = []
    var categoryNumber: Int? // 1: 첫 번째 메뉴, 2: 두 번째 메뉴 ...
    
    var storeKorName: String?
    var storeEnName: String?
    
    var menuKorName: String?
    
    // MARK: IBOutlet
    @IBOutlet weak var ProductTableView: UITableView!
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeNavigationItem()
        self.initializeTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setUpTableView()
    }
    
    
    // MARK: - Method
    // MARK: Table method
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
    
    // MARK: Custom Method
    
    func initializeNavigationItem() {
        
        self.navigationItem.title = menuKorName

        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = self.storeKorName! + "뒤로가기"
    }
    
    func initializeTableView() {
        
        ProductTableView.delegate = self
        ProductTableView.dataSource = self
        self.ProductTableView.rowHeight = 93.0
    }
    
    func setUpTableView() {
        
        CustomHttpRequest().phpCommunication(url: "detailMenu/api/category.php", postString: "category=\(self.categoryNumber!)&storeName=\(self.storeEnName!)") {
            responseString in
                        
            let dict = CustomConvert().convertStringToDictionary(text: responseString)!
            
            for i in 0..<dict.count{
                let menuData = dict.allValues[i] as! NSArray
                
                let name = menuData[0] as! String // 이름
                let price = menuData[1] as! Int   // 가격
                
                
                // 서버로부터 스몰 사이즈 메뉴 정보만 받아옴. ( ex) 모카 프라푸치노 스몰, 모카 스무디 스몰 )
                self.menuNameArray.append(name.components(separatedBy: "스몰")[0])
                self.menuPriceArray.append(price)
                self.storeNameArray.append(self.storeKorName!)
                
                // FavoriteTag Array 초기화: cell 마다 찜 여부 표시
                let favoriteMenuInfoDict = UserDefaults.standard.object(forKey: "favoriteMenuInfoDict") as? [String:String]

                for menuName in self.menuNameArray {

                    self.favoriteTagArray.append("")
                    for favoriteMenuName in favoriteMenuInfoDict!.keys {
                        if menuName == favoriteMenuName {
                            
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
    }
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        
      self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: IBAction
    
    @IBAction func addFavoriteItem_Btn(_ sender: UIButton) {
        
        // 터치한 cell을 알아내기 위해 사용
        let point = sender.convert(CGPoint.zero, to: ProductTableView)
        guard let indexPath = ProductTableView.indexPathForRow(at: point) else { return }
      
        let defaults = UserDefaults.standard
        var favoriteMenuInfoDict = defaults.object(forKey: "favoriteMenuInfoDict") as? [String:String]
        
        // 이미 찜한 경우
        if let _ = favoriteMenuInfoDict![menuNameArray[indexPath.row]] {
            
            favoriteMenuInfoDict?.removeValue(forKey: menuNameArray[indexPath.row])
            
            defaults.set(favoriteMenuInfoDict, forKey: "favoriteMenuInfoDict")
            
            self.favoriteTagArray[indexPath.row] = ""
            self.ProductTableView.reloadRows(at: [indexPath], with: .automatic)

        // 아직 찜 하지 않은 경우
        } else {
        
            favoriteMenuInfoDict?[self.menuNameArray[indexPath.row]] = self.storeKorName!
            
            defaults.set(favoriteMenuInfoDict, forKey: "favoriteMenuInfoDict")
            
            self.favoriteTagArray[indexPath.row] = "찜하기 됨"
            self.ProductTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
}
