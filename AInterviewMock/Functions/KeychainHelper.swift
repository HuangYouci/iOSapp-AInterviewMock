//
//  KeychainHelper.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/19.
//

import Foundation
import Security

struct KeychainHelper {
    
    /// 將數據安全地儲存到 Keychain。
    /// - Parameters:
    ///   - data: 要儲存的數據。
    ///   - key: 唯一的鍵，用於識別數據。
    /// - Returns: 如果儲存成功，返回 `true`。
    static func save(data: Data, forKey key: String) -> Bool {
        // 準備 Keychain 查詢字典
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            // 設置可訪問性：設備解鎖後才能訪問
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // 為了確保能寫入，先刪除可能已存在的舊項目
        SecItemDelete(query as CFDictionary)
        
        // 添加新項目
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // 檢查操作是否成功
        return status == errSecSuccess
    }
    
    /// 從 Keychain 安全地讀取數據。
    /// - Parameter key: 之前儲存時使用的唯一鍵。
    /// - Returns: 如果找到，返回儲存的 `Data`；否則返回 `nil`。
    static func load(forKey key: String) -> Data? {
        // 準備 Keychain 查詢字典
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        
        // 執行查詢
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            // 如果成功，將結果轉換為 Data
            return dataTypeRef as? Data
        } else {
            // 如果找不到或發生其他錯誤，返回 nil
            return nil
        }
    }
    
    /// 從 Keychain 中刪除一個項目。
    /// - Parameter key: 要刪除的項目的鍵。
    /// - Returns: 如果刪除成功，返回 `true`。
    static func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
