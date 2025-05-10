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
            HomeForceUpdateView(whatsNew: $whatsNew, newestVersion: $newestVersion)
        }
        .onAppear {
            checkAppStoreVersion()
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
        guard let bundleId = Bundle.main.bundleIdentifier else {
            print("HomeView | Error: Could not get bundle identifier.")
            return
        }
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            print("HomeView | Error: Invalid URL.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 1. 檢查網路錯誤
            if let error = error {
                print("HomeView | Network error: \(error.localizedDescription)")
                return
            }
            
            // 2. 檢查 HTTP 響應
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("HomeView | Server error: \(String(describing: response))")
                return
            }
            
            // 3. 檢查數據
            guard let data = data else {
                print("HomeView | No data received.")
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                // print("HomeView | Raw API Response: \(String(describing: result))") // 調試時可以打開
                
                guard let resultsArray = result?["results"] as? [[String: Any]],
                      let appInfo = resultsArray.first,
                      let appStoreVersion = appInfo["version"] as? String,
                      let releaseNotes = appInfo["releaseNotes"] as? String else {
                    print("HomeView | Could not parse app version or release notes from response.")
                    if let resultCount = result?["resultCount"] as? Int, resultCount == 0 {
                        print("HomeView | No app found with the given bundle ID in App Store.")
                    }
                    return
                }
                
                guard let currentVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                    print("HomeView | Could not get current app version.")
                    return
                }
                
                let currentVersionComponents = currentVersionString.split(separator: ".").compactMap { Int($0) }
                let appStoreVersionComponents = appStoreVersion.split(separator: ".").compactMap { Int($0) }
                
                // 確保版本號格式基本一致，或者你可以根據需求做更複雜的比較
                // 這裡假設版本號至少有一個組件
                if currentVersionComponents.isEmpty || appStoreVersionComponents.isEmpty {
                    print("HomeView | Invalid version format. Current: \(currentVersionString), AppStore: \(appStoreVersion)")
                    return
                }
                
                // 逐個比較版本組件
                // 例如: "1.2.3" vs "1.3.0"
                if currentVersionComponents.lexicographicallyPrecedes(appStoreVersionComponents, by: <) {
                    DispatchQueue.main.async {
                        print("HomeView | Update available! New version: \(appStoreVersion), Release Notes: \(releaseNotes)")
                        whatsNew = releaseNotes
                        newestVersion = appStoreVersion
                        forceUpdate = true
                    }
                } else {
                    print("HomeView | App is up to date. Current: \(currentVersionString), AppStore: \(appStoreVersion)")
                }
                
            } catch {
                print("HomeView | Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

struct HomeForceUpdateView: View {
    @Binding var whatsNew: String
    @Binding var newestVersion: String
    var body: some View {
        VStack {
            Spacer()
            Link(destination: URL(string: "https://apps.apple.com/tw/app/id6745684106")!){
                VStack(alignment: .leading){
                    Text(NSLocalizedString("HomeView_updateAppTitle", comment: "Title for the force update screen"))
                        .font(.title)
                        .bold()
                    Text(NSLocalizedString("HomeView_updateAppMessage", comment: "Message instructing user to update from App Store"))
                        .multilineTextAlignment(.leading)
                    Color.clear
                        .frame(height: 10)
                    HStack{
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("HomeView_currentVersionLabel", comment: "Label for current app version"))
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                                .font(.title3)
                        }
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("HomeView_latestVersionLabel", comment: "Label for latest app version available"))
                            Text(newestVersion)
                                .font(.title3)
                        }
                    }
                    Color.clear
                        .frame(height: 10)
                    ScrollView {
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("HomeView_updateNotesLabel", comment: "Label for what's new/release notes section"))
                            Text(whatsNew)
                                .multilineTextAlignment(.leading)
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
            }
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

#Preview {
    HomeView()
}
