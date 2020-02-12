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
    
    @IBAction func ReviewWrite_Btn(_ sender: Any) {
        guard let contents = self.reviewContents_TextField.text else {return}
        phpSendReview(self.storeEnName!, self.floatRatingView.rating, contents){
            response in
            print(response)
            
            DispatchQueue.main.async {
                // 리뷰 전송 완료 후 종료
                self.navigationController?.popViewController(animated: true)
            }
            

        }
    }
    
    
    func phpSendReview(_ storeEnName : String, _ rating: Double, _ contents: String, handler: @escaping (_ response : String)->Void){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/sendReviewInfo.php")! as URL)
        request.httpMethod = "POST"
        
        let postString = "storeEnName=\(storeEnName)&rating=\(rating)&contents=\(contents)"
        
        
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reset float rating view's background color
        floatRatingView.backgroundColor = UIColor.clear

        /** Note: With the exception of contentMode, type and delegate,
         all properties can be set directly in Interface Builder **/
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        floatRatingView.type = .halfRatings
        
        
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
