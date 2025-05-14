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
                        .frame(width: 35, height: 35)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text(NSLocalizedString("HomeView_appTitle", comment: "The main title of the application"))
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color(.accent))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        .foregroundStyle(Color(.systemGray))
                }
                .padding(.bottom)
                .padding(.horizontal)
                .background(Color(.systemBackground).opacity(0.3))
                .background(.ultraThinMaterial)
                
                switch(currentPage){
                case 0:
                    HomeEntryView(currentPage: $currentPage)
                case 1:
                    HomeListView()
                default:
                    Color.clear
                }
            }
            VStack{
                Spacer()
                HStack(spacing: 30){
                    barBuilder(page: 0, icon: "house")
                    barBuilder(page: 1, icon: "list.bullet")
                }
                .padding()
                .padding(.horizontal)
                .background(Color(.black).opacity(0.3))
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(radius: 5)
                .padding()
            }
        }
        .background(Color(.systemBackground))
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
                .foregroundStyle(Color(.white))
                .shadow(radius: 1)
            if (currentPage == page){
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(Color(.white))
                    .shadow(radius: 1)
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
