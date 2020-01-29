//
//  MainController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/01/02.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class MainController : UIViewController{
    
    private var userId: String?
    private var purchaseCount: Float = 0
    
    @IBOutlet weak var title_View: UIView!
    @IBOutlet weak var sub_View: UIView!
    @IBOutlet weak var sub2_View: UIView!
    @IBOutlet weak var progressBar_view: UIView!
    
    @IBOutlet weak var storeSelect_Btn: UIButton!
    @IBOutlet weak var favorite_Btn: UIButton!
    
    
    //@IBOutlet weak var id_Label: UILabel!
    @IBOutlet weak var purchaseCount_Label: UILabel!
    @IBOutlet weak var grade_Label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        navigationItem.hidesBackButton = true // hide button
        //        self.tabBarController?.tabBar.isHidden = false
        //        self.tabBarController?.viewControllers?.remove(at: 0)
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        
        
        title_View.layer.shadowColor = UIColor.black.cgColor
        title_View.layer.shadowOpacity = 0.3
        title_View.layer.shadowOffset = .zero
        title_View.layer.shadowRadius = 4
        title_View.layer.cornerRadius = 5
        
        sub_View.layer.shadowColor = UIColor.black.cgColor
        sub_View.layer.shadowOpacity = 0.3
        sub_View.layer.shadowOffset = .zero
        sub_View.layer.shadowRadius = 4
        sub_View.layer.cornerRadius = 5
        	
        sub2_View.layer.shadowColor = UIColor.black.cgColor
        sub2_View.layer.shadowOpacity = 0.3
        sub2_View.layer.shadowOffset = .zero
        sub2_View.layer.shadowRadius = 4
        sub2_View.layer.cornerRadius = 5
        
        storeSelect_Btn.layer.cornerRadius = 5
        
        favorite_Btn.layer.cornerRadius = 5
        
        
        let cp = CircularProgressView(frame: CGRect(x: 35.5, y: 16.5, width: 120.0, height: 120.0))
        cp.trackColor = UIColor(red: 188.0/255.0, green: 188.0/255.0, blue: 188.0/255.0, alpha: 0.3)
        cp.progressColor = UIColor.systemYellow
        cp.tag = 101
        self.sub2_View.addSubview(cp)
        //cp.center = self.progressBar_view.center
        
        
        
        
        //CircularProgress.trackColor = UIColor.white
        //CircularProgress.progressColor = UIColor.purple
        //CircularProgress.setProgressWithAnimation(duration: 1.0, value: 0.3)
        
        
        userId = UserDefaults.standard.string(forKey: "id")!
        
        //id_Label.text = userId! + " 님은"
        
        self.getPurchaseCount(){
            responseString in
            DispatchQueue.main.async {
                self.purchaseCount_Label.text = (responseString! as String) as String + " / 25"
                self.purchaseCount = Float(responseString! as String)! / 25.0
                self.perform(#selector(self.animateProgress), with: nil, afterDelay: 1.0)
            }
        }
        
        grade_Label.text = "Bronze"
        
        
        
    }
    
    
    @objc func animateProgress() {
        let cP = self.view.viewWithTag(101) as! CircularProgressView
        cP.setProgressWithAnimation(duration: 0.7, value: self.purchaseCount)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addShadow(btn : UIButton){
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 5, height: 5)
        btn.layer.shadowRadius = 0.5
        
        btn.layer.cornerRadius = 1
    }
    
    func getPurchaseCount(handler: @escaping (_ responseStrng : NSString?) -> Void){
        /* php 통신 */
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/getUserInfo.php")! as URL)
        request.httpMethod = "POST"
        
//        let postString = "name=\(self.name!)&size=\(self.size!)&count=\(self.count!)"
        let postString = "id=\(self.userId!)"
        print(self.userId!)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            /* php서버와 통신 시 NSString에 생기는 개행 제거 */
            responseString = responseString?.trimmingCharacters(in: .newlines) as NSString?
            
            print("responseString = \(responseString!)")
            
            /* UI 변경은 메인쓰레드에서만 가능 */
            
            //self.speechAndText(textResponse + " 총 \(responseString!)원입니다. 주문하시겠습니까 ?")
            handler(responseString)
            
        }
        task.resume()
    }
    
    
    
    
    
    /* 카페 버튼 */
    @IBAction func storeSelect_Btn(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "StoreListController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    /* 즐겨찾기 버튼 */
    @IBAction func favoriteMenu_Btn(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteMenuController"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
