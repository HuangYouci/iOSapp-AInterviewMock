//
//  CoinManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI
import Security

class CoinManager: ObservableObject {
    static let shared = CoinManager()

    // MARK: - Published Properties
    @Published var coins: Int = 0
    @Published var isPremiumCoinAvailable: Bool = false

    // MARK: - Keychain Keys
    private let coinKeychainKey = "com.huangyouci.AInterviewMock.key.coin"
    private let lastPremiumClaimKeychainKey = "com.huangyouci.AInterviewMock.key.premiumLastGetCoinDate"

    // MARK: - Initialization
    private init() {
        // 從 Keychain 初始化代幣數量
        if let coinData = readDataFromKeychain(forKey: coinKeychainKey),
           let coinString = String(data: coinData, encoding: .utf8),
           let loadedCoins = Int(coinString) {
            self.coins = loadedCoins
            print("CoinManager | 💰 Keychain 初始化成功，代幣: \(self.coins)")
        } else {
            self.coins = 0
            print("CoinManager | ⚠️ Keychain 中未找到代幣數據，預設為 0")
        }
        // 初始化 isPremiumCoinAvailable 狀態
        updatePremiumCoinAvailability()
    }

    // MARK: - Public Coin Management Methods
    func getCoinValue() -> Int { // 雖然 View 可以直接用 cm.coins，但保留此方法以保持 API 一致性
        return self.coins
    }

    func addCoin(_ amount: Int) {
        guard amount > 0 else { return }
        DispatchQueue.main.async {
            let newTotal = self.coins + amount
            if self.saveDataToKeychain(value: newTotal, forKey: self.coinKeychainKey) {
                self.coins = newTotal
                print("CoinManager | ✅ 已增加 \(amount) 代幣。新總數: \(self.coins)")
            } else {
                print("CoinManager | ❌ 增加代幣失敗 (Keychain 儲存錯誤)")
            }
        }
    }

    func removeCoin(_ amount: Int) {
        guard amount > 0 else { return }
        DispatchQueue.main.async {
            let newTotal = max(0, self.coins - amount)
            if self.saveDataToKeychain(value: newTotal, forKey: self.coinKeychainKey) {
                self.coins = newTotal
                print("CoinManager | ✅ 已移除 \(amount) 代幣。剩餘: \(self.coins)")
            } else {
                print("CoinManager | ❌ 移除代幣失敗 (Keychain 儲存錯誤)")
            }
        }
    }

    // MARK: - Keychain Access (通用化)
    private func saveDataToKeychain(value: Int, forKey key: String) -> Bool {
        guard let valueData = String(value).data(using: .utf8) else {
            print("CoinManager | ❌ 無法將 Int \(value) 轉換為 Data for key \(key)")
            return false
        }
        return saveDataToKeychain(data: valueData, forKey: key)
    }

    private func saveDataToKeychain(date: Date, forKey key: String) -> Bool {
        let timeInterval = date.timeIntervalSince1970
        guard let valueData = String(timeInterval).data(using: .utf8) else {
            print("CoinManager | ❌ 無法將 Date \(date) 轉換為 Data for key \(key)")
            return false
        }
        return saveDataToKeychain(data: valueData, forKey: key)
    }

    private func saveDataToKeychain(data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let attributesToUpdate: [String: Any] = [kSecValueData as String: data]
        var status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        if status == errSecItemNotFound {
            var itemToSave = query
            itemToSave[kSecValueData as String] = data
            status = SecItemAdd(itemToSave as CFDictionary, nil)
        }
        if status == errSecSuccess {
            return true
        } else {
            print("CoinManager | ❌ 無法儲存/更新數據到 Keychain (Key: \(key))：狀態碼 \(status)")
            if let err = SecCopyErrorMessageString(status, nil) as? String { print("CoinManager | Keychain Error: \(err)") }
            return false
        }
    }

    private func readDataFromKeychain(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            return item as? Data
        } else if status != errSecItemNotFound { // 只在非 "not found" 的錯誤時印出
            print("CoinManager | ❌ 從 Keychain 讀取數據失敗 (Key: \(key))：狀態碼 \(status)")
            if let err = SecCopyErrorMessageString(status, nil) as? String { print("CoinManager | Keychain Error: \(err)") }
        }
        return nil
    }

    private func deleteFromKeychain(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("CoinManager | ❌ 從 Keychain 刪除數據失敗 (Key: \(key))：狀態碼 \(status)")
            if let err = SecCopyErrorMessageString(status, nil) as? String { print("CoinManager | Keychain Error: \(err)") }
            return false
        }
    }

    // MARK: - Premium Coin Logic
    func premiumGetCoin() {
        guard self.isPremiumCoinAvailable else { // 直接檢查 @Published 變數
            print("CoinManager | ⚠️ 尚未到可再次領取時間 (checked via @Published var)")
            return
        }

        DispatchQueue.main.async {
            let currentCoinsValue = self.coins
            if currentCoinsValue < 50 {
                if self.saveDataToKeychain(value: 50, forKey: self.coinKeychainKey) {
                    self.coins = 50
                    print("CoinManager | ✅ Premium coin 已設為 50 (因原少於50)。")
                } else {
                    print("CoinManager | ❌ Premium coin 設置失敗 (Keychain 儲存錯誤)")
                    return
                }
            } else {
                print("CoinManager | 💰 硬幣數量 (\(currentCoinsValue)) 已達到或超過 50，本次領取不額外增加。")
            }

            if self.saveDataToKeychain(date: Date(), forKey: self.lastPremiumClaimKeychainKey) {
                print("CoinManager | ✅ 已更新上次 Premium coin 領取時間到 Keychain。")
                self.updatePremiumCoinAvailability()
            } else {
                print("CoinManager | ❌ 更新上次 Premium coin 領取時間到 Keychain 失敗。")
            }
            
            AnalyticsHolder.shared.premiumGetCoins(count: 5, afterTotal: self.coins)
        }
    }

    private func checkRawPremiumCoinAvailability() -> Bool {
        guard let lastClaimData = readDataFromKeychain(forKey: lastPremiumClaimKeychainKey),
              let lastClaimString = String(data: lastClaimData, encoding: .utf8),
              let lastClaimTimeInterval = TimeInterval(lastClaimString) else {
            return true // Keychain 中無記錄，可領取
        }
        let lastDate = Date(timeIntervalSince1970: lastClaimTimeInterval)
        let interval = Date().timeIntervalSince(lastDate)
        return interval >= 3600 // 至少相隔一小時
    }

    func updatePremiumCoinAvailability() {
        let available = checkRawPremiumCoinAvailability()
        DispatchQueue.main.async {
            if self.isPremiumCoinAvailable != available {
                self.isPremiumCoinAvailable = available
                if available {
                    print("CoinManager | 🟢 Premium coin 現在可以領取。")
                } else {
                    if let lastClaimData = self.readDataFromKeychain(forKey: self.lastPremiumClaimKeychainKey),
                       let lastClaimString = String(data: lastClaimData, encoding: .utf8),
                       let lastClaimTimeInterval = TimeInterval(lastClaimString) {
                        let lastDate = Date(timeIntervalSince1970: lastClaimTimeInterval)
                        let interval = Date().timeIntervalSince(lastDate)
                        let remainingSeconds = max(0, 3600 - interval) // 避免負數
                        let minutes = Int(remainingSeconds) / 60
                        let seconds = Int(remainingSeconds) % 60
                        print("CoinManager | 🔴 Premium coin 領取冷卻中，預計剩餘 \(minutes) 分 \(seconds) 秒。")
                    } else {
                        print("CoinManager | 🔴 Premium coin 領取冷卻中 (無法計算剩餘時間)。")
                    }
                }
            }
        }
    }

    // 用於測試
    #if DEBUG
    func resetKeychainDataForTesting() {
        print("CoinManager | ⚠️ 正在重置 Keychain 中的代幣和領取時間數據 (用於測試)...")
        _ = deleteFromKeychain(forKey: coinKeychainKey)
        _ = deleteFromKeychain(forKey: lastPremiumClaimKeychainKey)
        DispatchQueue.main.async {
            self.coins = 0
            self.updatePremiumCoinAvailability() // 重置後也更新可用性狀態
        }
        print("CoinManager | ✅ Keychain 數據已重置。")
    }
    #endif
}
