//
//  ContentView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI
import FirebaseAnalytics

struct ContentView: View {
    
    @EnvironmentObject var usp: UserProfileService
    @EnvironmentObject var am: AuthManager
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var co: CoinManager
    @EnvironmentObject var uc: UpdateChecker
    
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
                        case .appinfo:
                            InfoView()
                        case .shop:
                            ShopView()
                        case .toolInterview:
                            InterviewView()
                        }
                    }
            }
            
            // MARK: - Top Views (Top)
            // COIN
            if (usp.pendingModifyCoinNumber > 0){
                CoinModView()
            }
            // UPDATE
            if ((uc.status == .lower)){
                UpdateInfoView()
            }
            // AUTH ( BE SURE AT TOP TOP )
            if ((am.user == nil)){
                AuthView()
            }
        }
    }
}
