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
import Alamofire


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
    var willgetCategroyName : Array<String>!
    var willgetCategroyPrice : Array<Int>!
    var favoriteTag : Array<String> = []
        
    
    @IBOutlet weak var ProductTableView: UITableView!
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return willgetCategroyName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* 재사용할 수 있는 cell을 ProductTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = ProductTableView.dequeueReusableCell(withIdentifier: "ProductList", for: indexPath ) as! ProductList
        cell.productName_Label.text = willgetCategroyName[indexPath.row]
        cell.productPrice_Label.text = String(willgetCategroyPrice[indexPath.row]) + "원"
        cell.productFavorite_Label.text = favoriteTag[indexPath.row]
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
      
        /* 성공 시, UserDefualts 에 즐겨찾기 메뉴 추가
         UserDefaults 특성 상, append될 수 가없어서 데이터를 뽑은 후, favoriteMenu 오브젝트를 삭제 한 후에,
         배열에 메뉴이름 추가 후, 다시 오브젝트를 세팅한다.
         */
        
        /*
         수정부분
         1. 중복으로 array에 저장이 된다. => 완료
         2. 추가 하는 동시에 lable.text가 바뀌었으면 좋겠다. => 완료
         ->label.text를 바꾸는 동시에 버튼을 hidden처리 한다. 그 이후에 label.text가 추가됨으로 변경 되면
         다시 들어와도 변경된 상태로 유지가 되어야한다. 이것은 tableView cell에서 처리하기.
         */
        let defaults = UserDefaults.standard
        var favoriteMenuArray = defaults.stringArray(forKey: "favoriteMenuArray") ?? [String]()
        
        /* 이미 추가된 메뉴가 있을경우 중복 추가를 방지 하기위해 만들어 놓은 if stmt*/
        if (favoriteMenuArray.contains(self.willgetCategroyName[indexPath.row])){
            print("Already contained")
        }else{
            
            UserDefaults.standard.removeObject(forKey: "favoriteMenuArray")
            favoriteMenuArray.append(self.willgetCategroyName[indexPath.row])
            print("favorite menu : ", favoriteMenuArray,"\n") //print test
            UserDefaults.standard.set(favoriteMenuArray, forKey: "favoriteMenuArray")
            self.favoriteTag[indexPath.row] = "즐겨찾기 됨"
            self.ProductTableView.reloadRows(at: [indexPath], with: .automatic)
             
        }

        /*
         PHP 추가 연동기능 동기화 제거 -> 어플 자체에 저장하는 방식으로 변경함.
         let userId = UserDefaults.standard.string(forKey: "id")!
         let parameters: Parameters = [
             "name" : willgetCategroyName[indexPath.row],
             "userID" : userId
         ]
        let URL_ORDER = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/favoriteMenu/api/addFavoriteMenu.php"
        //Sending http post request
        Alamofire.request(URL_ORDER, method: .post, parameters: parameters).responseString
            {
                response in
                print("응답",response)
        }*/
        
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
        
        
        
        /* TableView를 생성하기 전, UserDefault에 저장된 메뉴이름(favoriteMenuArray) 데이터 값과 카테고리별 메뉴이름배열(willgetCategoryName)을 비교하여 이미 즐겨찾기가 되었는지 아닌지에 따라 즐겨찾기라벨(favoriteTag)에 text값을 설정해 준다.*/

        let defaults = UserDefaults.standard
        let favoriteMenuArray = defaults.stringArray(forKey: "favoriteMenuArray") ?? [String]()
        

        /* 일단 ""문자로 초기화를 시킨다. 그 이후, UserDefaults에 저장되어 있는 즐겨찾기 이름이 있다면
            favoriteTag를 "이미 찜!" 으로 변경한다.
         */
        for productName in willgetCategroyName{
            /* 이곳에서 UserDefault에 있는 문자와 비교하여 실제로 존재하면 favoriteTag의 값을 바꾼다.*/
            favoriteTag.append("")
            for favoriteMenuName in favoriteMenuArray{
                if(productName == favoriteMenuName){
//                    print("match!!", productName, favoriteMenuName)
                    favoriteTag[willgetCategroyName.firstIndex(of: productName)!] = "즐겨찾기 됨!"
                    break
                }
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
    }
    
}
