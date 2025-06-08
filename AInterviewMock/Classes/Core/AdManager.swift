//
//  AdManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import Foundation
import GoogleMobileAds
import SwiftUI

@MainActor
class AdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = AdManager()

    @Published var isAdLoaded = false
    private var rewardedAd: RewardedAd?

    /// 自動切換測試與正式環境的廣告單元 ID
    private let adUnitID: String = {
        #if DEBUG
        return "ca-app-pub-3940256099942544/1712485313" // 測試廣告 ID
        #else
        return "ca-app-pub-4733744894615858/8699412783" // 你的正式廣告 ID
        #endif
    }()

    override private init() {
        super.init()
        MobileAds.shared.start(completionHandler: nil)
        loadRewardedAd()
    }

    /// 載入獎勵廣告
    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("AdManager | 獎勵廣告載入失敗: \(error.localizedDescription)")
                self?.isAdLoaded = false
            } else {
                print("AdManager | 獎勵廣告載入成功")
                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isAdLoaded = true
            }
        }
    }

    /// 顯示獎勵廣告
    func showAd(from rootViewController: UIViewController, onReward: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("AdManager | 廣告尚未準備好")
            return
        }

        ad.present(from: rootViewController) {
            print("AdManager | 用戶獲得獎勵！")
            onReward()
        }
    }

    /// 廣告播放完畢或關閉時，重新載入下一個廣告
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("AdManager | 廣告關閉，準備重新載入")
        loadRewardedAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AdManager | 廣告展示失敗：\(error.localizedDescription)")
        isAdLoaded = false
        loadRewardedAd()
    }
}
