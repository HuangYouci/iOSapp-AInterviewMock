//
//  ViewManager.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/13.
//

import SwiftUI

class ViewManager: ObservableObject {
    
    static let shared = ViewManager()
 
    // 主要元件
    @Published var viewStack: [AnyView] = [AnyView(HomeView())]
    @Published var topView: AnyView?
    
    // 顯示動畫
    @Published var lastViewId: Int = 0      // 動畫 ID
    @Published var leaving: Bool = false    // 是否為離開頁面 (動畫控制)
    
    // View Memory
    @Published var viewStates: [String: Any] = [:]
    
    // MARK: - Public Methods
    /// 返回主畫面
    func backHomePage() {
        leaving = true
        withAnimation(.easeInOut(duration: 0.3)){
            viewStack.removeSubrange(1...)
        }
    }
    
    /// 新增頁數
    func addPage(view: any View) {
        leaving = false
        withAnimation(.easeInOut(duration: 0.3)){
            viewStack.append(AnyView(view))
        }
    }
    
    /// 回到上一頁
    func perviousPage() {
        guard viewStack.count > 1 else { return }
        leaving = true
        _ = withAnimation(.easeInOut(duration: 0.3)){
            viewStack.removeLast()
        }
    }
    
    /// 設定最上層
    func setTopView(view: any View) {
        withAnimation(.easeInOut(duration: 0.2)){
            topView = AnyView(view)
        }
    }
    
    func clearTopView(){
        withAnimation(.easeInOut(duration: 0.2)){
            topView = nil
        }
    }

    /// Memory: 讀取狀態
    func getState(state: String) -> Any? {
        print("ViewManager | Get state \(state) is \(viewStates[state] ?? "null").")
        return viewStates[state]
    }
    
    /// Memory: 設定狀態
    func setState(state: String, value: Any) {
        print("ViewManager | Set state \(state) to \(value).")
        viewStates[state] = value
    }
        
}
