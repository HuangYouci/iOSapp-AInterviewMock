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
    
    let vertex = VertexAI.vertexAI()
    let model: GenerativeModel
    
    private init(){
        self.model = vertex.generativeModel(modelName: "gemini-2.0-flash-lite-001")
    }
    
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
                \(i.templatePrompt)
        
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
            出 \(i.questionNumbers) 題面試問題，
            而正式程度（題目的口氣與氣氛，0.5 一般，1.0 正式，0.0 輕鬆）為 \(i.questionFormalStyle)，
            而嚴格程度（問題的深度與難度，0.5 一般，1.0 正式，0.0 輕鬆）為 \(i.questionStrictStyle)
        """)
        
        if (i.filesPath.count > 0){
            textPart.append("""
                使用者提供了 \(i.filesPath.count) 個附件，這些是面試者的附件，請參考附件內容與之前所提的面試準則（請僅依據附件有的內容進行參考）。
            。
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
                InterviewProfileQuestions(question: questionString, answer: "", score: 0, feedback: "")
            }
            
            // 回應 Token 數量
            if let responseContent = response.candidates.first?.content {
                         let responseCountTokensResponse = try await model.countTokens([responseContent])
                         print("GeminiService | Response Token Count: \(responseCountTokensResponse.totalTokens)")
                    }

            return interviewQuestions

        } catch {
            // 處理生成或解析錯誤
            print("GeminiService | Error generating or parsing questions: \(error)")
            return []
        }
        
    }

}
