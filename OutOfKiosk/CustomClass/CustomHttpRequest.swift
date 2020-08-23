//
//  CustomHttpRequest.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/17.
//  Copyright © 2020 OOK. All rights reserved.
//

import Foundation

class CustomHttpRequest{
    
    // MARK: Custom Method
    
    // PHP 서버와 HTTP 통신
    func phpCommunication(url: String, postString: String, handler: @escaping (_ responseString: String)->Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-54-180-97-136.ap-northeast-2.compute.amazonaws.com/\(url)")! as URL)
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        print("보낸 parameter:", postString)
        
        // URLSession: HTTP 요청을 보내고 받는 핵심 객체
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let data = data else {
                print("수신 data 에러 발생1")
                return
            }
            
            
            // PHP Server 에서 반환한 내용 출력
            var returnValue: String
            
            if let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                returnValue = responseString as String
            }else {
                print("수신 data 에러 발생2")
                return
            }
            
            // 서버로부터 받은 내용에서 생기는 개행 제거
            returnValue = returnValue.trimmingCharacters(in: .newlines)
            print("응답: \(returnValue)")
            
            handler(returnValue)
        }
        
        // 실행
        task.resume()
    }
}
