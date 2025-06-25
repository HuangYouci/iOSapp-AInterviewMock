//
//  InterviewProfile.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/5.
//

import Foundation

enum InterviewProfileStatus: Codable, Equatable {
    case notStarted             // 尚未開始（模板）
    case prepared               // 已準備好（設定完成）
    case generateQuestions
    case inProgress             // 正在面試中
    case generateResults
    case completed              // 完成（完整）
}

struct InterviewProfile: Identifiable, Codable {
    // 基礎資料
    var id = UUID()
    var date: Date = Date()
    var status: InterviewProfileStatus = .notStarted
    var name: String = ""                                  // 完成後的名稱
    // 模板：在初始設置時有預設模板
    var templateName: String                               // 檔案名稱
    var templateDescription: String                        // 檔案敘述
    var templateImage: String                              // 檔案圖示
    var templatePrompt: String                             // 檔案題詞（模板題詞）
    var preQuestions: [InterviewProfilePreQuestions] = []  // 類型細節問題
    var filesPath: [String] = []                           // 參考資料路徑
    // 問題
    var questions: [InterviewProfileQuestions] = []        // 面試當中的問題
    var questionNumbers: Int = 5                           // 面試問題數量
    var questionFormalStyle: Double = 0.5                  // 正式程度
    var questionStrictStyle: Double = 0.5                  // 嚴格程度
    // 結果
    var feedback: String = ""
    var feedbacks: [InterviewProfileFeedbacks] = []
    var overallRating: Int = 0
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
    var answerAudioPath: String = ""            // 回答語音路徑
    var answer: String = ""                     // 使用者回答（語音轉文字）
    var score: Int = 0                          // 評分（ＡＩ）
    var feedback: String = ""                   // 反饋（ＡＩ）
}

struct InterviewProfileFeedbacks: Identifiable, Codable {
    // 結束的評價
    var id = UUID()                             // ID
    var content: String                         // 評價內容
    var positive: Bool                          // 是否為正向
    var suggestion: String                      // 改善方向
}

// Constants

struct DefaultInterviewProfile {
    // template
    static var college: InterviewProfile {
            return InterviewProfile(
                id: UUID(),
                templateName: "大學面試",
                templateDescription: "針對大學面試做準備", // 使用圖片中的 "針對大學面試做準備"
                templateImage: "graduationcap.fill",
                templatePrompt: "你是一間大學面試的面試官，請你依照以下資訊提供面試的題目，題目不可重複或過於相似且需符合要求，除了參考資訊以及可能的附件之外，亦可搜尋目標校系的資料進行綜合出題。",
                preQuestions: [
                    InterviewProfilePreQuestions(question: "目標的學校是什麼？", answer: "", required: true),
                    InterviewProfilePreQuestions(question: "目標的科系是什麼？", answer: "", required: true),
                    InterviewProfilePreQuestions(question: "該科系有要求自我介紹嗎？有詳細的自我介紹要求嗎？", answer: "", required: false),
                    InterviewProfilePreQuestions(question: "該科系偏重詢問哪些方向的題目？", answer: "", required: false),
                    InterviewProfilePreQuestions(question: "該科系對於面試有什麼其他的特別要求嗎？", answer: "", required: false)
                ]
            )
        }
    static var jobGeneral: InterviewProfile {
        return InterviewProfile(
            id: UUID(),
            templateName: "工作面試（通用）",
            templateDescription: "準備一般性的工作面試",
            templateImage: "briefcase.fill",
            templatePrompt: "你是一位公司的人力資源面試官或部門主管，請根據以下應聘者提供的職位和公司信息，以及可能的附件（如履歷），設計專業的面試問題，以評估其是否適合該職位。",
            preQuestions: [
                InterviewProfilePreQuestions(question: "目標公司名稱是什麼？", answer: "", required: true),
                InterviewProfilePreQuestions(question: "申請的職位名稱是什麼？", answer: "", required: true),
                InterviewProfilePreQuestions(question: "該職位描述中，你認為最重要的幾項要求或職責是什麼？", answer: "", required: false),
                InterviewProfilePreQuestions(question: "你為什麼對這間公司感興趣？", answer: "", required: false),
                InterviewProfilePreQuestions(question: "你認為自己為什麼適合這個職位？", answer: "", required: false)
            ],
            questionNumbers: 10,
            questionFormalStyle: 0.7,
            questionStrictStyle: 0.6
        )
    }
    static var internship: InterviewProfile {
        return InterviewProfile(
            id: UUID(),
            templateName: "實習面試",
            templateDescription: "為獲得實習機會做準備",
            templateImage: "studentdesk",
            templatePrompt: "你正在面試一位申請實習的學生或初級候選人。請設計問題來評估他們的學習動機、基礎技能、對該領域的熱情以及團隊合作潛力。",
            preQuestions: [
                InterviewProfilePreQuestions(question: "這個實習是在哪個領域？", answer: "", required: true),
                InterviewProfilePreQuestions(question: "提供實習的公司名稱是什麼？", answer: "", required: false),
                InterviewProfilePreQuestions(question: "你申請這個特定實習的動機是什麼？", answer: "", required: true),
                InterviewProfilePreQuestions(question: "你有哪些相關的技能或修過的課程？", answer: "", required: false),
                InterviewProfilePreQuestions(question: "你希望從這次實習中學到或達成什麼目標？", answer: "", required: false)
            ]
        )
    }
}
