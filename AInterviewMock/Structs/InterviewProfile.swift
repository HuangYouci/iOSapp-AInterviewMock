//
//  InterviewProfile.swift
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
                                                        // 2 生成完問題，開始作答／3 全部作答完畢等待生成／4 完成
    var date: Date = Date()                             // 建立日期
    var feedbacks: [InterviewProfileFeedbacks] = []     // 回饋（ＡＩ）
    var overallRating: Int                              // 總體評價（ＡＩ）
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
    var answerAudioPath: String                 // 回答語音路徑
    var answer: String                          // 使用者回答（語音轉文字）
    var score: Int                              // 評分（ＡＩ）
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

struct DefaultInterviewProfile {
    // template
    static var college: InterviewProfile {
            return InterviewProfile(
                id: UUID(),
                templateName: NSLocalizedString("InterviewProfile_college_templateName", comment: "Name of the college interview template"),
                templateDescription: NSLocalizedString("InterviewProfile_college_templateDescription", comment: "Description for the college interview template"),
                templateImage: "graduationcap.fill",
                templatePrompt: NSLocalizedString("InterviewProfile_college_templatePrompt", comment: "Base prompt for AI for college interview template. This might be long and could also be a key if parts of it need to change by language, but for now, localizing the whole string."),
                preQuestions: [
                    InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_college_preQuestion1_school", comment: "Pre-interview question: Target school?"), answer: "", required: true),
                    InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_college_preQuestion2_department", comment: "Pre-interview question: Target department?"), answer: "", required: true),
                    InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_college_preQuestion3_selfIntro", comment: "Pre-interview question: Self-introduction requirements?"), answer: "", required: false),
                    InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_college_preQuestion4_focusTopics", comment: "Pre-interview question: Department's typical question focus?"), answer: "", required: false),
                    InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_college_preQuestion5_specialReqs", comment: "Pre-interview question: Other special interview requirements?"), answer: "", required: false)
                ],
                filesPath: [],
                questions: [],
                questionNumbers: 5,
                questionFormalStyle: 0.5,
                questionStrictStyle: 0.5,
                feedbacks: [],
                overallRating: 0
            )
        }
    static var jobGeneral: InterviewProfile {
        return InterviewProfile(
            id: UUID(),
            templateName: NSLocalizedString("InterviewProfile_jobGeneral_templateName", comment: "Name of the general job interview template"),
            templateDescription: NSLocalizedString("InterviewProfile_jobGeneral_templateDescription", comment: "Description for the general job interview template"),
            templateImage: "briefcase.fill",
            templatePrompt: NSLocalizedString("InterviewProfile_jobGeneral_templatePrompt", comment: "Base prompt for AI for general job interview template"),
            preQuestions: [
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_jobGeneral_preQuestion1_company", comment: "Pre-interview question: Target company?"), answer: "", required: true),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_jobGeneral_preQuestion2_position", comment: "Pre-interview question: Target position/role?"), answer: "", required: true),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_jobGeneral_preQuestion3_jobDescription", comment: "Pre-interview question: Key requirements or responsibilities from the job description?"), answer: "", required: false),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_jobGeneral_preQuestion4_whyCompany", comment: "Pre-interview question: Why are you interested in this company?"), answer: "", required: false),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_jobGeneral_preQuestion5_whyPosition", comment: "Pre-interview question: Why are you suitable for this position?"), answer: "", required: false)
            ],
            filesPath: [],
            questions: [],
            questionNumbers: 10,
            questionFormalStyle: 0.7,
            questionStrictStyle: 0.6,
            feedbacks: [],
            overallRating: 0
        )
    }
    static var internship: InterviewProfile {
        return InterviewProfile(
            id: UUID(),
            templateName: NSLocalizedString("InterviewProfile_internship_templateName", comment: "Name of the internship interview template"),
            templateDescription: NSLocalizedString("InterviewProfile_internship_templateDescription", comment: "Description for the internship interview template"),
            templateImage: "studentdesk",
            templatePrompt: NSLocalizedString("InterviewProfile_internship_templatePrompt", comment: "Base prompt for AI for internship interview template"),
            preQuestions: [
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_internship_preQuestion1_field", comment: "Pre-interview question: What field is the internship in?"), answer: "", required: true),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_internship_preQuestion2_company", comment: "Pre-interview question: Name of the company offering the internship?"), answer: "", required: false),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_internship_preQuestion3_motivation", comment: "Pre-interview question: What motivates you to apply for this specific internship?"), answer: "", required: true),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_internship_preQuestion4_skills", comment: "Pre-interview question: What relevant skills or coursework do you have?"), answer: "", required: false),
                InterviewProfilePreQuestions(question: NSLocalizedString("InterviewProfile_internship_preQuestion5_learningGoals", comment: "Pre-interview question: What do you hope to learn or achieve from this internship?"), answer: "", required: false)
            ],
            filesPath: [],
            questions: [],
            questionNumbers: 5,
            questionFormalStyle: 0.5,
            questionStrictStyle: 0.4,
            feedbacks: [],
            overallRating: 0
        )
    }
    // test
    static let test: InterviewProfile = InterviewProfile(
           id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E29")!, // 固定 UUID 以便於測試
           templateName: "綜合職能測試",
           templateDescription: "用於展示AI面試回饋功能的完整範例",
           templateImage: "checkmark.seal.fill", // 更改圖示表示已完成
           templatePrompt: "你是一位資深的人力資源專家，負責評估應聘者的綜合職能。請根據以下應聘者提供的背景資訊以及他們在面試中的回答，進行全面的評估。",
           preQuestions: [
               InterviewProfilePreQuestions(question: "您認為自己最大的優勢是什麼？", answer: "我認為我最大的優勢是解決問題的能力和快速學習新事物。", required: true),
               InterviewProfilePreQuestions(question: "您對我們這個行業有什麼了解？", answer: "我對貴行業的發展趨勢進行過一些研究，特別是關於技術創新和市場競爭方面。", required: true),
               InterviewProfilePreQuestions(question: "您的職業規劃是什麼？", answer: "我希望在未來3-5年內成為一名資深工程師，並有機會參與更具挑戰性的專案。", required: false),
               InterviewProfilePreQuestions(question: "您期望的薪資範圍是多少？", answer: "根據市場行情和我的經驗，我期望的年薪範圍是 X 到 Y 之間。", required: false)
           ],
           filesPath: [
               "/path/to/fake_resume_for_testing.pdf",
               "/path/to/fake_cover_letter_for_testing.pdf"
           ],
           questions: [
               InterviewProfileQuestions(
                   id: UUID(uuidString: "A1B2C3D4-E5F6-7890-1234-567890ABCDEF")!, // 固定問題ID
                   question: "請您談談過去一次成功解決複雜問題的經驗。",
                   answerAudioPath: "/caches/test_audio_answer_1.m4a",
                   answer: "在之前的專案中，我們遇到了一個關鍵的技術瓶頸，影響了產品的交付進度。我主動組織了團隊進行腦力激盪，並提出了一個創新的解決方案，最終成功克服了困難，按時完成了專案。這個過程中，我學會了如何在高壓下保持冷靜和有效地協調資源。",
                   score: 88, // 模擬 AI 評分
                   feedback: "回答結構清晰，STAR 原則運用得當，突出了您在解決問題中的主動性和領導力。語氣自信，表達流暢。可以考慮再具體說明一下您提出的“創新解決方案”的細節，會更有說服力。" // 模擬 AI 回饋
               ),
               InterviewProfileQuestions(
                   id: UUID(uuidString: "B2C3D4E5-F6A7-8901-2345-67890ABCDEF0")!,
                   question: "您如何處理團隊合作中的意見分歧？",
                   answerAudioPath: "/caches/test_audio_answer_2.m4a",
                   answer: "我認為開放的溝通和相互尊重是解決意見分歧的關鍵。我會先仔細聆聽各方的觀點，然後嘗試找到共同點，並尋求一個對團隊最有利的折衷方案。如果無法達成共識，我會建議尋求上級或更有經驗的同事的指導。",
                   score: 92,
                   feedback: "非常好！您強調了溝通和尊重，並提出了尋求共識和適時尋求指導的策略，這在團隊合作中非常重要。表達清晰，邏輯性強。"
               ),
               InterviewProfileQuestions(
                   id: UUID(uuidString: "C3D4E5F6-A7B8-9012-3456-7890ABCDEF01")!,
                   question: "面對快速變化的市場環境，您如何保持自己的競爭力？",
                   answerAudioPath: "/caches/test_audio_answer_3.m4a",
                   answer: "我會持續學習新的技術和行業知識，例如閱讀專業書籍、參加線上課程和行業研討會。我也樂於接受新的挑戰，並從實踐中不斷提升自己。",
                   score: 85,
                   feedback: "展現了良好的學習態度和主動性。建議可以舉一個具體例子，說明您是如何透過學習新技能來應對變化的，這樣能讓回答更具體。"
               ),
               InterviewProfileQuestions(
                   id: UUID(uuidString: "D4E5F6A7-B8C9-0123-4567-890ABCDEF012")!,
                   question: "請描述一個您設定並達成具挑戰性目標的例子。",
                   answerAudioPath: "/caches/test_audio_answer_4.m4a",
                   answer: "我曾經為自己設定了一個在三個月內掌握一門新程式語言的目標。為此，我制定了詳細的學習計劃，每天堅持投入時間學習和練習，並積極尋找實踐機會。最終，我成功地掌握了這門語言，並將其應用到實際工作中。",
                   score: 90,
                   feedback: "目標明確，行動計劃清晰，結果導向。很好地展示了您的自律性和執行力。錄音中語速稍快，可以稍微放慢一點，讓聽者更容易吸收信息。"
               ),
               InterviewProfileQuestions(
                   id: UUID(uuidString: "E5F6A7B8-C9D0-1234-5678-90ABCDEF0123")!,
                   question: "在壓力下，您如何有效地管理時間和任務？",
                   answerAudioPath: "/caches/test_audio_answer_5.m4a",
                   answer: "我會使用任務清單和優先級排序來管理我的工作。對於重要的任務，我會設定明確的截止日期，並分解成更小的步驟。同時，我也會注意保持工作與生活的平衡，透過運動和冥想來釋放壓力。",
                   score: 87,
                   feedback: "時間管理方法得當，並提到了壓力管理，這是一個全面的回答。可以進一步思考，當多個高優先級任務同時出現時，您會如何權衡。"
               ),
               // 為了簡潔，省略後續5個問題的詳細模擬回饋，但您可以按此模式填充
               InterviewProfileQuestions(
                   id: UUID(), question: "您對我們公司的企業文化有什麼看法？",
                   answerAudioPath: "/caches/test_audio_answer_6.m4a", answer: "我對貴公司強調創新和團隊合作的企業文化印象深刻...",
                   score: 82, feedback: "對公司文化有一定的了解，但可以更深入地結合自身特質說明如何融入。"
               ),
               InterviewProfileQuestions(
                   id: UUID(), question: "如果您的項目進展不如預期，您會採取哪些措施？",
                   answerAudioPath: "/caches/test_audio_answer_7.m4a", answer: "首先，我會重新評估項目的目標和現狀...",
                   score: 89, feedback: "解決問題的思路清晰，有條理。"
               ),
               InterviewProfileQuestions(
                   id: UUID(), question: "請分享一個您主動學習並應用新技能的例子。",
                   answerAudioPath: "/caches/test_audio_answer_8.m4a", answer: "最近，我注意到數據分析在我們行業的重要性日益增加...",
                   score: 91, feedback: "展現了良好的學習主動性和應用能力，例子具體。"
               ),
               InterviewProfileQuestions(
                   id: UUID(), question: "您認為在未來五年，這個行業最重要的趨勢是什麼？",
                   answerAudioPath: "/caches/test_audio_answer_9.m4a", answer: "我認為人工智能和自動化將是未來五年最重要的趨勢...",
                   score: 86, feedback: "對行業趨勢有一定洞察，可以再結合個人如何應對這些趨勢來談。"
               ),
               InterviewProfileQuestions(
                   id: UUID(), question: "您有什麼問題想問我們嗎？",
                   answerAudioPath: "/caches/test_audio_answer_10.m4a", answer: "我想了解一下團隊目前面臨的最大挑戰是什麼？以及公司如何支持員工的職業發展和技能提升？",
                   score: 93, feedback: "提出的問題有深度，表現出對公司和職位的積極興趣。"
               )
           ],
           questionNumbers: 10,
           questionFormalStyle: 0.6,
           questionStrictStyle: 0.7,
           cost: 1500, // 假設生成回饋產生了一些花費 (例如 Token 數)
           status: 4, // 4: 完成 (AI 已生成回饋)
           date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, // 假設是昨天完成的
           feedbacks: [ // 模擬 AI 生成的整體主題式回饋
               InterviewProfileFeedbacks(
                   id: UUID(),
                   content: "應聘者在問題解決能力和學習主動性方面表現突出。",
                   positive: true,
                   suggestion: "可以多準備一些能夠量化成果的案例，以增強說服力。"
               ),
               InterviewProfileFeedbacks(
                   id: UUID(),
                   content: "溝通表達能力良好，思路清晰。",
                   positive: true,
                   suggestion: "在回答部分問題時，語速可以適當放緩，給予聽者更多思考和吸收的時間。"
               ),
               InterviewProfileFeedbacks(
                   id: UUID(),
                   content: "對行業和公司有一定了解，但可以更深入。",
                   positive: false,
                   suggestion: "建議在面試前對公司的最新動態、產品以及競爭對手做更細緻的研究，並思考如何將自身優勢與公司需求結合。"
               )
           ],
           overallRating: 88 // 模擬 AI 生成的總體評價 (0-100)
       )
}
