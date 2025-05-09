//
//  AudioRecorder.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/8.
//

import SwiftUI
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    
    static let shared = AudioRecorder()
    
    private var audioRecorder: AVAudioRecorder?
    private(set) var recordedFileURL: URL? // 最後錄音檔案路徑
    @Published var isRecording = false

    /// 檢查麥克風權限（同步呼叫）
    func checkPermission() -> Bool {
        let session = AVAudioSession.sharedInstance()
        return session.recordPermission == .granted
    }

    /// 開始錄音（會請求權限）
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            session.requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.beginRecording()
                    }
                } else {
                    print("AudioRecorder | 沒有麥克風權限")
                }
            }
        } catch {
            print("AudioRecorder | 設定 audio session 發生錯誤：\(error)")
        }
    }

    /// 開始錄音的內部邏輯（已確保權限）
    private func beginRecording() {
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
            isRecording = true
        } catch {
            print("AudioRecorder | 開始錄音失敗：\(error)")
        }
    }

    /// 停止錄音並回傳暫存檔案 URL
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        print("AudioRecorder | 錄音結束，檔案暫存在 \(recordedFileURL?.path ?? "未知")")
        return recordedFileURL
    }
    
    /// 只請求麥克風權限，不錄音
    func requestMicrophonePermissionOnly() {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default)
                try session.setActive(true)
                session.requestRecordPermission { granted in
                    if granted {
                        print("AudioRecorder | 麥克風權限已授權")
                        DispatchQueue.main.async {
                            self.isRecording = true
                        }
                    } else {
                        print("AudioRecorder | 麥克風權限被拒絕")
                        DispatchQueue.main.async {
                            self.isRecording = false
                        }
                    }
                }
            } catch {
                print("AudioRecorder | 麥克風權限請求失敗：\(error)")
            }
        }

}
