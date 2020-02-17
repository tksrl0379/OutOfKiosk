//
//  CustomConvert.swift
//  OutOfKiosk
//
//  Created by a1111 on 2020/02/17.
//  Copyright © 2020 OOK. All rights reserved.
//

import Foundation

class CustomConvert{
    
    /* Stiring -> Dictionary */
    func convertStringToDictionary(text: String) -> NSDictionary? {//[String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                /* jsonObject: String type json을 Foundation Object로 바꿔줌 */
                /* Foundation Object: NSArray, NSDictionary, NSNumber, NSDate, NSString or NSNull 로 변환 가능 */
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary //[String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    
    
}
