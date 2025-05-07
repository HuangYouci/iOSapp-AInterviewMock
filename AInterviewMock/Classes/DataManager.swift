//
//  DataManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/6.
//

import SwiftUI

class DataManager: ObservableObject {
    
    static let shared = DataManager()
    
    // InterviewType
    
    func saveInterviewTypeDocuments(from sourceURL: URL, fileName: String) -> URL? {
        let fileManager = FileManager.default
        
        // ~/documents/
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("DataManager | 無法取得 Documents 路徑")
            return nil
        }

        // ~/documents/InterviewTypeDocuments/
        let folderURL = documentsURL.appendingPathComponent("InterviewProfileDocuments")
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("DataManager | 成功建立資料夾：\(folderURL.path)")
            } catch {
                print("DataManager | 建立資料夾失敗：\(error)")
                return nil
            }
        }
        
        // ~/documents/InterviewTypeDocuments/fileName
        let destinationURL = folderURL.appendingPathComponent("\(fileName).pdf")

        do {
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("DataManager | 複製成功！儲存位置：\(destinationURL.path)")
            return destinationURL
            
        } catch {
            
            print("DataManager | 複製檔案失敗：\(error)")
            return nil
            
        }
    }
    
    func saveInterviewTypeJSON(_ interview: InterviewProfile, fileName: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(interview) {
            let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("InterviewProfileDocuments")
            
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            let fileURL = url.appendingPathComponent("\(fileName).json")
            try? data.write(to: fileURL)
        }
    }
    
    func loadAllInterviewTypes() -> [InterviewProfile] {
        let folderURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("InterviewProfileDocuments")
        
        let fileURLs = (try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)) ?? []

        let decoder = JSONDecoder()
        var interviews: [InterviewProfile] = []

        for url in fileURLs where url.pathExtension == "json" {
            if let data = try? Data(contentsOf: url),
               let interview = try? decoder.decode(InterviewProfile.self, from: data) {
                interviews.append(interview)
            }
        }

        return interviews
    }



}
