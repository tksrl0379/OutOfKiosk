//
//  ReviewWriteController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/12.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class ReviewWriteController : UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
    // MARK: - Propery
    // MARK: Custom Property
    var storeEnName: String?
    
    // MARK: IBOutlet
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var reviewContents_TextView: UITextView!
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeKeyboard()
        self.initializeNavigationItem()
        self.initializeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(changeProgressTitleView(_:)), name: NSNotification.Name("rating"), object: nil)
    }
    
    // MARK: - Method
    // MARK: Custom Method
    
    func initializeKeyboard() {
        
        // 키보드 올라가고 내려가기 설정
        reviewContents_TextView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initializeNavigationItem() {
        
        self.navigationItem.title = "리뷰 작성하기"
        
        // 좌측 버튼
        self.navigationItem.leftBarButtonItem = BackButton(controller: self)
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "리뷰 목록으로 가는 뒤로가기"
        
        // 우측 버튼
        let writeBtn = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 30, height: 30))
        writeBtn.setImage(UIImage(systemName: "pencil.and.ellipsis.rectangle"), for: .normal)
        writeBtn.tintColor = UIColor.black
        writeBtn.addTarget(self, action: #selector(ReviewWriteController.writeAction(_:)), for: UIControl.Event.touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: writeBtn)
        self.navigationItem.rightBarButtonItem?.accessibilityLabel = "리뷰 제출하기"

    }
    
    func initializeView() {
        
        // 별표 평점
        floatRatingView.delegate = self
        
        floatRatingView.backgroundColor = UIColor.clear
        floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        floatRatingView.type = .halfRatings
        
        floatRatingView.editable = true
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
        self.view.frame.origin.y = -150
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        
        self.view.frame.origin.y = 0
    }
    
    @objc func changeProgressTitleView(_ notification: NSNotification){
        floatRatingView.accessibilityLabel = "별점" + String(notification.userInfo!["rating"] as! Double) + "개"
    }
    
    @objc func writeAction(_ sender: UIBarButtonItem) {
        
        let userId = UserDefaults.standard.string(forKey: "id")!
        guard let contents = self.reviewContents_TextView.text else { return }
        
        CustomHttpRequest().phpCommunication(url: "sendReviewInfo.php", postString: "storeEnName=\(self.storeEnName!)&userId=\(userId)&rating=\(self.floatRatingView.rating)&contents=\(contents)"){
            responseString in
            
            DispatchQueue.main.async {
                // 리뷰 전송 완료 후 종료
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension ReviewWriteController: FloatRatingViewDelegate {
    
    // MARK: FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
    }
    
}
