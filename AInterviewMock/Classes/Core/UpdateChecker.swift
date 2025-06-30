//
//  UpdateChecker.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/14.
//

import Foundation

class UpdateChecker: ObservableObject {
    
    enum UpdateCheckerStatus {
        case higher  // Beta
        case same    // Stable
        case lower   // Old
    }
    
    static let shared = UpdateChecker()
    
    @Published var status: UpdateCheckerStatus = .same
    @Published var newestVersion: String = ""   // app store 版本
    @Published var thisVersion: String = ""     // 現在運行的版本
    @Published var whatsNew: String = ""        // app store 更新信息
    
    init(){
        checkAppStoreVersion()
    }
    
    private func checkAppStoreVersion() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            print("UpdateChecker | Error: Could not get bundle identifier.")
            return
        }
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)&timestamp=\(Date().timeIntervalSince1970)") else {
            print("UpdateChecker | Error: Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // 1. 檢查網路錯誤
            if let error = error {
                print("UpdateChecker | Network error: \(error.localizedDescription)")
                return
            }
            
            // 2. 檢查 HTTP 響應
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("UpdateChecker | Server error: \(String(describing: response))")
                return
            }
            
            // 3. 檢查數據
            guard let data = data else {
                print("UpdateChecker | No data received.")
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                // print("UpdateChecker | Raw API Response: \(String(describing: result))") // 調試時可以打開
                
                guard let resultsArray = result?["results"] as? [[String: Any]],
                      let appInfo = resultsArray.first,
                      let appStoreVersion = appInfo["version"] as? String,
                      let releaseNotes = appInfo["releaseNotes"] as? String else {
                    print("UpdateChecker | Could not parse app version or release notes from response.")
                    if let resultCount = result?["resultCount"] as? Int, resultCount == 0 {
                        print("UpdateChecker | No app found with the given bundle ID in App Store.")
                    }
                    return
                }
                
                guard let currentVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                    print("UpdateChecker | Could not get current app version.")
                    return
                }
                
                let currentVersionComponents = currentVersionString.split(separator: ".").compactMap { Int($0) }
                let appStoreVersionComponents = appStoreVersion.split(separator: ".").compactMap { Int($0) }
                
                // 確保版本號格式基本一致，或者你可以根據需求做更複雜的比較
                // 這裡假設版本號至少有一個組件
                if currentVersionComponents.isEmpty || appStoreVersionComponents.isEmpty {
                    print("UpdateChecker | Invalid version format. Current: \(currentVersionString), AppStore: \(appStoreVersion)")
                    return
                }
                
                // 逐個比較版本組件
                // 例如: "1.2.3" vs "1.3.0"
                if currentVersionComponents.lexicographicallyPrecedes(appStoreVersionComponents, by: <) {
                    
                    // 版本小於商店版本：舊版
                    
                    DispatchQueue.main.async {
                        print("UpdateChecker | Update available! New version: \(appStoreVersion), Release Notes: \(releaseNotes)")
                        self.whatsNew = releaseNotes
                        self.status = .lower
                        
                    }
                } else if currentVersionComponents.lexicographicallyPrecedes(appStoreVersionComponents, by: >) {
                    
                    // 版本大於商店版本：測試版
                    
                    DispatchQueue.main.async {
                        print("UpdateChecker | You are running test version! App Store version: \(appStoreVersion), Your Version: \(currentVersionString)")
                        self.status = .higher
                        
                    }
                } else {
                    
                    // 版本等於商店版本：正式版
                    DispatchQueue.main.async {
                        print("UpdateChecker | App is up to date. Current: \(currentVersionString), AppStore: \(appStoreVersion)")
                        self.status = .same
                    }
                }
                
                DispatchQueue.main.async {
                    self.thisVersion = currentVersionString
                    self.newestVersion = appStoreVersion
                    if self.status == .lower {
                        self.whatsNew = releaseNotes
                    }
                }
                
            } catch {
                print("UpdateChecker | Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
}
