//
//  AnalyticsHolder.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/13.
//

import FirebaseAnalytics
import Foundation

class AnalyticsLogger {
    
    static let shared = AnalyticsLogger()
    
    // 轉換日期
    func dateConvertor(_ date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    // 通用
    func logEvent(name: String, parameters: [String: Any]?) {
        #if DEBUG
        print("AnalyticsHolder | Analytics Event: \(name), Parameters: \(parameters ?? [:])")
        #endif
        Analytics.logEvent(name, parameters: parameters)
    }
    
    /// 觀看廣告
    func watchAd(){
        logEvent(name: "AdWatched", parameters: ["date":dateConvertor(Date()),"reward": 5, "logVersion": 2])
    }
    
    /// 購買商品
    /// - Parameters:
    ///    - productId: 商品 ID
    func purchaseItem(productId: String){
        var analyticsItemId = productId
        if productId.hasPrefix("com.huangyouci.AInterviewMock.") {
            analyticsItemId = String(productId.dropFirst("com.huangyouci.AInterviewMock.".count)) // 結果 "iap.coinseta"
        }
        logEvent(name: "purchased", parameters: ["date":dateConvertor(Date()),"itemID":analyticsItemId,"count": 1, "logVersion": 2])
    }
    
    
}
