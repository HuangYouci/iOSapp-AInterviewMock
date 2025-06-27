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
        // Home
        case profile
        case profileDeletion
        case appinfo
        case shop
        
        // Tool
        case toolInterview
    }
    
    // 主要元件
    @Published var path: [ViewManagerRoute] = []
    @Published var topView: AnyView? = nil
    
    @Published var rn: Int = 0          // 計算 path 有幾個（用於 onChange）
    
    // MARK: - Public Methods
    /// 返回主畫面
    func homePage() {
        path = []
        calRn()
    }
    
    /// 新增頁數
    func addPage(_ target: ViewManagerRoute) {
        path.append(target)
        calRn()
    }
    
    /// 回到上一頁
    func perviousPage() {
        if (!path.isEmpty){
            path.removeLast()
        }
    }
    
    /// 新增 Top View
    func setTopView(_ view: any View){
        withAnimation {
            topView = AnyView(view)
        }
    }
    
    /// 清除 Top View
    func clearTopView() {
        withAnimation {
            topView = nil
        } 
        calRn()
    }
    
    // MARK: - Private Methods
    private func calRn() {
        var number: Int = 0
        number += path.count
        number += (topView != nil ? 1 : 0) * 10
        rn = number
    }
    
}
