//
//  IAPManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//  Version: No-Backend, Production-Ready
//

import Foundation
import StoreKit

// MARK: - IAPError
/// 定義 IAP 流程中可能發生的特定錯誤，便於在 UI 層處理和顯示。
enum IAPError: LocalizedError {
    case productsLoadFailed(Error)
    case purchaseFailed(Error)
    case purchasePending
    case verificationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .productsLoadFailed(let error):
            return "無法載入商品清單: \(error.localizedDescription)"
        case .purchaseFailed(let error):
            return "購買失敗: \(error.localizedDescription)"
        case .purchasePending:
            return "您的購買正在等待處理中，請稍後。"
        case .verificationFailed:
            return "交易驗證失敗，無法完成購買。"
        case .unknown:
            return "發生未知錯誤，請稍後再試。"
        }
    }
}

// MARK: - Constants
/// 將所有產品 ID 集中管理，避免硬編碼字串。
enum ConstantStoreItems {
    // 在這裡列出你在 App Store Connect 中設定的所有產品 ID
    static let coinSetA = "com.huangyouci.AInterviewMock.iap.coinseta"
    static let coinSetB = "com.huangyouci.AInterviewMock.iap.coinsetb"
    static let monthlySubscription = "com.huangyouci.AInterviewMock.subscription.monthly"
    
    /// 所有產品 ID 的數組，用於一次性獲取全部產品資訊。
    static let productIDs = [coinSetA, coinSetB, monthlySubscription]
}

// MARK: - IAPManager
@MainActor
class IAPManager: ObservableObject {

    // MARK: - Published Properties
    /// 可供購買的產品列表。
    @Published private(set) var products: [Product] = []
    
    /// 用戶已擁有的非消耗品或訂閱產品 ID。
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    /// 指示當前是否有 IAP 相關操作正在進行中。
    @Published private(set) var isLoading: Bool = false
    
    // MARK: - Dependencies & State
    private let userProfileService: UserProfileService
    private var transactionListener: Task<Void, Error>? = nil
    
    /// 用於記錄已處理交易 ID 的本地存儲鍵。
    private let processedTransactionIDsKey = "com.huangyouci.AInterviewMock.processedTransactionIDs"
    /// 內存中的已處理交易 ID 集合，用於快速查找。
    private var processedTransactionIDs: Set<String>

    // MARK: - Initialization
    
    /// 初始化 IAPManager，並注入依賴。
    /// - Parameter userProfileService: 用於處理獎勵發放的服務。
    init(userProfileService: UserProfileService) {
        self.userProfileService = userProfileService
        
        // 從 UserDefaults 加載已處理的交易 ID
        self.processedTransactionIDs = Set(UserDefaults.standard.stringArray(forKey: processedTransactionIDsKey) ?? [])
        print("IAPManager | 初始化，已加載 \(processedTransactionIDs.count) 個已處理的交易 ID。")

        // 啟動交易監聽器，其生命週期與 IAPManager 實例綁定
        transactionListener = Task.detached {
            await self.listenForTransactionUpdates()
        }
        
        // 在背景加載產品，不阻塞 UI
        Task {
            await loadProducts()
        }
        
        print("IAPManager | INIT - 實例正在創建")
    }

    deinit {
        // 當 IAPManager 被銷毀時，取消監聽器以釋放資源
        transactionListener?.cancel()
        
        print("IAPManager | DEINIT - 實例正在銷毀)")
    }
    
    // MARK: - Public Methods
    
    /// 從 App Store 加載所有已定義的產品。
    func loadProducts() async {
        guard !isLoading else { return }
        self.isLoading = true
        print("IAPManager | 開始載入商品...")
        do {
            self.products = try await Product.products(for: ConstantStoreItems.productIDs)
            print("IAPManager | 成功載入 \(self.products.count) 個商品。")
        } catch {
            print("IAPManager | ⛔️ 載入商品失敗: \(error)")
        }
        self.isLoading = false
    }

    /// 啟動購買指定產品的流程。
    /// 此函式只負責發起購買，真正的獎勵發放由 `listenForTransactionUpdates` 處理。
    /// - Parameter product: 要購買的 Product 物件。
    /// - Throws: 如果購買流程啟動失敗，會拋出 `IAPError`。
    func purchase(_ product: Product) async throws {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("IAPManager | ✅ 購買請求成功提交。等待監聽器驗證...")
                await process(verificationResult: verification)
                if case .unverified = verification {
                    throw IAPError.verificationFailed
                }
                
            case .userCancelled:
                print("IAPManager | ℹ️ 使用者取消購買。")
                // 不需要拋出錯誤，這是正常操作
                
            case .pending:
                print("IAPManager | ⏳ 購買待處理，請用戶檢查 App Store。")
                throw IAPError.purchasePending
                
            @unknown default:
                throw IAPError.unknown
            }
        } catch let error as IAPError {
            throw error
        } catch {
            print("IAPManager | ⛔️ 購買流程啟動失敗: \(error)")
            throw IAPError.purchaseFailed(error)
        }
    }
    
    /// 觸發 App Store 的還原購買流程，主要用於非消耗品和訂閱。
    func restorePurchases() async {
        self.isLoading = true
        print("IAPManager | 開始還原購買...")
        do {
            try await AppStore.sync()
        } catch {
            print("IAPManager | ⛔️ 還原購買失敗: \(error)")
        }
        self.isLoading = false
        print("IAPManager | 還原購買流程完成。")
    }
    
    /// 根據產品 ID 獲取本地化的價格字串。
    /// - Parameter productID: 你在 App Store Connect 中設定的產品 ID。
    /// - Returns: 一個格式化好的價格字串 (例如 "$0.99" 或 "NT$30")。如果找不到該產品，則返回 "N/A"。
    func priceString(for productID: String) -> String {
        // 從內存中的 products 陣列中查找對應的產品
        guard let product = products.first(where: { $0.id == productID }) else {
            // 如果產品列表還沒加載完成，或 ID 不存在，返回一個預設值
            return "N/A"
        }
        
        // 返回 StoreKit 為我們格式化好的 displayPrice
        return product.displayPrice
    }

    // MARK: - Core Transaction Handling
    
    /// 持續監聽來自 App Store 的交易更新。這是所有交易處理的唯一入口點。
    private func listenForTransactionUpdates() async {
        print("IAPManager | 開始監聽交易更新...")
        for await verificationResult in Transaction.updates {
            print("IAPManager | 偵測到交易更新: \(verificationResult)")
            await self.process(verificationResult: verificationResult)
        }
        print("IAPManager | 交易監聽器意外終止")
    }

    /// 處理單個交易的核心邏輯。
    private func process(verificationResult: VerificationResult<Transaction>) async {
        // 1. StoreKit 初步驗證
        guard case .verified(let transaction) = verificationResult else {
            print("IAPManager | 監聽器捕獲到未驗證的交易，忽略。")
            return
        }

        print("IAPManager | 監聽器捕獲到已驗證交易 ID: \(transaction.id)，產品 ID: \(transaction.productID)")
        
        // 2. 檢查此交易 ID 是否已被處理過，防止重複發放
        let transactionIDString = String(transaction.id)
        guard !processedTransactionIDs.contains(transactionIDString) else {
            print("IAPManager | 警告: 交易 \(transaction.id) 已被處理過，忽略重複請求。")
            await transaction.finish() // 即使是重複的，也完成它以停止 StoreKit 的重試
            return
        }

        // 3. 處理獎勵發放
        if transaction.productType == .consumable {
            await grantConsumableReward(for: transaction)
        } else {
            // 對於訂閱或非消耗品，更新本地已購買狀態
            purchasedProductIDs.insert(transaction.productID)
        }

        // 4. 標記交易為已處理，並持久化記錄
        processedTransactionIDs.insert(transactionIDString)
        UserDefaults.standard.set(Array(processedTransactionIDs), forKey: processedTransactionIDsKey)
        print("IAPManager | 交易 \(transaction.id) 已標記為處理完畢。")

        // 5. 完成交易
        await transaction.finish()
        print("IAPManager | ✅ 交易 \(transaction.id) 已成功處理並完成。")
    }

    /// 發放消耗品獎勵的具體實現。
    private func grantConsumableReward(for transaction: Transaction) async {
        let coinAmount: Int
        switch transaction.productID {
        case ConstantStoreItems.coinSetA:
            coinAmount = 100
        case ConstantStoreItems.coinSetB:
            coinAmount = 300
        default:
            print("IAPManager | 警告: 收到未知的消耗品 ID: \(transaction.productID)")
            return
        }
        
        // 調用 UserProfileService 的 pendingCoins 機制，確保獎勵能可靠地送達用戶
        print("IAPManager | 準備將 \(coinAmount) 枚金幣設為待處理...")
        // 這裡的 userProfileService 是被注入的，遵循了依賴反轉原則
        userProfileService.coinRequest(type: .add(item: "代幣購買"), amount: coinAmount, onConfirm: {
            self.userProfileService.setGetPendingCoins(amount: 0)
        })
        
        userProfileService.setGetPendingCoins(amount: coinAmount)
    }
}

