//
//  HomeListView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI

struct HomeListView: View {
    
    @State private var profiles: [InterviewProfile] = []
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                ForEach(profiles){ item in
                    profileCard(i: item)
                    .onTapGesture {
                        ViewManager.shared.addPage(view: InterviewAnalysisView(selected: .constant(item)))
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .onAppear {
            profiles = DataManager.shared.loadAllInterviewProfiles()
        }
        
    }
    
    // MARK: - 卡片視覺建造
    @ViewBuilder
    private func profileCard(i: InterviewProfile) -> some View {
        switch (i.status){
        case 4: // 完成
            profileCardCompleted(i: i)
        case 3: // 全部作答完畢等待生成｜生成失敗（意外退出，需再次分析）
            EmptyView()
        case 2: // 生成完問題，開始作答｜作答中離開，未來處裡
            EmptyView()
        case 1: // 問題填答完畢，暫存中｜恢復
            profileCardDraft(i: i)
        case 0: // 剛開始設置｜不處理
            EmptyView()
        default:
            EmptyView()
        }
    }
    
    private func profileCardCompleted(i: InterviewProfile) -> some View {
        VStack(alignment: .leading, spacing: 10){
            HStack{
                Text(i.templateName)
                    .font(.title)
                    .bold()
                Spacer()
            }
            Text({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                return formatter.string(from: i.date)
            }())
            .padding(.top, 20)
        }
        .foregroundStyle(Color(.white))
        .padding()
        .background(
            Image(systemName: "\(i.templateImage)")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .offset(x: 160, y: 30)
                .foregroundStyle(Color(.white))
        )
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 52 / 255, green: 41 / 255, blue: 157 / 255),
                    Color(red: 108 / 255, green: 106 / 255, blue: 237 / 255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    private func profileCardDraft(i: InterviewProfile) -> some View {
        VStack(alignment: .leading, spacing: 10){
            HStack{
                Text("草稿")
                    .padding(3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                Color(.white),
                                lineWidth: 1
                            )
                    )
                Text(i.templateName)
                    .font(.title)
                    .bold()
                Spacer()
            }
            Text({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                return formatter.string(from: i.date)
            }())
            .padding(.top, 20)
        }
        .foregroundStyle(Color(.white))
        .padding()
        .background(
            Image(systemName: "\(i.templateImage)")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .offset(x: 160, y: 30)
                .foregroundStyle(Color(.white))
        )
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 92 / 255, green: 92 / 255, blue: 92 / 255),
                    Color(red: 52 / 255, green: 52 / 255, blue: 52 / 255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
}

#Preview {
    HomeView()
}

#Preview{
    HomeListView()
}
