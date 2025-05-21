//
//  SpeechProfile.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//

import Foundation

enum SpeechProfileStatus: Int, Codable, Equatable {
    case notStarted = 0  // 尚未開始
    case prepared = 1
    case inProgress = 2
    case analyzing = 3
    case completed = 4 // 已經完成
}

struct SpeechProfile: Codable, Identifiable {
    // 演講類型（在初始設置時有預設模板）
    var id = UUID()
    var templateName: String
    var templateDescription: String
    var templateImage: String
    var templatePrompt: String
    var preQuestions: [SpeechProfilePreQuestions]
    var filesPath: [String] = []
    // 演講內容
    var speechContent: String = ""
    var speechAudioPath: String = ""
    // AI 提問
    var askedQuestions: [SpeechProfileAskedQuestions] = []
    var askedQuestionNumbers: Int = 0
    // 回饋
    var cost: Int = 0                                   // 花費
    var status: SpeechProfileStatus = .notStarted       // 狀態
    var date: Date = Date()
    var feedback: String = ""
    var feedbacks: [SpeechProfileFeedbacks] = []
    var overallRating: Int = 0
}

struct SpeechProfilePreQuestions: Identifiable, Equatable, Codable {
    // 演講類型細節問題
    var id = UUID()                             // ID
    var question: String                        // 題目問題
    var answer: String                          // 題目回答
    var required: Bool = true                   // 是否必填
}

struct SpeechProfileAskedQuestions: Identifiable, Equatable, Codable {
    // 演講 AI 提問問題
    var id = UUID()                             // ID
    var question: String                        // 題目問題（ＡＩ）
    var answerAudioPath: String                 // 回答語音路徑
    var answer: String                          // 使用者回答（語音轉文字）
    var score: Int                              // 評分（ＡＩ）
    var feedback: String                        // 反饋（ＡＩ）
}

struct SpeechProfileFeedbacks: Identifiable, Codable {
    // 結束的評價
    var id = UUID()                             // ID
    var content: String                         // 評價內容
    var positive: Bool                          // 是否為正向
    var suggestion: String                      // 改善方向
}

// Constant

struct DefaultSpeechProfile {
    // template
    static var general: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_general_templateName", comment: "Template name for general speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_general_templateDescription", comment: "Template description for general speech profile"),
            templateImage: "quote.bubble.fill",
            templatePrompt: NSLocalizedString("SpeechProfile_general_templatePrompt", comment: "Template prompt for general speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_general_preQuestion_topic", comment: "Pre-question about the topic of the speech"),
                    answer: "",
                    required: true
                )
            ]
        )
    }
    static var academic: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_academic_templateName", comment: "Template name for academic speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_academic_templateDescription", comment: "Template description for academic speech profile"),
            templateImage: "graduationcap.fill",
            templatePrompt: NSLocalizedString("SpeechProfile_academic_templatePrompt", comment: "Template prompt for academic speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_academic_preQuestion_topic", comment: "Pre-question about the speech topic for academic profile"),
                    answer: "",
                    required: true
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_academic_preQuestion_audience", comment: "Pre-question about the target audience for academic profile"),
                    answer: "",
                    required: false
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_academic_preQuestion_coreConcept", comment: "Pre-question about the core concept to convey for academic profile"),
                    answer: "",
                    required: false
                )
            ]
        )
    }
    static var selfIntro: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_selfIntro_templateName", comment: "Template name for self-introduction speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_selfIntro_templateDescription", comment: "Template description for self-introduction speech profile"),
            templateImage: "person.crop.circle.fill",
            templatePrompt: NSLocalizedString("SpeechProfile_selfIntro_templatePrompt", comment: "Template prompt for self-introduction speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_selfIntro_preQuestion_who", comment: "Pre-question about who you are"),
                    answer: "",
                    required: true
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_selfIntro_preQuestion_specialty", comment: "Pre-question about your specialty or interest"),
                    answer: "",
                    required: false
                )
            ]
        )
    }
    static var inspirational: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_inspirational_templateName", comment: "Template name for inspirational/TED-style speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_inspirational_templateDescription", comment: "Template description for inspirational/TED-style speech profile"),
            templateImage: "sparkles",
            templatePrompt: NSLocalizedString("SpeechProfile_inspirational_templatePrompt", comment: "Template prompt for inspirational/TED-style speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_inspirational_preQuestion_idea", comment: "Pre-question about the idea worth spreading"),
                    answer: "",
                    required: true
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_inspirational_preQuestion_personalStory", comment: "Pre-question about a personal story or insight"),
                    answer: "",
                    required: false
                )
            ]
        )
    }
    static var instructional: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_instructional_templateName", comment: "Template name for instructional/teaching speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_instructional_templateDescription", comment: "Template description for instructional/teaching speech profile"),
            templateImage: "book.fill",
            templatePrompt: NSLocalizedString("SpeechProfile_instructional_templatePrompt", comment: "Template prompt for instructional/teaching speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_instructional_preQuestion_topic", comment: "Pre-question about the topic to teach"),
                    answer: "",
                    required: true
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_instructional_preQuestion_keyPoints", comment: "Pre-question about key concepts or steps"),
                    answer: "",
                    required: false
                )
            ]
        )
    }
    static var persuasive: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_persuasive_templateName", comment: "Template name for persuasive speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_persuasive_templateDescription", comment: "Template description for persuasive speech profile"),
            templateImage: "megaphone.fill",
            templatePrompt: NSLocalizedString("SpeechProfile_persuasive_templatePrompt", comment: "Template prompt for persuasive speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_persuasive_preQuestion_goal", comment: "Pre-question about the goal of persuasion"),
                    answer: "",
                    required: true
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_persuasive_preQuestion_reason", comment: "Pre-question about the reason or argument"),
                    answer: "",
                    required: false
                )
            ]
        )
    }
    static var ceremonial: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_ceremonial_templateName", comment: "Template name for ceremonial/occasional speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_ceremonial_templateDescription", comment: "Template description for ceremonial/occasional speech profile"),
            templateImage: "rosette",
            templatePrompt: NSLocalizedString("SpeechProfile_ceremonial_templatePrompt", comment: "Template prompt for ceremonial/occasional speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_ceremonial_preQuestion_event", comment: "Pre-question about the occasion or event"),
                    answer: "",
                    required: true
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_ceremonial_preQuestion_message", comment: "Pre-question about the core message or blessing"),
                    answer: "",
                    required: false
                )
            ]
        )
    }
    static var demonstrative: SpeechProfile {
        return SpeechProfile(
            templateName: NSLocalizedString("SpeechProfile_demonstrative_templateName", comment: "Template name for demonstrative speech profile"),
            templateDescription: NSLocalizedString("SpeechProfile_demonstrative_templateDescription", comment: "Template description for demonstrative speech profile"),
            templateImage: "hammer.fill",
            templatePrompt: NSLocalizedString("SpeechProfile_demonstrative_templatePrompt", comment: "Template prompt for demonstrative speech profile"),
            preQuestions: [
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_demonstrative_preQuestion_subject", comment: "Pre-question about what is being demonstrated"),
                    answer: "",
                    required: true
                ),
                SpeechProfilePreQuestions(
                    question: NSLocalizedString("SpeechProfile_demonstrative_preQuestion_steps", comment: "Pre-question about steps or how it works"),
                    answer: "",
                    required: false
                )
            ]
        )
    }

    // test
    static let test = SpeechProfile(
        templateName: "學術演講",
        templateDescription: "模擬大學課堂中進行的研究簡報，包含背景、方法、結果與結論。",
        templateImage: "graduationcap.fill", // 對應 Image Asset 名稱
        templatePrompt: "你現在是一位學生，正在進行一場學術簡報，請根據提供的資訊開始模擬。",
        preQuestions: [
            SpeechProfilePreQuestions(
                question: "這場演講的主題是什麼？",
                answer: "我這場演講的主題是有關生成式 AI 在教育中的應用。"
            ),
            SpeechProfilePreQuestions(
                question: "你的目標聽眾是誰？",
                answer: "主要是教授與同學，具有基礎的人工智慧背景。"
            ),
            SpeechProfilePreQuestions(
                question: "你希望傳達的核心概念是什麼？",
                answer: "我希望讓大家了解生成式 AI 的潛力與在課堂互動上的實際效益。"
            )
        ],
        filesPath: [
            "/Users/youqi/Documents/Slides/GenAIEducation.pdf"
        ],
        speechContent: """
這次演講分為四個部分：研究動機、研究方法、實驗結果與討論。首先，我們發現學生在課堂上面對複雜知識時，經常缺乏足夠的即時支援。為了改善這個問題，我們設計了一套整合 GPT 模型的即時問答平台，並在兩個學期的課堂上進行實驗。
""",
        speechAudioPath: "", askedQuestions: [
            SpeechProfileAskedQuestions(
                question: "你提到的實驗有對照組嗎？如何確保實驗結果可信？",
                answerAudioPath: "/recordings/q1.m4a",
                answer: "是的，我們設計了一組使用 AI 輔助平台的班級，並與沒有使用平台的班級進行比較，並控制了講師與課程內容。",
                score: 4,
                feedback: "你提到了控制變因，回答完整清楚，但可再補充實驗人數與統計方法會更完整。"
            ),
            SpeechProfileAskedQuestions(
                question: "你提到學生互動有提升，有具體數據嗎？",
                answerAudioPath: "/recordings/q2.m4a",
                answer: "有的，使用平台的班級平均每堂課提問次數為 12 次，是未使用組的三倍。",
                score: 5,
                feedback: "很棒，有明確數據支撐，說明清楚且具說服力。"
            )
        ],
        askedQuestionNumbers: 2,
        status: .completed,
        feedback: "總體來說，講得挺好",
        feedbacks: [
            SpeechProfileFeedbacks(
                content: "你的結構清楚、語速適中，很容易理解。",
                positive: true,
                suggestion: "下次可以加入更多圖表輔助說明。"
            ),
            SpeechProfileFeedbacks(
                content: "問答部分略顯緊張，有時表達不夠精確。",
                positive: false,
                suggestion: "可以多練習即席反應，尤其針對關鍵數據要能快速回答。"
            )
        ],
        overallRating: 4
    )
}

