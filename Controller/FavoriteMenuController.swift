//
//  FavoriteMenuController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

/* PHP통신으로 Data를 받는다. 각 유저마다 원하는 정보의 Data를 받을것이다.*/
import Alamofire
import UIKit

class FavoriteMenuController : UIViewController, UITableViewDelegate , UITableViewDataSource{
    
    
    //    var willgetFavoriteMenuName = Array<String>!
    
    //각 유저가 즐겨찾기한 목록의 item을 Array들을 여기에 넣을 것이다.
    var willgetFavoriteMenuName = [""]
    
    @IBOutlet weak var FavoriteMenuTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //        print("갯수는 ", favoriteProduct.count)
        
        return willgetFavoriteMenuName.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* 재사용할 수 있는 cell을 FavoriteMenuTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Storelist로 다운캐스팅 */
        let cell = FavoriteMenuTableView.dequeueReusableCell(withIdentifier: "FavoriteList", for: indexPath ) as! FavoriteList
        
        /* StoreList 클래스(Cell Class)에 등록한 프로퍼티 이용 가능 */
        cell.favoriteProductName_Label.text = willgetFavoriteMenuName[indexPath.row]
        cell.orderFavoriteProduct_Btn.layer.cornerRadius = 5
        cell.deleteFavoriteProduct_Btn.layer.cornerRadius = 5
        
        return cell
        
    }
    
    
    /* 즐겨찾기 추가한 아이템을 주문(챗봇음성안내)로 바로가게 하기.*/
    @IBAction func orderFavoriteProduct_Btn(_ sender: UIButton) {
        
        /* 해당 Cell의 이름을 얻기위해 indexPath를 구한다.*/
        let point = sender.convert(CGPoint.zero, to: FavoriteMenuTableView)
        guard let indexPath = FavoriteMenuTableView.indexPathForRow(at: point)else{return}
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DialogFlowPopUpController") as? DialogFlowPopUpController else {
            return}
        
        /* Cell의 이름을 DialogFlow에 전송한다. */
        rvc.favoriteMenuName = willgetFavoriteMenuName[indexPath.row]
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    
    
    @IBAction func deleteFavoriteProduct_Btn(_ sender: UIButton) {
        
        let point = sender.convert(CGPoint.zero, to: FavoriteMenuTableView)
        
        guard let indexPath = FavoriteMenuTableView.indexPathForRow(at: point)else{return}
        
        
        /*
            Todo : PHP 통신으로 실제로 즐겨찾기 추가 된 아이템을 삭제하기.
            userID와 Name을 전송해야함.
         
        */
        
        let userId = UserDefaults.standard.string(forKey: "id")!
        
        /* 해당 테이블 뷰의 이름을 얻기위해 indexPath.row를 사용함.*/
        let parameters: Parameters=[
            "name" : willgetFavoriteMenuName[indexPath.row],
            "userID" : userId
        ]
        /* php 서버 위치 */
        let URL_DELETE_FAVORITE = "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/favoriteMenu/api/deleteFavoriteMenu.php"
        //Sending http post request
        Alamofire.request(URL_DELETE_FAVORITE, method: .post, parameters: parameters).responseString
            {
                response in
                print("응답",response)
                
        }
        
        
        
        /* willgetFavoriteMenuName = 현재 즐겨찾기목록에 있는 메뉴들의 이름 배열.*/
        willgetFavoriteMenuName.remove(at: indexPath.row)

        FavoriteMenuTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    
    
    
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Delegate 위임하지 않으면 절대로 표출되지 않는다.
         dataSource = DataSource는 데이터를 받아 뷰를 그려주는 역할
         delegate =  어떤 행동에 대한 "동작"을 제시
         출처: https://zeddios.tistory.com/137 [ZeddiOS]
         */
        
        FavoriteMenuTableView.delegate=self
        FavoriteMenuTableView.dataSource=self
        self.FavoriteMenuTableView.rowHeight = 100.0
        
        
        /* backButton 커스터마이징 */
        let addButton = UIBarButtonItem(image:UIImage(named:"left"), style:.plain, target:self, action:#selector(FavoriteMenuController.buttonAction(_:)))
        addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        
    }
    
    
    
}
