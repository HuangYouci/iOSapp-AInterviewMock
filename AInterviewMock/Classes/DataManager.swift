//
//  DataManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/6.
//

import SwiftUI

class DataManager: ObservableObject {
    
    static let shared = DataManager()
    
    // MARK: - Write
    // Save Document
    func saveInterviewTypeDocuments(interviewProfile: inout InterviewProfile) {
            let fileManager = FileManager.default

            // ~/documents/
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("DataManager | 無法取得 Documents 路徑")
                return
            }

            // ~/documents/InterviewProfileDocuments/<interviewProfile.id>/
            let folderURL = documentsURL
                .appendingPathComponent("InterviewProfileDocuments")
                .appendingPathComponent("\(interviewProfile.id.uuidString)") // Use interviewProfile

            // 檢查並建立資料夾 (如果不存在)
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    print("DataManager | 成功建立資料夾：\(folderURL.path)")
                } catch {
                    print("DataManager | 建立資料夾失敗：\(error)")
                    return // If folder creation fails, can't proceed
                }
            }

            // 遍歷 filesPath 使用索引來更新
            for index in interviewProfile.filesPath.indices { // ⬅️ 2. Iterate by index
                let originalPathString = interviewProfile.filesPath[index]

                // 檢查原始路徑是否為空
                if originalPathString.isEmpty {
                    print("DataManager | filesPath 中索引 \(index) 的路徑為空，跳過。")
                    continue
                }

                let sourceURL = URL(fileURLWithPath: originalPathString)

                // 檢查原始檔案是否存在
                guard fileManager.fileExists(atPath: sourceURL.path) else {
                    print("DataManager | 原始文件檔案不存在：\(sourceURL.path)，跳過。")
                    continue
                }

                // 產生目標檔案名稱與路徑，嘗試保留原始副檔名
                let fileExtension = sourceURL.pathExtension
                let actualExtension = fileExtension.isEmpty ? "pdf" : fileExtension // ⬅️ 3. Preserve extension, default to pdf
                let destinationFilename = "\(UUID().uuidString).\(actualExtension)"
                let destinationURL = folderURL.appendingPathComponent(destinationFilename)

                do {
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.removeItem(at: destinationURL)
                        // print("DataManager | 已存在目標檔案，已刪除：\(destinationURL.path)") // Optional log
                    }

                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                    print("DataManager | 文件複製成功！儲存位置：\(destinationURL.path)")

                    // ⬅️ 4. 更新 InterviewProfile 實例中的路徑
                    interviewProfile.filesPath[index] = destinationURL.path
                    print("DataManager | filesPath 索引 \(index) 已更新為: \(destinationURL.path)")

                } catch {
                    print("DataManager | 複製文件檔案失敗：\(error) (從 \(sourceURL.path) 到 \(destinationURL.path))")
                    // 如果複製失敗，該文件的路徑保持原始狀態，繼續處理下一個文件
                    // interviewProfile.filesPath[index] 保持不變
                    continue // ⬅️ 5. Continue to next file on error
                }
            }
            print("DataManager | 所有文件處理完畢。interviewProfile.filesPath 已更新（針對成功複製的文件）。")
        }
    // Save Audio (from Temporary)
    func saveInterviewTypeAudios(interviewProfile: inout InterviewProfile) {
           let fileManager = FileManager.default

           // 1. 取得 Documents 目錄路徑
           guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
               print("DataManager | 無法取得 Documents 路徑")
               return
           }

           // 2. 建立目標資料夾路徑: ~/documents/InterviewProfileDocuments/<interviewProfile.id>/
           let folderURL = documentsURL
               .appendingPathComponent("InterviewProfileDocuments")
               .appendingPathComponent("\(interviewProfile.id.uuidString)") // 使用 interviewProfile

           // 3. 檢查並建立資料夾 (如果不存在)
           if !fileManager.fileExists(atPath: folderURL.path) {
               do {
                   try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                   print("DataManager | 成功建立資料夾：\(folderURL.path)")
               } catch {
                   print("DataManager | 建立資料夾失敗：\(error)")
                   return
               }
           }

           // 4. 遍歷 InterviewProfile 中的 questions，使用索引來修改
           for index in interviewProfile.questions.indices { // ⬅️ 2. 使用索引遍歷
               let sourceAudioPathString = interviewProfile.questions[index].answerAudioPath

               if sourceAudioPathString.isEmpty {
                   print("DataManager | 問題 (ID: \(interviewProfile.questions[index].id)) 的 answerAudioPath 為空，跳過。")
                   continue
               }

               let sourceAudioURL = URL(fileURLWithPath: sourceAudioPathString)

               guard fileManager.fileExists(atPath: sourceAudioURL.path) else {
                   print("DataManager | 原始音訊檔案不存在：\(sourceAudioURL.path)，跳過。")
                   continue
               }

               // 5. 產生目標檔案名稱與路徑
               let destinationFilename = "\(UUID().uuidString).m4a"
               let destinationURL = folderURL.appendingPathComponent(destinationFilename)

               // 6. 複製檔案
               do {
                   if fileManager.fileExists(atPath: destinationURL.path) {
                       try fileManager.removeItem(at: destinationURL)
                   }

                   try fileManager.copyItem(at: sourceAudioURL, to: destinationURL)
                   print("DataManager | 音訊複製成功！儲存位置：\(destinationURL.path)")

                   // ⬅️ 3. 更新 InterviewProfile 實例中的路徑
                   interviewProfile.questions[index].answerAudioPath = destinationURL.path
                   print("DataManager | 問題 (ID: \(interviewProfile.questions[index].id)) 的 answerAudioPath 已更新為: \(destinationURL.path)")

               } catch {
                   print("DataManager | 複製音訊檔案失敗：\(error) (從 \(sourceAudioURL.path) 到 \(destinationURL.path))")
                   continue
               }
           }
           print("DataManager | 所有音訊處理完畢。interviewProfile 已更新。")
       }
    // Update JSON
    func saveInterviewTypeJSON(_ interview: InterviewProfile) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(interview) {
            let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("InterviewProfileDocuments")
                .appendingPathComponent("\(interview.id.uuidString)")
            
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            let fileURL = url.appendingPathComponent("profile.json")
            do {
                try data.write(to: fileURL)
                print("DataManager | JSON 儲存成功：\(fileURL.path)")
            } catch {
                print("DataManager | 儲存 JSON 檔案失敗：\(error)")
                return
            }
        }
    }
    
    // MARK: - Load
    func loadAllInterviewProfiles() -> [InterviewProfile] {
        let fileManager = FileManager.default
        var interviews: [InterviewProfile] = []
        let decoder = JSONDecoder()

        // 1. 取得 InterviewProfileDocuments 的基礎目錄 URL
        guard let baseFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("InterviewProfileDocuments") else {
            print("DataManager | 無法取得 InterviewProfileDocuments 目錄路徑。")
            return []
        }

        // 檢查基礎目錄是否存在
        guard fileManager.fileExists(atPath: baseFolderURL.path) else {
            print("DataManager | InterviewProfileDocuments 目錄不存在於：\(baseFolderURL.path)")
            return [] // 如果基礎目錄不存在，則沒有任何東西可以載入
        }

        // 2. 獲取基礎目錄下的所有項目 (期望是子資料夾)
        do {
            let subDirectoryURLs = try fileManager.contentsOfDirectory(
                at: baseFolderURL,
                includingPropertiesForKeys: [.isDirectoryKey], // 我們只關心是否是目錄
                options: .skipsHiddenFiles
            )

            // 3. 遍歷每個子項目
            for potentialFolderURL in subDirectoryURLs {
                var isDirectory: ObjCBool = false
                // 確保它是一個目錄
                if fileManager.fileExists(atPath: potentialFolderURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
                    // 4. 檢查此子目錄內是否有 profile.json
                    let profileJsonURL = potentialFolderURL.appendingPathComponent("profile.json")

                    if fileManager.fileExists(atPath: profileJsonURL.path) {
                        // 5. 如果 profile.json 存在，則讀取並解碼
                        do {
                            let jsonData = try Data(contentsOf: profileJsonURL)
                            let interview = try decoder.decode(InterviewProfile.self, from: jsonData)
                            interviews.append(interview)
                            print("DataManager | 成功載入並解碼: \(profileJsonURL.path)")
                        } catch {
                            print("DataManager | 讀取或解碼 profile.json 失敗 (路徑: \(profileJsonURL.path)): \(error)")
                        }
                    } else {
                        // print("DataManager (Load) | 在目錄 \(potentialFolderURL.path) 中未找到 profile.json。")
                    }
                }
            }
        } catch {
            print("DataManager | 獲取 InterviewProfileDocuments 目錄內容失敗: \(error)")
        }

        print("DataManager | 共載入 \(interviews.count) 筆 InterviewProfile。")
        return interviews.sorted(by: { $0.date > $1.date }) // 按日期降序排序，最新的在前
    }
    
    // MARK: - Delete
    func deleteInterviewProfile(withId id: String) {
        let fileManager = FileManager.default

        // 1. 取得 Documents 目錄路徑
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("DataManager | 無法取得 Documents 路徑。")
            return
        }

        // 2. 構造目標資料夾的路徑: ~/documents/InterviewProfileDocuments/<id.uuidString>/
        let folderURLToDelete = documentsURL
            .appendingPathComponent("InterviewProfileDocuments")
            .appendingPathComponent(id)

        // 3. 檢查資料夾是否存在
        guard fileManager.fileExists(atPath: folderURLToDelete.path) else {
            print("DataManager | 要刪除的資料夾不存在：\(folderURLToDelete.path)")
            return
        }

        // 4. 刪除資料夾及其所有內容
        do {
            try fileManager.removeItem(at: folderURLToDelete)
            print("DataManager | 成功刪除資料夾及其內容：\(folderURLToDelete.path)")
            return
        } catch {
            print("DataManager | 刪除資料夾失敗：\(error) (路徑: \(folderURLToDelete.path))")
            return
        }
    }

}
