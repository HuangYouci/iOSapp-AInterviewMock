//
//  ProfileDeletionView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/17.
//

import SwiftUI
import FirebaseCore

struct ProfileDeletionView: View {
    
    @EnvironmentObject var ups: UserProfileService
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var am: AuthManager
    
    @State private var loadedTimeSec: Int = 0
    @State private var timer: Timer?
    @State private var deletedFailed: String?
    
    var body: some View {
        VStack(spacing: 0){
            if let up = ups.currentUserProfile {
                ScrollView{
                    VStack(alignment: .leading){
                        HStack{
                            Button{
                                vm.perviousPage()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(8)
                                    .background(Color("AccentColorP1"))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Text("inif")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                            Spacer()
                        }
                        .foregroundStyle(Color(.white))
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        
                        VStack {
                            Text(up.userName ?? "inif")
                                .font(.title)
                                .bold()
                            if let email = up.userEmail {
                                Text(email)
                                    .tint(Color(.white))
                                    .font(.title3)
                            }
                            HStack(spacing: 5){
                                Text("inifid")
                                    .fontWeight(.heavy)
                                Text("#\(up.userId)")
                            }
                            .padding(8)
                            .background(Color("AccentColorP1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(25)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color(.white))
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("刪除帳號")
                                    .font(.title3)
                                    .foregroundStyle(Color("AccentColorP1"))
                                    .bold()
                                Spacer()
                            }
                            Text("你確定要刪除帳號？這將會刪除你帳號中的所有資訊（未上傳伺服器之本機資料仍會存留，您可透過刪除 app 來手動移除）。此操作不可逆！觀看廣告或是付費購買的代幣將會清空，且無法退款。")
                            Text("這將解除登入之 Apple 或 Google 帳號對本程式伺服器帳號的綁定。您仍可透過相同帳號進行重註冊。")
                            
                            VStack{
                                Button {
                                    am.coordinateAccountDeletion { error in
                                        if let error = error {
                                            deletedFailed = error.errorDescription
                                        } else {
                                            vm.homePage()
                                        }
                                    }
                                } label: {
                                    HStack{
                                        Text("確認刪除帳號")
                                            .foregroundStyle(Color( loadedTimeSec < 10 ? .systemGray : .red))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color(.systemGray))
                                            .frame(width: 15, height: 15)
                                    }
                                }
                                .disabled(loadedTimeSec < 10)
                            }
                            .padding()
                            .background(Color("AccentColorR5"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.bottom, 10)
                            
                            if let em = deletedFailed {
                                VStack(alignment: .leading){
                                    HStack{
                                        Text("錯誤")
                                            .bold()
                                        Spacer()
                                    }
                                    Text(em)
                                }
                                .padding(10)
                                .background(Color(.red).opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color(.red), lineWidth: 1)
                                )
                            } else {
                                if (loadedTimeSec < 10){
                                    Text("請再等候 \(10 - loadedTimeSec) 秒方可刪除。")
                                }
                                Text("按下本按鈕後將會登出帳號並立刻進行刪除作業。")
                            }
                        }
                        .padding(25)
                        .frame(maxWidth: .infinity)
                        .background(Color("Background"))
                        .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                    }
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .fixedSize(horizontal: false, vertical: true)
                Color("Background")
                    .ignoresSafeArea(edges: [.bottom])
            } else {
                LoadView(loadingTitle: "個人資料載入中")
            }
        }
        .background(Color.accentColor)
        .navigationBarHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            loadedTimeSec += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ProfileDeletionView()
}
