//
//  DiaryStruct.swift
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
    // MARK: - DiaryProfile
    // 基礎資料
    var id = UUID()
    var date: Date = Date()
    var status: DiaryProfileStatus = .notStarted
    var diaryTitle: String = ""                        // 今日標題
    var diaryPath: String = ""                         // 日記錄音檔
    // 結果
    var diaryContent: String = ""                      // 今日內文（整理過的）
    var diaryResponse: [DiaryProfileResponses] = []    // 觀眾回覆
    
    // MARK: - 初始化
    /// 創建實例
    init(){}
    /// 自訂解碼策略 當解碼器解碼失敗後，嘗試的操作（如果沒有在此自訂，其餘欄位失敗，就會解析失敗）
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 必要欄位
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        status = try container.decode(DiaryProfileStatus.self, forKey: .status)
        diaryTitle = try container.decode(String.self, forKey: .diaryTitle)
        diaryPath = try container.decode(String.self, forKey: .diaryPath)
        diaryContent = try container.decode(String.self, forKey: .diaryContent)

        // 選填欄位
        diaryResponse = (try? container.decode([DiaryProfileResponses].self, forKey: .diaryResponse)) ?? []
    }
}

struct DiaryProfileResponses: Identifiable, Equatable, Codable {
    // 面試聽眾留言
    var id = UUID()                             // ID
    var name: String                            // 留言標題
    var comment: String                         // 留言內容
}
