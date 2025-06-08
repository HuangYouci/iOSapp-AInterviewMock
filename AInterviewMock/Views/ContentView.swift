//
//  ContentView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI
import FirebaseAnalytics

struct ContentView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var vm = ViewManager.shared
    @ObservedObject var co = CoinManager.shared
    
    var body: some View {
        ZStack{
            // MARK: - Views (Vm)
            // VM STACK
            vm.viewStack.last!
                .background(Color(.systemBackground))
                .id(vm.viewStack.count)
                .transition(
                    vm.leaving ?
                        .asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.85, anchor: .center).combined(with: .opacity)
                        ) :
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .opacity
                        )
                 )
            
            vm.topView
                .id("topViewIdentifier")
                .transition(.opacity)
            
            // MARK: - Top Views (Top)
            // CO NOTIF
            if (co.showCoinNotification){
                CoinManagerView(amountChanged: co.lastCoinChange, finalAmount: co.coins)
            }
            // Auth
            if ((authManager.user == nil)){
                AuthView()
            }
        }
    }
}
