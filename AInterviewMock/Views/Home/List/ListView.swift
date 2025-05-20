//
//  HomeListView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI

struct ListView: View {
    
    enum ListViewPage: Equatable {
        case interview
        case speech
    }
    
    @State private var currentPage: ListViewPage = .interview
    
    @State private var interview: [InterviewProfile] = []
    @State private var speech: [SpeechProfile] = []
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
            Color.clear
                .frame(height: 10)
            
            VStack{
                HStack(spacing: 10){
                    pageTab(title: "模擬面試", page: .interview)
                    pageTab(title: "模擬演講", page: .speech)
                }
                .padding(.horizontal)
                Divider()
            }
            
            ScrollView{
                switch(currentPage){
                case .interview:
                    ForEach(interview){ item in
                        interviewCard(i: item)
                    }
                case .speech:
                    ForEach(speech){ item in
                        speechCard(i: item)
                    }
                }
                
            }
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .onAppear {
            interview = DataManager.shared.loadAllInterviewProfiles()
            speech = DataManager.shared.loadAllSpeechProfiles()
            
            // 讀取頁面狀態
            let ts = ViewManager.shared.getState(state: "ListViewCurrentPage") as? Int ?? 0
            switch(ts){
            case 1:
                currentPage = .speech
            default: // case 0
                currentPage = .interview
            }
        }
        .onChange(of: currentPage){ _ in
            switch(currentPage){
            case .interview:
                ViewManager.shared.setState(state: "ListViewCurrentPage", value: 0)
            case .speech:
                ViewManager.shared.setState(state: "ListViewCurrentPage", value: 1)
            }
        }
        
    }
    
    @ViewBuilder
    private func pageTab(title: String, page: ListViewPage) -> some View {
        VStack{
            Text(title)
                .padding(.horizontal, 10)
                .background(
                    Rectangle()
                        .fill(Color(currentPage == page ? .accent : .clear))
                        .frame(height: 5)
                        .offset(y: 20)
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)){
                currentPage = page
            }
        }
    }
    
    @ViewBuilder
    private func interviewCard(i: InterviewProfile) -> some View {
        switch (i.status){
        case 4: // 完成
            VStack{
                VStack(alignment: .leading, spacing: 10){
                    HStack{
                        Text(i.templateName)
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text({
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd HH:mm"
                            return formatter.string(from: i.date)
                        }())
                        .foregroundStyle(Color(.systemGray))
                    }
                    Text(i.templateDescription)
                        .lineLimit(1)
                }
                .padding()
                .onTapGesture {
                    ViewManager.shared.addPage(view: InterviewAnalysisView(selected: .constant(i)))
                }
                Divider()
            }
        case 3: // 全部作答完畢等待生成｜生成失敗（意外退出，需再次分析）
            EmptyView()
        case 2: // 生成完問題，開始作答｜作答中離開，未來處裡
            EmptyView()
        case 1: // 問題填答完畢，暫存中｜恢復
            EmptyView()
        case 0: // 剛開始設置｜不處理
            EmptyView()
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func speechCard(i: SpeechProfile) -> some View {
        switch (i.status){
        default:
            VStack{
                VStack(alignment: .leading, spacing: 10){
                    HStack{
                        Text(i.templateName)
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text({
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd HH:mm"
                            return formatter.string(from: i.date)
                        }())
                        .foregroundStyle(Color(.systemGray))
                    }
                    Text(i.speechContent)
                        .lineLimit(1)
                }
                .padding()
                .onTapGesture {
                    ViewManager.shared.addPage(view: SpeechAnalysisView(selected: .constant(i)))
                }
                Divider()
            }
        }
    }
        
}

#Preview {
    HomeView()
}

#Preview{
    ListView()
}
