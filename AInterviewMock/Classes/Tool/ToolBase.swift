//
//  ToolBase.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/23.
//

import Foundation
import AVFoundation
import FirebaseVertexAI

/// TOOL 的工具基底
/// 包含檔案讀寫／音訊／檔案／AI
class ToolBase: ObservableObject {
    // MARK: - 初始化
    
    var toolName: String {
        return "ToolBase"                              // 本工具名稱（會存在本處目錄）
    }
    
    init() {
        self.checkPermissionStatus()
    }
    
    // MARK: - 檔案處理
    /// 將指定檔案複製到 App 的 Documents 目錄下一個以 toolName/UUID 命名的資料夾中。
    /// - Parameters:
    ///   - sourceFileURL: 要複製的來源檔案的 URL。
    ///   - uuid: 用於創建子目錄的唯一標識符。
    /// - Returns: 如果成功，返回儲存後新檔案的 URL 字串；如果失敗，返回 `nil`。
    func saveFile(from sourceFileURL: URL, for uuid: UUID) -> String? {
        let fileManager = FileManager.default
        
        // 1. 獲取 App 的 Documents 目錄 URL
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\(toolName) | 嚴重錯誤：無法取得 Documents 目錄路徑。")
            return nil
        }
        
        // 2. 使用 appendingPathComponent 創建正確的目標【資料夾】路徑
        let destinationFolderURL = documentsURL
            .appendingPathComponent(self.toolName, isDirectory: true)
            .appendingPathComponent(uuid.uuidString, isDirectory: true)
        
        // 3. 檢查並創建目標資料夾
        do {
            try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("\(toolName) | 建立目標資料夾失敗: \(error.localizedDescription)")
            return nil
        }
        
        // 4. 創建最終的目標【檔案】路徑
        let destinationFileURL = destinationFolderURL.appendingPathComponent(sourceFileURL.lastPathComponent)
        
        // 5. 執行檔案複製操作
        do {
            // 如果目標位置已存在同名檔案，先刪除它，避免 copyItem 失敗
            if fileManager.fileExists(atPath: destinationFileURL.path) {
                try fileManager.removeItem(at: destinationFileURL)
                print("\(toolName) | 已存在同名檔案，已將其移除。")
            }
            
            // 將檔案從來源位置複製到目標位置
            try fileManager.copyItem(at: sourceFileURL, to: destinationFileURL)
            
            print("\(toolName) | 檔案成功儲存至: \(destinationFileURL.path)")
            
            // 6. ✅ 回傳新檔案的 URL 字串
            return destinationFileURL.path
            
        } catch {
            print("\(toolName) | 複製檔案時發生錯誤: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 嘗試將任何遵守 `Identifiable` 協定的物件序列化成 JSON 並儲存。
    /// 此函式【假設】物件的 `id` 屬性是 `UUID` 類型。如果不是，將會直接返回 nil。
    /// 儲存路徑為：.../Documents/<toolName>/<object.id>.json
    /// - Parameters:
    ///     - _: 要儲存的物件，它必須遵守 Identifiable 協定，並且最好是 Encodable 的。
    /// - Returns: 如果成功，返回儲存後新檔案的 URL；如果失敗，返回 `nil`。
    func save(_ object: any Identifiable & Encodable) -> URL? {
        
        // 1. 核心檢查：使用 guard let 和 as? 來「假設」並安全地解包 UUID
        // 如果 object.id 無法被轉換為 UUID，函式會立即執行 else 區塊並返回 nil。
        guard let uuid = object.id as? UUID else {
            print("\(toolName) | 儲存失敗：傳入物件的 id (類型: \(type(of: object.id))) 不是 UUID。")
            return nil
        }
        
        let fileManager = FileManager.default
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        // 2. 獲取 App 的 Documents 目錄 URL
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\(toolName) | 嚴重錯誤：無法取得 Documents 目錄路徑。")
            return nil
        }
        
        // 3. 創建目標【資料夾】路徑：.../Documents/<toolName>/<uuid>/<toolName>.json
        let destinationFolderURL = documentsURL
                                    .appendingPathComponent(self.toolName, isDirectory: true)
                                    .appendingPathComponent(uuid.uuidString, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("\(toolName) | 建立目標資料夾失敗: \(error.localizedDescription)")
            return nil
        }
        
        // 4. 創建最終的目標【檔案】路徑，檔名為 uuid.json
        let destinationFileURL = destinationFolderURL
            .appendingPathComponent(self.toolName)
            .appendingPathExtension("json")
            
        // 5. 將物件編碼成 JSON Data
        do {
            // 因為我們在函式簽名中要求了 Encodable，所以這裡可以直接編碼
            let jsonData = try encoder.encode(object)
            
            // 6. 將 JSON Data 寫入檔案
            try jsonData.write(to: destinationFileURL, options: [.atomic])
            
            print("\(toolName) | 物件 (UUID: \(uuid.uuidString)) 成功序列化並儲存至: \(destinationFileURL.path)")
            
            // 7. 回傳新檔案的 URL
            return destinationFileURL
            
        } catch {
            print("\(toolName) | 序列化或寫入檔案時發生錯誤: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 從指定工具的資料夾中，加載所有能被成功解碼為特定類型的檔案。
    /// - Parameter type: 要加載的目標類型，它必須遵守 `Loadable` (即 `Decodable`)。
    /// - Returns: 一個包含所有成功解碼物件的陣列。如果資料夾不存在或發生任何錯誤，返回一個空陣列。
    func load<T: Codable>(all ofType: T.Type) -> [T] {
        let fileManager = FileManager.default
        let decoder = JSONDecoder()

        // 1. 獲取 App 的 Documents 目錄 URL
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\(toolName) | 嚴重錯誤：無法取得 Documents 目錄路徑。")
            return []
        }
        
        // 2. 拼接目標【資料夾】路徑：.../Documents/<toolName>/
        let sourceFolderURL = documentsURL.appendingPathComponent(self.toolName, isDirectory: true)
        
        // 3. 檢查資料夾是否存在，如果不存在就沒什麼好加載的
        guard fileManager.fileExists(atPath: sourceFolderURL.path) else {
            print("\(toolName) | 資料夾不存在，無需加載。")
            return []
        }
        
        var loadedObjects: [T] = []
        
        do {
            // 獲取根目錄下的所有子目錄
            let subfolderURLs = try fileManager.contentsOfDirectory(at: sourceFolderURL, includingPropertiesForKeys: [.isDirectoryKey])
            
            // 便利每一個子目錄
            for subfolderURL in subfolderURLs {
                let resourceValues = try? subfolderURL.resourceValues(forKeys: [.isDirectoryKey])
                guard resourceValues?.isDirectory == true else {
                    continue
                }
                
                // 存於「toolName.json」
                var profileFileURL = subfolderURL
                profileFileURL.appendPathComponent(self.toolName)
                profileFileURL.appendPathExtension("json")
                
                // 5. 如果 profile.json 存在，就嘗試讀取和解碼
                if fileManager.fileExists(atPath: profileFileURL.path) {
                    do {
                        let jsonData = try Data(contentsOf: profileFileURL)
                        let object = try decoder.decode(T.self, from: jsonData)
                        loadedObjects.append(object)
                    } catch {
                        // 如果某個 profile.json 解碼失敗，打印錯誤並繼續
                        print("\(toolName) | 警告：解碼檔案 \(profileFileURL.lastPathComponent) 失敗: \(error)")
                        continue
                    }
                }
            }
        } catch {
            print("\(toolName) | 遍歷資料夾內容時發生錯誤: \(error.localizedDescription)")
            return []
        }
        
        print("\(toolName) | 成功加載了 \(loadedObjects.count) 個 \(String(describing: T.self)) 類型的物件。")
        return loadedObjects
    }
    
    /// 根據提供的 UUID，刪除對應的整個資料夾及其所有內容。
    /// 刪除路徑為：.../Documents/<toolName>/<uuid>/
    /// - Parameter uuid: 要刪除的資料夾所對應的 UUID。
    /// - Returns: 如果刪除成功或資料夾本來就不存在，返回 `true`；如果刪除過程中發生錯誤，返回 `false`。
    @discardableResult
    func delete(for uuid: UUID) -> Bool {
        let fileManager = FileManager.default
        
        // 1. 獲取 App 的 Documents 目錄 URL
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\(toolName) | 嚴重錯誤：無法取得 Documents 目錄路徑。")
            return false
        }
        
        // 2. 拼接要刪除的目標【資料夾】路徑
        //    路徑：.../Documents/<toolName>/<uuid>/
        let targetFolderURL = documentsURL
            .appendingPathComponent(self.toolName, isDirectory: true)
            .appendingPathComponent(uuid.uuidString, isDirectory: true)
        
        // 3. 檢查目標資料夾是否存在
        guard fileManager.fileExists(atPath: targetFolderURL.path) else {
            // 如果資料夾本來就不存在，從邏輯上講，「刪除」這個操作也算是成功了
            print("\(toolName) | UUID 為 \(uuid.uuidString) 的資料夾不存在，無需刪除。")
            return true
        }
        
        // 4. 執行刪除操作
        do {
            // 使用 removeItem(at:) 來刪除整個資料夾和它裡面的所有內容
            try fileManager.removeItem(at: targetFolderURL)
            print("\(toolName) | 成功刪除資料夾: \(targetFolderURL.path)")
            return true
        } catch {
            print("\(toolName) | 刪除資料夾時發生錯誤: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 音訊
    @Published var microphonePermissionStatus: AVAudioSession.RecordPermission = .undetermined
    private var audioRecorder: AVAudioRecorder? // 錄音器
    private var recordedFileURL: URL?           // 最後錄製路徑
    
    /// 檢查麥克風權限
    private func checkPermissionStatus() {
        microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
    }
    
    /// 要求權限
    func requestPermission() {
        let session = AVAudioSession.sharedInstance()
        
        session.requestRecordPermission { granted in
            // 這個閉包會在用戶做出選擇後被執行
            // 它可能不在主線程上，所以如果需要更新 UI，要切換回主線程
            if granted {
                self.microphonePermissionStatus = .granted
                print("ToolBase - \(self.toolName) | 用戶剛剛授予了權限")
            } else {
                self.microphonePermissionStatus = .denied
                print("ToolBase - \(self.toolName) | 用戶剛剛拒絕了權限")
            }
        }
        
    }
    
    /// 開始錄音
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            let fileManager = FileManager.default
            let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let filename = "\(UUID().uuidString).m4a"
            let fileURL = cacheURL.appendingPathComponent(filename)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                AVEncoderBitRateKey: 32000
            ]
            
            do {
                recordedFileURL = fileURL
                audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
                audioRecorder?.record()
            } catch {
                print("ToolBase - \(self.toolName) | 開始錄音失敗：\(error)")
            }
            
        } catch {
            print("ToolBase - \(self.toolName) | 設定 Audio Session 時發生錯誤 \(error)")
        }
    }
    
    /// 停止錄音並會傳暫存檔案 URL
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        print("ToolBase - \(self.toolName) | 錄音結束，檔案暫存在 \(recordedFileURL?.path ?? "未知")")
        return recordedFileURL
    }
    
    // MARK: - Gemini AI
    let aiModel = VertexAI.vertexAI(location: "us-central1").generativeModel(modelName: "gemini-2.0-flash-lite")
    
    /// 依照 prompt 生成文字
    func generateText(from prompt: String) async -> String? {
        do {
            let response = try await aiModel.generateContent(prompt)
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
    
    /// 依照語音路徑語音轉文字
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
        let transcriptionPrompt = """
        Transcribe the following audio to text. Output only the spoken words, with no commentary.
        If the language is Chinese, use Traditional Chinese characters (繁體字), not Simplified.
        If the audio is empty or unclear, return an empty string.
        Do not add new line at end.
        """
        let textPart = TextPart(transcriptionPrompt)

        // The order of parts can sometimes matter. Instruction then data is common.
        let content: [ModelContent] = [ModelContent(role: "user", parts: [textPart, audioPart])]

        // 5. Send to Gemini and process response
        do {
            let response = try await self.aiModel.generateContent(content)

            if let transcribedText = response.text, !transcribedText.isEmpty {
                print("GeminiService | Audio transcribed successfully. Length: \(transcribedText.count)")
                return transcribedText.trimmingCharacters(in: .newlines)
            } else if response.text != nil && response.text!.isEmpty {
                print("GeminiService | Gemini returned an empty transcription (possibly silent or unintelligible audio).")
                return ""
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
    
    /// 依照 Schema 生成回饋
    func generateResponseFromSchema(schema: Schema, prompt: [any Part]) async -> GenerateContentResponse? {
        print("\(toolName) | 正在依照 Schema 生成回應")
        
        // Model 建立
        let gModel = VertexAI.vertexAI(location: "us-central1").generativeModel(
            modelName: "gemini-2.0-flash-lite",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: schema
            )
        )
        
        // Content 建立
        let content: [ModelContent] = [ModelContent(role: "user", parts: prompt)]
        
        // Response 建立（回傳 GenerateContentResponse）
        let response: GenerateContentResponse
        do {
            response = try await gModel.generateContent(content)
        } catch {
            return nil
        }
        
        return response
    }
}
