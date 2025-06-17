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
                    pageTab(title: NSLocalizedString("ListView_MockInterview", comment: "Tab subment for Mock Interview"), page: .interview)
                    pageTab(title: NSLocalizedString("ListView_MockSpeech", comment: "Tab subment for Mock Speech"), page: .speech)
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
            .contentShape(Rectangle())
            .onTapGesture {
                // ViewManager.shared.addPage(view: InterviewAnalysisView(selected: .constant(i)))
            }
            Divider()
        }
    }
    
    @ViewBuilder
    private func speechCard(i: SpeechProfile) -> some View {
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
            .contentShape(Rectangle())
            .onTapGesture {
                // ViewManager.shared.addPage(view: SpeechAnalysisView(selected: .constant(i)))
            }
            Divider()
        }
    }
        
}

#Preview {
    HomeView()
}

#Preview{
    ListView()
}
