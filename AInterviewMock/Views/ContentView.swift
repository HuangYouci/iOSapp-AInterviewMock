//
//  ContentView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI
import FirebaseAnalytics

struct ContentView: View {
    
    @EnvironmentObject var ups: UserProfileService
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
                        case .diaryView:
                            DiaryView()
                        }
                    }
            }
            
            ZStack{
                if let tv = vm.topView {
                    tv
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut, value: vm.rn)
            
            // MARK: - Top Views (Top)
            // COIN
            if (ups.coinModifyRequest != nil){
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
