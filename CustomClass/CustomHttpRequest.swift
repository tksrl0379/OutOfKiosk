//
//  CustomHttpRequest.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/17.
//  Copyright © 2020 OOK. All rights reserved.
//

import Foundation

class CustomHttpRequest{
    
    
    /* php 서버를 통해 mysql 서버와 통신하는 함수 */
    func phpCommunication(url: String, postString: String, handler: @escaping (_ responseString: String)->Void){
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-13-124-57-226.ap-northeast-2.compute.amazonaws.com/\(url)")! as URL)
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        /* URLSession: HTTP 요청을 보내고 받는 핵심 객체 */
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            
            print("response = \(response!)")
            
            /* php server에서 echo한 내용들이 담김 */
            var responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString!)")
            
            /* php서버와 통신 시 NSString에 생기는 개행 제거 */
            responseString = responseString?.trimmingCharacters(in: .newlines) as NSString?
            
            
            handler(responseString! as String)
            
        }
        //실행
        task.resume()
    }
}
