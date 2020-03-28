//
//  ReviewController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/06.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class ReviewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var reviewWrite_Btn: UIButton!
    
    var storeEnName : String?
    var storeKorName: String?
    var reviewUserId: Array<String>? = []
    var reviewContents: Array<String>? = []
    var reviewTime: Array<String>? = []
    var reviewRating: Array<Double>? = []
    
    @IBOutlet weak var reviewTableView: UITableView!

    
    @IBAction func reviewWriteButton(_ sender: Any) {
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewWriteController") as? ReviewWriteController else { return }
        
        rvc.storeEnName = self.storeEnName
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewUserId!.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//      재사용할 수 있는 cell을 ProductTableView에 넣는다는 뜻. UITableViewCell을 반환하기 때문에 Reviewlist로 다운캐스팅
        
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "ReviewList", for: indexPath ) as! ReviewList
        
        cell.reviewUserId_Label.text = reviewUserId![indexPath.row] + "님"
        cell.reviewContents_Label.text = reviewContents![indexPath.row]
        cell.reviewTime_Label.text = reviewTime![indexPath.row]
        
        // 별점
        // Reset float rating view's background color
        cell.floatRatingView.backgroundColor = UIColor.clear

        //cell.floatRatingView.delegate = self
        cell.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        cell.floatRatingView.type = .halfRatings
        cell.floatRatingView.editable = false
        cell.floatRatingView.rating = reviewRating![indexPath.row]
        
        

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
        
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = self.storeKorName! + "로 가는 뒤로가기"
        
        /* 테두리 둥글게 만들기 */
        reviewWrite_Btn.layer.cornerRadius = 5
        reviewWrite_Btn.layer.borderWidth = 0.2
        reviewWrite_Btn.layer.borderColor = UIColor.gray.cgColor
        
        reviewWrite_Btn.layer.shadowColor = UIColor.black.cgColor
        reviewWrite_Btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        reviewWrite_Btn.layer.shadowRadius = 3
        reviewWrite_Btn.layer.shadowOpacity = 0.3
        
        
        // 테이블
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        // tableView의 계산된 높이 값은 68이다. 즉 Default Height이다.
        reviewTableView.estimatedRowHeight = 100.0
        // tableView의 rowHeight는 유동적일 수 있다
        reviewTableView.rowHeight = UITableView.automaticDimension
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* TableView 제목 사이즈 동적 조절 */
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "리뷰하기"
        
        /* 리뷰 정보 받아오기 */
        reviewUserId?.removeAll()
        reviewContents?.removeAll()
        reviewTime?.removeAll()
        reviewRating?.removeAll()
        
        CustomHttpRequest().phpCommunication(url: "getReviewInfo.php", postString: "storeEnName=\(storeEnName!)"){
            responseString in
            
            guard let dict = CustomConvert().convertStringToDictionary(text: responseString as! String) else {return}
        
            for i in 1...dict.count{
                let dict = dict[String(i)] as! NSDictionary
                self.reviewUserId?.append(dict["userId"] as! String)
                self.reviewContents?.append(dict["contents"] as! String)
                self.reviewTime?.append(dict["time"] as! String)
                self.reviewRating?.append(dict["rating"] as! Double)
                
            }
            
            DispatchQueue.main.async {
                self.reviewTableView.reloadData()
            }
        }
        
        /* navigationbar 투명 설정 */
        //self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //self.navigationController!.navigationBar.shadowImage = UIImage()
        
    }
    
    
}


extension ReviewController: FloatRatingViewDelegate {

    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        //liveLabel.text = String(format: "%.2f", self.floatRatingView.rating)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        //updatedLabel.text = String(format: "%.2f", self.floatRatingView.rating)
    }
    
}

