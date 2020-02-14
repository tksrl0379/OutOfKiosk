//
//  ReviewWriteController.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/12.
//  Copyright © 2020 OOK. All rights reserved.
//

import UIKit

class ReviewWriteController : UIViewController{
    
    var storeEnName: String?
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var reviewContents_TextField: UITextField!
    @IBOutlet weak var reviewWrite_Btn: UIButton!
    
    @IBAction func ReviewWrite_Btn(_ sender: Any) {
        let userId = UserDefaults.standard.string(forKey: "id")!
        guard let contents = self.reviewContents_TextField.text else {return}
        phpSendReview(self.storeEnName!, userId, self.floatRatingView.rating, contents){
            response in
            print(response)
            
            DispatchQueue.main.async {
                // 리뷰 전송 완료 후 종료
                self.navigationController?.popViewController(animated: true)
            }
            

        }
    }
    
    
    func phpSendReview(_ storeEnName : String, _ userId: String, _ rating: Double, _ contents: String, handler: @escaping (_ response : String)->Void){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/sendReviewInfo.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "storeEnName=\(storeEnName)&userId=\(userId)&rating=\(rating)&contents=\(contents)"
        
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString!)")
            
            
            //guard let dict = self.convertStringToDictionary(text: responseString as! String) else {return}
            
            handler("전송성공")
        }
        
        //실행
        task.resume()
    }
    
    @objc func buttonAction(_ sender: UIBarButtonItem) {
      self.navigationController?.popViewController(animated: true)
    }
    
    
//    override func accessibilityIncrement() {
//        <#code#>
//    }
//    override func accessibilityDecrement() {
//        <#code#>
//    }
    
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
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "뒤로가기"
        
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
    
    override func viewWillAppear(_ animated: Bool) {
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
