//
//  ReviewController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/06.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class ReviewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var storeEnName : String?
    var reviewUserId: Array<String>? = []
    var reviewContents: Array<String>? = []
    var reviewTime: Array<String>? = []
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    
    @IBAction func reviewWriteButton(_ sender: Any) {
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewWriteController") as? ReviewWriteController else { return }
        
        rvc.storeEnName = self.storeEnName
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewUserId!.count
//        return willgetCategroyName.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         재사용할 수 있는 cell을 ProductTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Reviewlist로 다운캐스팅
        
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "ReviewList", for: indexPath ) as! ReviewList
        
        cell.reviewUserId_Label.text = reviewUserId![indexPath.row] + "님"
        cell.reviewContents_Label.text = reviewContents![indexPath.row]
        cell.reviewTime_Label.text = reviewTime![indexPath.row]
        
        
        

        return cell
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
        backBtn.addTarget(self, action: #selector(ReviewController.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        
        let addButton = UIBarButtonItem(customView: backBtn)
        let currWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        
        
        
        //addButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        self.reviewTableView.rowHeight = 174.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
    }
    
    
    
}


