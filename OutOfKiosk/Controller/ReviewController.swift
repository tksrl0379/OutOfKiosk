//
//  ReviewController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/06.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class ReviewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - Propery
    // MARK: Custom Property
    var storeEnName : String?
    var storeKorName: String?
    var reviewUserId: Array<String> = []
    var reviewContents: Array<String> = []
    var reviewTime: Array<String> = []
    var reviewRating: Array<Double> = []
    
    // MARK: IBOutlet
    @IBOutlet weak var reviewWrite_Btn: UIButton!
    @IBOutlet weak var reviewTableView: UITableView!
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeNavigationItem()
        self.initializeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setUpReviewContents()
    }
    
    
    // MARK: - Method
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reviewUserId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "ReviewList", for: indexPath ) as! ReviewList
        
        cell.reviewUserId_Label.text = reviewUserId[indexPath.row] + "님"
        cell.reviewContents_Label.text = reviewContents[indexPath.row]
        cell.reviewTime_Label.text = reviewTime[indexPath.row]
        
        // 별점
        cell.floatRatingView.backgroundColor = UIColor.clear
        
        cell.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        cell.floatRatingView.type = .halfRatings
        cell.floatRatingView.editable = false
        cell.floatRatingView.rating = reviewRating[indexPath.row]
        
        return cell
    }
    
    // MARK: Custom Method
    func initializeNavigationItem() {
        self.navigationItem.title = "리뷰하기"
        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = self.storeKorName! + " 뒤로가기"
    }
    
    func initializeView() {
        
        // 테두리 둥글게 만들기
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
        //reviewTableView.estimatedRowHeight = 100.0
        reviewTableView.rowHeight = UITableView.automaticDimension // 테이블의 rowHeight 유동적으로 설정
    }
    
    func setUpReviewContents() {
        
        // 리뷰 정보 받아오기
        reviewUserId.removeAll()
        reviewContents.removeAll()
        reviewTime.removeAll()
        reviewRating.removeAll()
        
        CustomHttpRequest().phpCommunication(url: "getReviewInfo.php", postString: "storeEnName=\(storeEnName!)") {
            responseString in
            
            guard let dict = CustomConvert().convertStringToDictionary(text: responseString ) else { return }
            
            for i in 1...dict.count {
                let dict = dict[String(i)] as! NSDictionary
                self.reviewUserId.append(dict["userId"] as! String)
                self.reviewContents.append(dict["contents"] as! String)
                self.reviewTime.append(dict["time"] as! String)
                self.reviewRating.append(dict["rating"] as! Double)
            }
            
            DispatchQueue.main.async {
                self.reviewTableView.reloadData()
            }
        }
    }
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: IBAction
    @IBAction func reviewWriteButton(_ sender: Any) {
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewWriteController") as? ReviewWriteController else { return }
        
        rvc.storeEnName = self.storeEnName
        self.navigationController?.pushViewController(rvc, animated: true)
    }
    
}




