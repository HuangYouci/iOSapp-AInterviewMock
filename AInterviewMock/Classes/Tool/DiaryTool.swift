//
//  DiaryTool.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/30.
//

import FirebaseVertexAI
import Foundation

class DiaryTool: ToolBase {
    
    override var toolName: String {
        return "Interview"
    }
    
    // MARK: - 生成修正過的日記
    
    func generateContent(i: DiaryProfile) async -> DiaryProfile? {
        
        struct responseStruct: Codable {
            let diaryTitle: String
            let diaryContent: String
        }
        
        var ri = i
        
        let schema: Schema = .object(
            properties: [
                "diaryTitle": .string(description: "以 20 字內作為本日記的標題"),
                "diaryContent": .string(description: "日記的內容")
            ]
        )
        
        var prompt: [any Part] = []
        
        let textprompt: String = """
        # 任務
        ## `diaryContent` 指引：
        請把附件使用者的日記內容轉成文章形式，符合正式的文章書寫規則（正確的標點符號、斷句與分段）。
        禁止更動輸入的內容，不要任意刪減新增其他非朗讀之文字。
        該分段時（例如換情境、換話題等等）就要分段（空兩行）。
        """
        
        prompt.append(TextPart(textprompt))
        
        let url = URL(fileURLWithPath: i.diaryPath)
        do {
            let audioData = try Data(contentsOf: url)
            prompt.append(InlineDataPart(data: audioData, mimeType: "audio/m4a"))
        } catch {
            print("\(toolName) | Error loading audio from \(i.diaryPath): \(error)")
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
            let decodedResponse = try JSONDecoder().decode(responseStruct.self, from: jsonData)
            
            print("\(toolName) | 成功解析日記")
            ri.diaryContent = decodedResponse.diaryContent
            ri.diaryTitle = decodedResponse.diaryTitle
            ri.status = .completed
            return ri
        } catch {
            print("\(toolName) | 發生錯誤 \(error)")
            return nil
        }
        
    }

    // MARK: - 生成觀眾回覆（一次一個）
    
    func generateResponse(i: DiaryProfile) async -> DiaryProfileResponses? {
        
        struct responseStruct: Codable {
            let responseName: String
            let responseComment: String
        }
        
        let schema: Schema = .object(
            properties: [
                "responseName": .string(description: "生成名稱"),
                "responseComment": .string(description: "生成留言內容")
            ]
        )
        
        var prompt: [any Part] = []
        
        let textprompt: String = """
        # 日記
        * 以下是使用者的日記內容
        ```
        \(i.diaryContent)
        ```
        # 任務
        ## `responseName` 指引：
        請以使用者日記的主要語言，生成隨機的一個網名（可以是真名、暱稱或是網路用戶名稱），不一定要與日記內容有關。
        ## `responseComment` 指引：
        請參考使用者的日記內容，當作觀眾（網友）留言你的看法、回饋或是心得。請採取隨機的不同的角色設定。
        可以多善用網路流行詞，表情符號或是顏文字。
        """
        
        prompt.append(TextPart(textprompt))
        
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
            
            print("\(toolName) | 成功解析日記")
            return DiaryProfileResponses(name: decodedResponse.responseName, comment: decodedResponse.responseComment)
        } catch {
            print("\(toolName) | 發生錯誤 \(error)")
            return nil
        }
        
    }
    
}
