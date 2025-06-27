//
//  InterviewTool.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/23.
//

import FirebaseVertexAI
import Foundation

class InterviewTool: ToolBase {
    
    override var toolName: String {
        return "Interview"
    }
    
    // MARK: - 生成面試題目
    
    func generateQuestions(i: InterviewProfile) async -> InterviewProfile? {
        
        var ri = i
        
        let schema: Schema = .array(items: .string())
        
        var prompt: [any Part] = []
        
        var textprompt: String = """
        你是一個專門生成面試問題的模擬面試考官。
        你的唯一任務是根據以下提供的資訊，生成指定數量的面試問題。
        輸出格式要求：你必須嚴格地只輸出一個 JSON 陣列，其中每個元素都是一個字串（一個面試問題）。
        絕對不要包含任何 JSON 陣列以外的文字、開頭問候語、解釋、說明或題號。
        
        # 參考資訊
        ## 題目語言
        請依照使用者「答」以及「備審資料」的主要語言，判斷應由何種語言生成題目。
        
        ## 身份設定
        \(i.templatePrompt)
        
        ## 以下是面試前詢問使用者的問題，請參考「問」以及「答」來設計題目，且不要被錯誤的使用者答帶跑。
        """
        
        for item in i.preQuestions {
            if !(item.answer.isEmpty){
                textprompt.append("""
                    問：\(item.question)
                    答：\(item.answer)
                
                """)
            }
        }
        
        textprompt.append("""
        ## 題目數量
            出 \(i.questionNumbers) 題面試問題。
            請直接輸出題目，不需要其他說明，也不用新增題號。
        ## 題目問題調整
            - 正式程度（題目的口氣與氣氛，0.5 一般，1.0 正式，0.0 輕鬆）為 \(i.questionFormalStyle)，
            - 嚴格程度（問題的深度與難度，0.5 一般，1.0 正式，0.0 輕鬆）為 \(i.questionStrictStyle)
        """)
        
        if (i.filesPath.count > 0){
            textprompt.append("""
            ## 附件
                使用者提供了 \(i.filesPath.count) 個附件，這些是面試者的附件，請參考附件內容與之前所提的面試準則（請僅依據附件有且實際需要的內容進行參考）。
            """)
        }
        
        textprompt.append("""
        ## 注意事項
        *   請以「繁體中文」輸出回應。
        """)
        
        prompt.append(TextPart(textprompt))
        
        for filePath in i.filesPath {
            if filePath.lowercased().hasSuffix(".pdf") {
                let url = URL(fileURLWithPath: filePath)
                do {
                    let pdfData = try Data(contentsOf: url)
                    // 將 PDF 數據添加到 parts 陣列中
                    prompt.append(InlineDataPart(data: pdfData, mimeType: "application/pdf"))
                    print("GeminiService | Successfully loaded PDF from \(filePath)")
                } catch {
                    print("GeminiService | Error loading PDF from \(filePath): \(error)")
                }
            }
        }
        
        guard let response = await generateResponseFromSchema(schema: schema, prompt: prompt) else {
            print("\(toolName) | 獲取回應失敗")
            return nil
        }
        
        guard let responseText = response.text,
              let jsonData = responseText.data(using: .utf8) else {
            print("\(toolName) | 獲取回應失敗")
            return nil
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode([String].self, from: jsonData)
            
            let interviewQuestions = decodedResponse.map { q in
                return InterviewProfileQuestions(
                    question: q
                )
            }
            
            print("\(toolName) | 成功解析 \(interviewQuestions.count) 個問題")
            ri.questions = interviewQuestions
            ri.status = .inProgress
            return ri
        } catch {
            print("\(toolName) | 發生錯誤 \(error)")
            return nil
        }
        
    }
    
    func generateResults(i: InterviewProfile) async -> InterviewProfile? {
        
        struct responseStruct: Codable {
            let name: String
            let questions: [responseQuestionsStruct]
            let feedback: String
            let feedbacks: [responseFeedbacksStruct]
            let overallRating: Int
        }
        
        struct responseQuestionsStruct: Codable {
            let id: String
            let score: Int
            let feedback: String
        }
        
        struct responseFeedbacksStruct: Codable {
            let content: String
            let positive: Bool
            let suggestion: String
        }
        
        var ri = i
        
        let schema: Schema = .object(
            properties: [
                "name": .string(description: "為這個面試檔案取一個簡短的標題名字"),
                "questions": .array(
                    items: .object(properties: [
                        "id": .string(description: "該問題的 UUID 字串，用於精確匹配"),
                        "score": .integer(description: "該問題的得分（0到10分）"),
                        "feedback": .string(description: "針對該問題回答的具體文字回饋")
                    ]), description: "針對每個問題的評估列表"
                ),
                "feedback": .string(description: "整體評語，代表對該面試的總結與感想回饋"),
                "feedbacks": .array(
                    items: .object(properties: [
                        "content": .string(description: "一個主題式回饋的內容描述（簡單的形容狀況或事件）"),
                        "positive": .boolean(description: "此項主題回饋是否為正面（true/false）"),
                        "suggestion": .string(description: "針對此主題的改進建議或強化說明")
                    ]), description: "針對整體面試表現的主題式回饋列表"
                ),
                "overallRating": .integer(description: "整體面試評分（0到100分），代表成功機率")
            ]
        )
        
        var prompt: [any Part] = []
        
        var textprompt = """
        你是一位資深的模擬面試教練與評估員。你的任務是分析以下模擬面試的過程與結果，並提供詳細的回饋。
        
        # 參考資訊
        ## 題目語言
        請依照使用者「答」以及「備審資料」的主要語言，判斷應由何種語言生成回應。
        
        ## 身份設定
        \(i.templatePrompt)
        
        ## 背景問題問答
        此項目為模擬面試前，系統詢問使用者的背景資料。使用者會「回答」：
        """
        
        for item in i.preQuestions {
            if !item.answer.isEmpty {
                textprompt.append("""
                - 問題: \(item.question)
                - 回答: \(item.answer)
                
                """)
            }
        }
        
        if !i.filesPath.isEmpty {
            textprompt.append("""
            ## 使用者提供的參考文件
            在評估可能與文件內容相關的回答時，請務必參考附件的內容。
            
            """)
            for filePath in i.filesPath {
                let fileURL = URL(fileURLWithPath: filePath)
                if let fileData = try? Data(contentsOf: fileURL) {
                    prompt.append(InlineDataPart(data: fileData, mimeType: "application/pdf"))
                    print("GeminiService | 已載入參考文件: \(filePath)")
                } else {
                    print("GeminiService | 警告: 無法載入或判斷參考文件 MIME 類型: \(filePath)")
                }
            }
        }
        
        textprompt.append("""
        ## 面試問題與使用者回答
        
        """)
        
        for questionData in i.questions {
            textprompt.append("""
            **問題 ID: \(questionData.id.uuidString):** \(questionData.question)
            **使用者文字回答:** \(questionData.answer)
            
            """)
        }
        
        textprompt.append("""
        # 評估任務
        請嚴格依照 Schema 指定的 JSON 格式提供您的評估報告。不要在 JSON 結構之外包含任何其他文字。
        
        ## 注意事項
        
        *   `overallRating` 應為 0 到 100 分的綜合評分，代表基於本次模擬面試，應試者準備充分度以及成功錄取/通過的可能性，請務必嚴謹評估。
            這代表面試的錄取機率，如果使用者表現優異，應給予 80 分以上分數，只有在表現極差才給予 40 分以下的分數。
        *   請分析文字回答與可能的檔案以進行全面評估。
        *   請以「繁體中文」輸出回應。
        """)
        
        prompt.insert(TextPart(textprompt), at: 0)
        
        guard let response = await generateResponseFromSchema(schema: schema, prompt: prompt) else {
            print("\(toolName) | 獲取回應失敗")
            return nil
        }
        
        guard let responseText = response.text,
              let jsonData = responseText.data(using: .utf8) else {
            print("\(toolName) | 獲取回應失敗")
            return nil
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(responseStruct.self, from: jsonData)
            
            ri.name = decodedResponse.name
            
            for q in decodedResponse.questions {
                if let qIndex = ri.questions.firstIndex(where: {$0.id.uuidString == q.id}) {
                    ri.questions[qIndex].score = q.score
                    ri.questions[qIndex].feedback = q.feedback
                    print("\(toolName) | 已更新問題 (ID: \(q.id)) 的分數: \(q.score), 回饋: \(q.feedback.prefix(50))...")
                } else {
                    print("\(toolName) | 警告: 在 InterviewProfile 中找不到對應的問題 ID: \(q.id)")
                }
            }
            
            ri.feedback = decodedResponse.feedback
            
            for f in decodedResponse.feedbacks {
                ri.feedbacks.append(InterviewProfileFeedbacks(content: f.content, positive: f.positive, suggestion: f.suggestion))
            }
            
            ri.overallRating = decodedResponse.overallRating
            
            ri.status = .completed
            return ri
        } catch {
            print("\(toolName) | 發生錯誤 \(error)")
            return nil
        }
        
    }
    
}
