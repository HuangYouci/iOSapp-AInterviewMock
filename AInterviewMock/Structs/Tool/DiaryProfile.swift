//
//  DiaryProfile.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/30.
//

import Foundation

enum DiaryProfileStatus: Codable, Equatable {
    case notStarted             // 尚未開始
    case prepared               // 準備好了（目前預設這個）
    case inProgress             // 紀錄中
    case generateContent        // 生成逐字稿中
    case completed              // 完成
}

struct DiaryProfile: Identifiable, Codable {
    // 基礎資料
    var id = UUID()
    var date: Date = Date()
    var status: DiaryProfileStatus = .notStarted
    var diaryTitle: String = ""                        // 今日標題
    var diaryPath: String = ""                         // 日記錄音檔
    // 結果
    var diaryContent: String = ""                      // 今日內文（整理過的）
    
}

struct DiaryProfileResponses: Identifiable, Equatable, Codable {
    // 面試聽眾留言
    var id = UUID()                             // ID
    var comment: String                         // 留言內容
}
