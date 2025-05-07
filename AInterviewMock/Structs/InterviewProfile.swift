//
//  InterviewType.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/5.
//

import Foundation

struct InterviewProfile: Identifiable, Codable {
    // 面試類型（在初始設置時有預設模板）
    var id = UUID()                                     // ID
    var templateName: String                            // 檔案名稱
    var templateDescription: String                     // 檔案敘述
    var templateImage: String                           // 檔案圖示
    var templatePrompt: String                          // 檔案題詞（模板題詞）
    var preQuestions: [InterviewProfilePreQuestions]    // 類型細節問題
    var filesPath: [String]                             // 參考資料路徑
    // 面試問題
    var questions: [InterviewProfileQuestions]          // 面試當中的問題
    var questionNumbers: Int                            // 面試問題數量
    var questionFormalStyle: Double                     // 正式程度
    var questionStrictStyle: Double                     // 嚴格程度
    // 面試資料
    var cost: Int = 0                                   // 花費
    var status: Int = 0                                 // 0 剛開始設置／1 回答完面試類型問題
                                                        // 2 進行中（生成完問題後產生）
    var date: Date = Date()                             // 建立日期
    var feedbacks: [String]                             // 回饋（ＡＩ）
    var overallRating: Double                           // 總體評價（ＡＩ）
}

struct InterviewProfilePreQuestions: Identifiable, Equatable, Codable {
    // 面試類型細節問題
    var id = UUID()                             // ID
    var question: String                        // 題目問題
    var answer: String                          // 題目回答
    var required: Bool = true                   // 是否必填
}

struct InterviewProfileQuestions: Identifiable, Equatable, Codable {
    // 面試當中問題
    var id = UUID()                             // ID
    var question: String                        // 題目問題（ＡＩ）
    var answer: String                          // 使用者回答（語音轉文字）
    var score: Double                           // 評分（ＡＩ）
    var feedback: String                        // 反饋（ＡＩ）
}

struct InterviewProfileFeedbacks: Identifiable, Codable {
    // 結束的評價
    var id = UUID()                             // ID
    var content: String                         // 評價內容
    var positive: Bool                          // 是否為正向
    var suggestion: String                      // 改善方向
}

// Constants

struct DefaultInterviewType {
    static let college: InterviewProfile = InterviewProfile(
        // 以下是您提供的資料
        templateName: "大學面試",
        templateDescription: "針對大學面試做準備",
        templateImage: "graduationcap.fill",
        templatePrompt: "你是一間大學面試的面試官，請你依照以下資訊提供面試的題目，題目不可重複或過於相似且需符合資訊要求，除了參考資訊以及可能的附件之外，亦可搜尋目標校系的資料進行綜合出題：",
        preQuestions: [
            InterviewProfilePreQuestions(question: "目標的學校是什麼？", answer: "", required: true),
            InterviewProfilePreQuestions(question: "目標的科系是什麼？", answer: "", required: true),
            InterviewProfilePreQuestions(question: "該科系有要求自我介紹嗎，有的話有什麼條件嗎？", answer: "", required: false),
            InterviewProfilePreQuestions(question: "據你所知，該科系偏重詢問什麼方向的題目？", answer: "", required: false),
            InterviewProfilePreQuestions(question: "該科系在面試有什麼其他的特別要求嗎？", answer: "", required: false)
        ],
        filesPath: [],
        questions: [],
        questionNumbers: 5,
        questionFormalStyle: 0.5,
        questionStrictStyle: 0.5,
        feedbacks: [],
        overallRating: 0.0
    )
}
