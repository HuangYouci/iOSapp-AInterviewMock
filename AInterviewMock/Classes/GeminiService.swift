//
//  VertexAI.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import Foundation
import FirebaseVertexAI

class GeminiService {
    static let shared = GeminiService()
    
    let model = VertexAI.vertexAI().generativeModel(modelName: "gemini-2.0-flash-lite-001")
    
    func generateText(from prompt: String) async -> String? {
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                print("GeminiService | Gemini 回覆：\(text)")
                return text
            } else {
                print("GeminiService | 沒有回傳文字內容")
                return nil
            }
        } catch {
            print("GeminiService | 發生錯誤：\(error)")
            return nil
        }
    }
    
    // MARK: - 模擬面試
    
    // 生成面試題目
    
    func generateInterviewQuestions(from i: InterviewProfile) async -> [InterviewProfileQuestions] {
        let schema: Schema = .array(items: .string())
        let model = VertexAI.vertexAI().generativeModel(
          modelName: "gemini-2.0-flash-lite-001",
          generationConfig: GenerationConfig(
            responseMIMEType: "application/json",
            responseSchema: schema
          )
        )
        
        // 題詞
        var prompt: [any Part] = []
        
        // 文字題詞設計
        var textPart = """
        你是一個專門生成面試問題的模擬面試考官。
        你的唯一任務是根據以下提供的資訊，生成指定數量的面試問題。
        輸出格式要求：你必須嚴格地只輸出一個 JSON 陣列，其中每個元素都是一個字串（一個面試問題）。
        絕對不要包含任何 JSON 陣列以外的文字、開頭問候語、解釋、說明或題號。
        
        * 參考資訊
        ** 以下是你的身份設定
        \(i.templatePrompt)
        
        ** 以下是面試前詢問使用者的問題，請參考「問」以及「答」來設計題目，且不要被錯誤的使用者答帶跑。
        """
        for item in i.preQuestions {
            if !(item.answer.isEmpty) {
                textPart.append("""
                    問：\(item.question)
                    答：\(item.answer)
                
                """)
            }
        }
        textPart.append("""
        ** 題目數量
            出 \(i.questionNumbers) 題面試問題。
            請直接輸出題目，不需要其他說明，也不用新增題號。
        ** 題目問題調整
            - 正式程度（題目的口氣與氣氛，0.5 一般，1.0 正式，0.0 輕鬆）為 \(i.questionFormalStyle)，
            - 嚴格程度（問題的深度與難度，0.5 一般，1.0 正式，0.0 輕鬆）為 \(i.questionStrictStyle)
        """)
        
        if (i.filesPath.count > 0){
            textPart.append("""
            ** 附件
                使用者提供了 \(i.filesPath.count) 個附件，這些是面試者的附件，請參考附件內容與之前所提的面試準則（請僅依據附件有且實際需要的內容進行參考）。
            """)
        }
        
        prompt.append(TextPart(textPart))
        
        // 檔案
        
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
        
        let content: [ModelContent] = [ModelContent(role: "user", parts: prompt)]
    
        do {
            
            // 在生成前獲取 Token 數量
            let countTokensResponse = try await model.countTokens(content)
            print("GeminiService | Prompt Token Count: \(countTokensResponse.totalTokens)")
            
            // 生成
            let response = try await model.generateContent(content)
            print("GeminiService | Generated \(response).")
            
            // 解析
            guard let jsonString = response.text,
                  let jsonData = jsonString.data(using: .utf8) else {
                print("GeminiService | Could not get JSON string or convert to data.")
                return []
            }
            
            let questionsArray: [String]
            do {
                questionsArray = try JSONDecoder().decode([String].self, from: jsonData)
            } catch {
                print("GeminiService | Error decoding JSON: \(error)")
                return []
            }

            let interviewQuestions: [InterviewProfileQuestions] = questionsArray.map { questionString in
                InterviewProfileQuestions(question: questionString, answerAudioPath: "", answer: "", score: 0, feedback: "")
            }
            
            // 回應 Token 數量
            if let responseContent = response.candidates.first?.content {
                         let responseCountTokensResponse = try await model.countTokens([responseContent])
                         print("GeminiService | Response Token Count: \(responseCountTokensResponse.totalTokens)")
                    }
            
            // 紀錄
            AnalyticsLogger.shared.generatedQuestions(templateName: i.templateName, token: countTokensResponse.totalTokens, generatedNum: i.questionNumbers, filesNum: i.filesPath.count, modFormalLevel: Int(i.questionFormalStyle*100), modStrictLevel: Int(i.questionStrictStyle*100))

            return interviewQuestions

        } catch {
            // 處理生成或解析錯誤
            print("GeminiService | Error generating or parsing questions: \(error)")
            return []
        }
        
    }

    // 語音轉文字
    
    func generateAudioText(source audioPath: String) async -> String {
        
            // 1. Validate source path
            if audioPath.isEmpty {
                print("GeminiService | Audio source path is empty.")
                return "No answer"
            }

            let audioFileURL = URL(fileURLWithPath: audioPath)
            let fileManager = FileManager.default

            if !fileManager.fileExists(atPath: audioFileURL.path) {
                print("GeminiService | Audio file does not exist at path: \(audioPath)")
                return "No answer"
            }

            // 2. Load audio data
            let audioData: Data
            do {
                audioData = try Data(contentsOf: audioFileURL)
            } catch {
                print("GeminiService | Error loading audio data from \(audioPath): \(error)")
                return "No answer" // Treat as a bad source
            }

            if audioData.isEmpty {
                print("GeminiService | Audio data is empty for path: \(audioPath)")
                return "No answer"
            }

            // 3. Determine MIME type
            let fileExtension = audioFileURL.pathExtension.lowercased()
            var mimeType: String
            switch fileExtension {
            case "m4a":
                mimeType = "audio/mp4" // M4A is an MP4 container, often with AAC. "audio/mp4" is widely supported.
                                       // "audio/m4a" might also work with some APIs.
            case "mp3":
                mimeType = "audio/mpeg"
            default:
                print("GeminiService | Unsupported audio file extension: \(fileExtension). Returning 'No answer'.")
                // If the MIME type is critical and unknown, it's safer to return an error.
                // Alternatively, you could try a generic one like "audio/octet-stream" but success isn't guaranteed.
                return "No answer" // Or "Can not analyse audio" if you prefer to try Gemini and let it fail
            }
            
            print("GeminiService | Attempting to transcribe audio from \(audioPath) with MIME type: \(mimeType)")

            // 4. Construct prompt for Gemini (using the class's default model)
            let audioPart = InlineDataPart(data: audioData, mimeType: mimeType)
            
            // A very direct prompt asking only for transcription.
            let transcriptionPrompt = "Transcribe the following audio to text. Provide only the raw transcription of the spoken words. Do not add any additional comments, summaries, or explanations. If the audio is silent or unintelligible, indicate that appropriately or return an empty string for the transcription. (If content is Chinese, please response as traditional chinese.)"
            let textPart = TextPart(transcriptionPrompt)

            // The order of parts can sometimes matter. Instruction then data is common.
            let content: [ModelContent] = [ModelContent(role: "user", parts: [textPart, audioPart])]
            // Or, for some multimodal models, just sending the audio part with a general model might infer transcription.
            // However, an explicit prompt is safer for your specific "don't change content" requirement.

            // 5. Send to Gemini and process response
            do {
                let response = try await self.model.generateContent(content) // Using self.model

                if let transcribedText = response.text, !transcribedText.isEmpty {
                    print("GeminiService | Audio transcribed successfully. Length: \(transcribedText.count)")
                    return transcribedText
                } else if response.text != nil && response.text!.isEmpty {
                    print("GeminiService | Gemini returned an empty transcription (possibly silent or unintelligible audio).")
                    return "" // Or "No answer" / "Audio silent or unintelligible" if you prefer
                }
                else {
                    print("GeminiService | Gemini response did not contain usable text for transcription.")
                    return "Can not analyse audio"
                }
            } catch {
                print("GeminiService | Error during Gemini API call for audio transcription: \(error)")
                return "Can not analyse audio"
            }
        }
    
    // 重要：評語
    
    func generateInterviewFeedback(interviewProfile: inout InterviewProfile) async {
        
        struct GeminiFeedbackResponse: Codable {
            let question_evaluations: [GeminiQuestionEvaluation]
            let overall_interview_feedback: [GeminiOverallFeedbackItem]
            let overall_rating: Int
        }

        struct GeminiQuestionEvaluation: Codable {
            let question_id: String
            let score: Int
            let feedback: String
        }

        struct GeminiOverallFeedbackItem: Codable {
            let content: String
            let positive: Bool
            let suggestion: String
        }
        
        print("GeminiService | 開始生成面試回饋...")

        // 1. 定義 Gemini 回應的 JSON Schema
        let feedbackSchema: Schema = .object(
            properties: [
                "question_evaluations": .array(
                    items: .object(properties: [
                        "question_id": .string(description: "問題的 UUID 字串，用於精確匹配"),
                        "score": .integer(description: "該問題的得分 (本項目評分 0 到 10 分)"),
                        "feedback": .string(description: "針對該問題回答的具體文字回饋")
                    ]), description: "針對每個問題的評估列表"
                ),
                "overall_interview_feedback": .array(
                    items: .object(properties: [
                        "content": .string(description: "一個主題式回饋的內容描述"),
                        "positive": .boolean(description: "此項主題回饋是否為正面 (true/false)"),
                        "suggestion": .string(description: "針對此主題的改進建議或強化說明")
                    ]), description: "針對整體面試表現的主題式回饋列表"
                ),
                "overall_rating": .integer(description: "整體面試評分 (本項目評分 0 到 100分)，代表成功機率")
            ]
        )

        // 2. 初始化用於生成回饋的 Gemini 模型 (配置 JSON 輸出)
        let feedbackGenerationModel = VertexAI.vertexAI().generativeModel(
            modelName: "gemini-2.0-flash-lite-001",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: feedbackSchema
            )
        )

        // 3. 構建 Prompt
        var promptParts: [any Part] = []
        var textPromptString = """
        你是一位資深的模擬面試教練與評估員。你的任務是分析以下模擬面試的過程與結果，並提供詳細的回饋。

        **面試基本資訊:
        *   **面試類型重點:** \(interviewProfile.templatePrompt)
        *   **使用者在面試前提供的背景資訊:**

        """
        for item in interviewProfile.preQuestions {
            if !item.answer.isEmpty {
                textPromptString += "    - 問題: \(item.question)\n    - 使用者回答: \(item.answer)\n"
            }
        }
        textPromptString += """
        *   **期望的正式程度:** \(interviewProfile.questionFormalStyle) (0.0 輕鬆, 0.5 一般, 1.0 正式；本項代表問題與回答應具備的正式或專業程度)
        *   **期望的嚴格程度:** \(interviewProfile.questionStrictStyle) (0.0 寬鬆, 0.5 一般, 1.0 嚴格；本項代表評分時的嚴格程度，較嚴格的面試請給予較嚴苛的評分與評語，反之較寬鬆的面試請給與輕鬆簡單的標準與寬鬆的評分)

        """

        if !interviewProfile.filesPath.isEmpty {
            textPromptString += "*   **使用者提供的參考文件:** 在評估可能與文件內容相關的回答時，請務必參考附件的內容。\n\n"
            for filePath in interviewProfile.filesPath {
                let fileURL = URL(fileURLWithPath: filePath)
                if let fileData = try? Data(contentsOf: fileURL) {
                    promptParts.append(InlineDataPart(data: fileData, mimeType: "application/pdf"))
                    print("GeminiService | 已載入參考文件: \(filePath)")
                } else {
                    print("GeminiService | 警告: 無法載入或判斷參考文件 MIME 類型: \(filePath)")
                }
            }
        }

        textPromptString += "**面試問題與使用者回答:**\n"
        var questionIndexForPrompt = 0
        for questionData in interviewProfile.questions {
            questionIndexForPrompt += 1
            textPromptString += """
            ---
            **問題 \(questionIndexForPrompt) (ID: \(questionData.id.uuidString)):** \(questionData.question)
            **使用者文字回答:** \(questionData.answer)

            """
        }
        textPromptString += """
        ---

        **評估任務:**
        請嚴格依照以下指定的 JSON 格式提供您的評估報告。不要在 JSON 結構之外包含任何其他文字。

        **評估指南:**
        *   針對每個問題 (question_evaluations)，請給出 `question_id` (用於對應原始問題的UUID)、`score` (0 到 10 分的分數) 以及 `feedback` (針對此問題回答的具體回饋，請考量內容的完整性、清晰度、相關性，並結合錄音分析回答者的語氣、自信度、流暢度、贅詞等。請提供建設性的意見。)。
        *   針對整體面試 (overall_interview_feedback)，請提供 2 到 10 個獨立的主題式回饋，每個包含 `content` (評論內容)、`positive` (是否正面 true/false) 以及 `suggestion` (改進建議或強化說明)。
        *   `overall_rating` 應為 0 到 100 分的綜合評分，代表基於本次模擬面試，應試者準備充分度以及成功錄取/通過的可能性，請務必嚴謹評估。
            這代表面試的錄取機率，如果使用者表現優異，應給予 80 分以上分數，只有在表現極差才給予 40 分以下的分數。
        *   請分析文字回答與可能的檔案以進行全面評估。
        *   嚴格遵守定義的 JSON 輸出格式。
        """

        promptParts.insert(TextPart(textPromptString), at: 0)

        let contentToGenerate: [ModelContent] = [ModelContent(role: "user", parts: promptParts)]

        do {
            let countTokensResponse = try await feedbackGenerationModel.countTokens(contentToGenerate)
            print("GeminiService | 面試回饋 Prompt Token 總數: \(countTokensResponse.totalTokens)")
            if countTokensResponse.totalTokens > 70000 {
                 print("GeminiService | 警告: Prompt Token 數量 (\(countTokensResponse.totalTokens)) 偏高，可能影響效能或成本。")
            }
        } catch {
            print("GeminiService | 計算 Token 時發生錯誤: \(error)")
        }

        // 4. 呼叫 Gemini API 生成內容
        print("GeminiService | 正在向 Gemini 發送請求以生成面試回饋...")
        let response: GenerateContentResponse
        do {
            response = try await feedbackGenerationModel.generateContent(contentToGenerate)
        } catch {
            print("GeminiService | Gemini API 生成回饋時發生錯誤: \(error)")
            return
        }

        // 5. 解析 JSON 回應
        guard let jsonString = response.text,
              let jsonData = jsonString.data(using: .utf8) else {
            print("GeminiService | 無法從 Gemini 回應中獲取 JSON 字串或轉換為 Data。")
            print("GeminiService | Gemini 原始回應文字: \(response.text ?? "無回應文字")")
            return
        }

        let decoder = JSONDecoder()
        let decodedFeedback: GeminiFeedbackResponse
        do {
            decodedFeedback = try decoder.decode(GeminiFeedbackResponse.self, from: jsonData)
        } catch {
            print("GeminiService | 解析 Gemini JSON 回饋時發生錯誤: \(error)")
            print("GeminiService | 解析失敗的 JSON 字串:\n\(jsonString)")
            return
        }

        // 6. 更新 InterviewProfile 物件
        // 更新每個問題的評分和回饋
        for evalItem in decodedFeedback.question_evaluations {
            if let questionIndex = interviewProfile.questions.firstIndex(where: { $0.id.uuidString == evalItem.question_id }) {
                interviewProfile.questions[questionIndex].score = evalItem.score
                interviewProfile.questions[questionIndex].feedback = evalItem.feedback
                print("GeminiService | 已更新問題 (ID: \(evalItem.question_id)) 的分數: \(evalItem.score), 回饋: \(evalItem.feedback.prefix(50))...")
            } else {
                print("GeminiService | 警告: 在 InterviewProfile 中找不到對應的問題 ID: \(evalItem.question_id)")
            }
        }

        // 更新整體回饋 (需要確認 InterviewProfile.feedbacks 的類型已修改為 [InterviewProfileFeedbacks])
        interviewProfile.feedbacks = decodedFeedback.overall_interview_feedback.map { item in
            InterviewProfileFeedbacks(content: item.content, positive: item.positive, suggestion: item.suggestion)
        }
        print("GeminiService | 已更新 \(interviewProfile.feedbacks.count) 項整體回饋。")


        // 更新整體評分
        interviewProfile.overallRating = decodedFeedback.overall_rating
        print("GeminiService | 已更新整體評分: \(interviewProfile.overallRating)")

        interviewProfile.status = 4 // 假設 4 代表已完成並生成回饋
        print("GeminiService | 面試回饋已成功生成並更新到 InterviewProfile。狀態已更新為 4。")
        
        // 紀錄 Analytics
        AnalyticsLogger.shared.generatedAnalysis(templateName: interviewProfile.templateName, generatedNum: interviewProfile.questionNumbers, filesNum: interviewProfile.filesPath.count, modFormalLevel: Int(interviewProfile.questionFormalStyle*100), modStrictLevel: Int(interviewProfile.questionStrictStyle*100), overallScore: interviewProfile.overallRating)
    }
    
}
