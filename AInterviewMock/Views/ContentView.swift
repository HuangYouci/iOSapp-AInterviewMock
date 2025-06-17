//
//  ContentView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI
import FirebaseAnalytics

struct ContentView: View {
    
    @EnvironmentObject var am: AuthManager
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var co: CoinManager
    
    var body: some View {
        ZStack{
            // MARK: - Views
            NavigationStack(path: $vm.path){
                HomeView()
                    .navigationDestination(for: ViewManager.ViewManagerRoute.self) { route in
                        switch route {
                        case .profile:
                            ProfileView()
                        case .profileDeletion:
                            ProfileDeletionView()
                        }
                    }
            }
            
            // MARK: - Top Views (Top)
            // CO NOTIF
            if (co.showCoinNotification){
                CoinManagerView(amountChanged: co.lastCoinChange, finalAmount: co.coins)
            }
            // UPDATE
            if (UpdateChecker.shared.haveUpdate){
                UpdateCheckerView()
            }
            // AUTH
            if ((am.user == nil)){
                AuthView()
            }
        }
    }
}
