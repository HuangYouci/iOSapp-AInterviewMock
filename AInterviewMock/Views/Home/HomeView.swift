//
//  HomeView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct HomeView: View {
    
    @State private var currentPage = 0
    @State private var forceUpdate = false
    @State private var whatsNew: String = "Error"
    @State private var newestVersion: String = "E"
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("模擬面試")
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
                .padding(.bottom)
                
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
        .fullScreenCover(isPresented: $forceUpdate) {
            VStack {
                Spacer()
                VStack(alignment: .leading){
                    Text("更新程式")
                        .font(.title)
                        .bold()
                    Text("本程式已推出最新版本，請至 App Store 更新本程式。")
                    Color.clear
                        .frame(height: 10)
                    HStack{
                        VStack(alignment: .leading){
                            Text("目前版本")
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                                .font(.title3)
                        }
                        VStack(alignment: .leading){
                            Text("最新版本")
                            Text(newestVersion)
                                .font(.title3)
                        }
                    }
                    Color.clear
                        .frame(height: 10)
                    ScrollView {
                        VStack(alignment: .leading){
                            Text("更新內容")
                            Text(whatsNew)
                        }
                    }
                    .frame(maxHeight: 100)
                    .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                }
                .foregroundStyle(Color(.white))
                .padding()
                .background(Color(.black).opacity(0.3))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
                .padding(.horizontal)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image("updatebg")
                    .resizable()
                    .scaledToFill()
            )
            .ignoresSafeArea()
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
    
    private func checkAppStoreVersion() {
            guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.huangyouci.AInterviewMock") else { return }
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else { return }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let results = result?["results"] as? [[String: Any]],
                       let appStoreVersion = results.first?["version"] as? String,
                       let releaseNotes = results.first?["releaseNotes"] as? String {
                        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           currentVersion < appStoreVersion {
                            // 更新內容
                            DispatchQueue.main.async {
                                whatsNew = releaseNotes
                                newestVersion = appStoreVersion
                                forceUpdate = true
                            }
                        }
                    }
                } catch {
                    print("HomeView | Error checking App Store version: \(error)")
                }
            }
            task.resume()
        }
}

#Preview {
    HomeView()
}
