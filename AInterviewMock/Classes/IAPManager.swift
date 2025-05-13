//
//  IAPManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

// Huangyouci IAP General v2

import Foundation
import StoreKit

@MainActor
class IAPManager: ObservableObject {
    static let shared = IAPManager()
    
    @Published var products: [Product] = []
    @Published var hasSubscription: Bool = false
    
    private init() {
        Task {
            await updateProducts()
            await checkSubscriptionStatus()
            await listenForTransactionUpdates()
        }
    }
    
    /// 所有商品 ID（包含訂閱、一次性購買）
    let productIDs: [String] = [
        "com.huangyouci.AInterviewMock.subscription.monthly",
        "com.huangyouci.AInterviewMock.iap.coinseta",
        "com.huangyouci.AInterviewMock.iap.coinsetb"
    ]
    
    func listenForTransactionUpdates() async {
        for await update in Transaction.updates {
            switch update {
            case .verified(let transaction):
                print("IAPManager | 偵測到購買：\(transaction.productID)")
                await transaction.finish()
                await checkSubscriptionStatus()
            case .unverified:
                print("IAPManager | 有未驗證的交易")
                continue
            }
        }
    }

    
    /// 抓取產品資訊
    func updateProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("IAPManager | 產品載入失敗：\(error)")
        }
    }
    
    /// 購買指定產品
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .unverified:
                    print("IAPManager | 購買未通過驗證")
                    return false
                case .verified(let transaction):
                    print("IAPManager | 購買成功：\(transaction.productID)")
                    await transaction.finish()
                    if transaction.productType == .consumable {
                            await grantConsumableReward(for: transaction.productID)
                        } else if transaction.productType == .autoRenewable {
                            await checkSubscriptionStatus()
                        }
                    AnalyticsHolder.shared.purchaseItem(productId: product.id)
                    return true
                }
            case .userCancelled:
                print("IAPManager | 使用者取消購買")
            case .pending:
                print("IAPManager | 購買待處理")
            @unknown default:
                break
            }
        } catch {
            print("IAPManager | 購買失敗：\(error)")
        }
        return false
    }
    
    /// 還原購買
    func restorePurchases() async {
        do {
            let _ = try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            print("IAPManager | 還原購買失敗：\(error)")
        }
    }
    
    /// 檢查訂閱狀態
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productType == .autoRenewable {
                    hasSubscription = true
                    return
                }
            case .unverified:
                continue
            }
        }
        hasSubscription = false
    }
    
    /// 根據 ID 取得格式化價格
    func priceString(for id: String) -> String {
        guard let product = products.first(where: { $0.id == id }) else { return "N/A" }
        return product.displayPrice
    }
    
    func grantConsumableReward(for productID: String) async {
        switch productID {
        case "com.huangyouci.AInterviewMock.iap.coinseta":
            CoinManager.shared.addCoin(100)
        case "com.huangyouci.AInterviewMock.iap.coinsetb":
            CoinManager.shared.addCoin(300)
        default:
            break
        }
    }

}
