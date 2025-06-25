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
    
}
