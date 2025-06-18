//
//  ProfileView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/16.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    
    @EnvironmentObject var ups: UserProfileService
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var am: AuthManager
    
    var body: some View {
        VStack(spacing: 0){
            if let up = ups.currentUserProfile {
                HStack{
                    Button{
                        vm.perviousPage()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .background(Color("AccentBackgroundP1"))
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
                .padding(.bottom, 5)
                
                ScrollView{
                    VStack(alignment: .leading){
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
                            .background(Color("AccentBackgroundP1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(25)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color(.white))
                        
                        VStack(alignment: .leading){
                            Text("帳號資訊")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                            VStack{
                                HStack{
                                    Text("代幣")
                                    Spacer()
                                    Text("\(up.coins)")
                                        .foregroundStyle(Color(.systemGray))
                                }
                                Divider()
                                    .padding(.vertical, 6.5)
                                HStack{
                                    Text("帳號創建日期")
                                    Spacer()
                                    Text(formatDate(up.creationDate!))
                                        .foregroundStyle(Color(.systemGray))
                                }
                            }
                            .padding()
                            .background(Color("BackgroundR1"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.bottom, 10)
                            
                            Text("帳號操作")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                            VStack{
                                Button {
                                    am.signOut()
                                    vm.homePage()
                                } label: {
                                    HStack{
                                        Text("登出")
                                            .foregroundStyle(Color(.red))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color(.systemGray))
                                            .frame(width: 15, height: 15)
                                    }
                                }
                                Divider()
                                    .padding(.vertical, 6.5)
                                Button {
                                    vm.addPage(.profileDeletion)
                                } label: {
                                    HStack{
                                        Text("刪除帳號")
                                            .foregroundStyle(Color(.red))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(Color(.systemGray))
                                            .frame(width: 15, height: 15)
                                    }
                                }
                            }
                            .padding()
                            .background(Color("BackgroundR1"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.bottom, 10)
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
        .background(Color("AccentBackground"))
        .navigationBarHidden(true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}


#Preview {
    VStack(spacing: 0){
        VStack{
            ProgressView()
            Text("帳號資訊載入中")
            Text("請確保網路連線。若等待許久未果，請嘗試重啟 app。")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(Color(.white))
    }
    .background(Color.accentColor)
}
