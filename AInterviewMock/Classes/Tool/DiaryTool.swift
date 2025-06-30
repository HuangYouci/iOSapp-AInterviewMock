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

    
}
