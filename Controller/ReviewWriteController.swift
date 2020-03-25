//
//  ReviewWriteController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/12.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class ReviewWriteController : UIViewController, UITextFieldDelegate{
    
    var storeEnName: String?
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var reviewContents_TextField: UITextField!
    @IBOutlet weak var reviewWrite_Btn: UIButton!
    
    @IBAction func ReviewWrite_Btn(_ sender: Any) {
        let userId = UserDefaults.standard.string(forKey: "id")!
        guard let contents = self.reviewContents_TextField.text else {return}
        
        CustomHttpRequest().phpCommunication(url: "sendReviewInfo.php", postString: "storeEnName=\(self.storeEnName!)&userId=\(userId)&rating=\(self.floatRatingView.rating)&contents=\(contents)"){
            responseString in
            
            DispatchQueue.main.async {
                // 리뷰 전송 완료 후 종료
                self.navigationController?.popViewController(animated: true)
            }
    
        }
    }
    
    
    
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // textField의 상태를 포기 -> 키보드 내려감
            textField.resignFirstResponder()
            return true
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 아이폰 키보드 올라가고 내려가기 설정*/
        reviewContents_TextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        
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
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "리뷰 목록으로 가는 뒤로가기"
        
        /* 테두리 둥글게 만들기 */
        reviewWrite_Btn.layer.cornerRadius = 5
        reviewWrite_Btn.layer.borderWidth = 0.2
        reviewWrite_Btn.layer.borderColor = UIColor.gray.cgColor
        
        
        // 별표 평점
        // Reset float rating view's background color
        floatRatingView.backgroundColor = UIColor.clear

        /** Note: With the exception of contentMode, type and delegate,
         all properties can be set directly in Interface Builder **/
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        floatRatingView.type = .halfRatings
        
        floatRatingView.editable = true
    }
    
    @objc func changeProgressTitleView(_ notification: NSNotification){
        floatRatingView.accessibilityLabel = "별점" + String(notification.userInfo!["rating"] as! Double) + "개"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(changeProgressTitleView(_:)), name: NSNotification.Name("rating"), object: nil)

        
        /* navigationbar 투명 설정 */
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }
    
}

extension ReviewWriteController: FloatRatingViewDelegate {

    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        //liveLabel.text = String(format: "%.2f", self.floatRatingView.rating)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        //updatedLabel.text = String(format: "%.2f", self.floatRatingView.rating)
    }
    
}
