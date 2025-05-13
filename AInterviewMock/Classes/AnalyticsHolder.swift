//
//  AnalyticsHolder.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/13.
//

import FirebaseAnalytics
import Foundation

class AnalyticsHolder {
    
    static let shared = AnalyticsHolder()
    
    private func logEvent(name: String, parameters: [String: Any]?) {
        #if DEBUG
        print("AnalyticsHolder | Analytics Event: \(name), Parameters: \(parameters ?? [:])")
        #endif
        Analytics.logEvent(name, parameters: parameters)
    }
    
    /// 觀看廣告
    func watchAd(){
        logEvent(name: "AdWatched", parameters: ["Reward": 5])
    }
    
    /// 購買商品
    /// - Parameters:
    ///    - productId: 商品 ID
    func purchaseItem(productId: String){
        var analyticsItemId = productId
        if productId.hasPrefix("com.huangyouci.AInterviewMock.") {
            analyticsItemId = String(productId.dropFirst("com.huangyouci.AInterviewMock.".count)) // 結果 "iap.coinseta"
        }
        logEvent(name: "purchased", parameters: [analyticsItemId: 1])
    }
    
    /// VIP 用戶換取代幣
    /// - Parameters:
    ///    - Count: 換取的代幣
    ///    - AfterTotal: 換取之後總代幣
    func premiumGetCoins(count: Int, afterTotal: Int){
        logEvent(name: "premiumGetCoins", parameters: ["count": count, "afterTotal": afterTotal])
    }
    
    /// 面試題目生成
    /// - Parameters:
    ///    - templateName: 模板名稱
    ///    - token: Token 數量
    ///    - generatedNum: 生成題目總數
    ///    - filesNum: 檔案數量
    ///    - modFormalLevel: 正式程度
    ///    - modStrictLevel: 嚴格程度
    func generatedQuestions(templateName: String, token: Int, generatedNum: Int, filesNum: Int, modFormalLevel: Int, modStrictLevel: Int){
        logEvent(name: "generatedQuestions", parameters: ["templateName": templateName, "token": token, "generatedNum": generatedNum, "filesNum": filesNum, "modFormalLevel": modFormalLevel, "modStrictLevel": modStrictLevel])
    }
    
    /// 分析結果生成
    /// - Parameters:
    ///    - templateName: 模板名稱
    ///    - token: Token 數量
    ///    - generatedNum: 生成題目總數
    ///    - filesNum: 檔案數量
    ///    - modFormalLevel: 正式程度
    ///    - modStrictLevel: 嚴格程度
    ///    - overallScore: 總分數
    func generatedAnalysis(templateName: String, generatedNum: Int, filesNum: Int, modFormalLevel: Int, modStrictLevel: Int, overallScore: Int){
        logEvent(name: "generatedAnalysis", parameters: ["templateName": templateName, "generatedNum": generatedNum, "filesNum": filesNum, "modFormalLevel": modFormalLevel, "modStrictLevel": modStrictLevel, "overallScore": overallScore])
    }
}
