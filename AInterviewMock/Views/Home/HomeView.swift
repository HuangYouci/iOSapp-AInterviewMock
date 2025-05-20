//
//  HomeView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct HomeView: View {
    
    @State private var currentPage: Int = 0
    @State private var whatsNew: String = "Error"
    @State private var newestVersion: String = "E"
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                
                HStack{
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Text(NSLocalizedString("HomeView_appTitle", comment: "The main title of the application"))
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color(.accent))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        .foregroundStyle(Color(.systemGray))
                }
                .padding(.bottom)
                .padding(.horizontal)
                
                switch(currentPage){
                case 0:
                    HomeEntryView()
                case 1:
                    ListView()
                case 2:
                    CoinView()
                default:
                    Color.clear
                }
                
                Divider()
                HStack(spacing: 30){
                    Spacer()
                    barBuilder(page: 2, icon: "hockey.puck")
                    barBuilder(page: 0, icon: "house")
                    barBuilder(page: 1, icon: "list.bullet")
                    Spacer()
                }
                .padding(20)
            }
        }
        .onAppear {
            // 讀取頁面狀態
            currentPage = ViewManager.shared.getState(state: "HomeViewCurrentPage") as? Int ?? 0
            // 檢查更新
            if (UpdateChecker.shared.haveUpdate){
                ViewManager.shared.addPage(view: UpdateCheckerView())
            }
        }
        .onChange(of: currentPage){ _ in
            ViewManager.shared.setState(state: "HomeViewCurrentPage", value: currentPage)
        }
    }
    
    private func barBuilder(page: Int, icon: String) -> some View {
        VStack{
            Image(systemName: "\(icon)")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            if (currentPage == page){
                Circle()
                    .frame(width: 5, height: 5)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)){
                currentPage = page
            }
        }
    }
    
}

#Preview {
    HomeView()
}
