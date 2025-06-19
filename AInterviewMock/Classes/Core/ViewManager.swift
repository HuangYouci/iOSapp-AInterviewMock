//
//  ViewManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/13.
//

import SwiftUI

class ViewManager: ObservableObject {
    
    static let shared = ViewManager()
    
    enum ViewManagerRoute: Hashable {
        case profile
        case profileDeletion
        case appinfo
        case shop
    }
    
    // 主要元件
    @Published var path: [ViewManagerRoute] = []
    
    // 通知元件
    /// Coin Modify Notification
    @Published var coinModNot: Bool = false
    @Published var coinModLast: Int = 0
    
    // MARK: - Public Methods
    /// 返回主畫面
    func homePage() {
        path = []
    }
    
    /// 新增頁數
    func addPage(_ target: ViewManagerRoute) {
        path.append(target)
    }
    
    /// 回到上一頁
    func perviousPage() {
        if (!path.isEmpty){
            path.removeLast()
        }
    }
}
