//
//  InterviewAnalysisView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI

/// Interview 結果頁
/// 傳入 selected Binding 作為顯示資料的依據
/// 如果 InterviewProfile 的 status 為 4 則顯示結果，為 1 則顯示未完成
struct InterviewAnalysisView: View {
    
    @Binding var selected: InterviewProfile
    
    var body: some View {
        ScrollView{
            HStack{
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text(NSLocalizedString("HomeListView_coinViewTitle", comment: "Title displayed at the top of the coin list screen"))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(.accent))
                Spacer()
                Button {
                    ViewManager.shared.backHomePage()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            .background(Color(.systemBackground).opacity(0.3))
            .background(.ultraThinMaterial)
            
            switch (selected.status){
            case 4: // 完成
                VStack(alignment: .leading, spacing: 20){
                    // Header
                    VStack(alignment: .leading, spacing: 10){
                        HStack{
                            Text(selected.templateName)
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        Text(selected.templateDescription)
                        Text({
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd HH:mm"
                            return formatter.string(from: selected.date)
                        }())
                        .padding(.top, 40)
                    }
                    .foregroundStyle(Color(.white))
                    .padding()
                    .background(
                        Image(systemName: "\(selected.templateImage)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .offset(x: 160, y: 70)
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
                    
                    // Overall Rating
                    VStack(alignment: .leading){
                        Text(NSLocalizedString("InterviewAnalysisView_overallRatingSectionTitle", comment: "Section title for 'Overall Rating'"))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.horizontal)
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "star.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.accent))
                                Text(NSLocalizedString("InterviewAnalysisView_overallRatingLabel", comment: "Label for 'Overall Rating' value"))
                                    .bold()
                                Spacer()
                            }
                            Text("\(selected.overallRating)")
                                .bold()
                                .font(.largeTitle)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.accentColor ,
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                    }
                    
                    // Feedback
                    VStack(alignment: .leading){
                        Text(NSLocalizedString("InterviewAnalysisView_feedbackSectionTitle", comment: "Section title for 'Feedback' (overall comments)"))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.horizontal)
                        ForEach(selected.feedbacks) { item in
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "star.bubble.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color(.accent))
                                    Text(NSLocalizedString("InterviewAnalysisView_feedbackItemLabel", comment: "Label for an individual feedback item/comment"))
                                        .bold()
                                    Spacer()
                                    if (item.positive){
                                        Image(systemName: "hand.thumbsup.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color("AppGreen"))
                                    }
                                }
                                Text(item.content)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.accentColor ,
                                        lineWidth: 2
                                    )
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Each Question Feedback
                    VStack(alignment: .leading){
                        Text(NSLocalizedString("InterviewAnalysisView_answersSectionTitle", comment: "Section title for 'Answers' (per-question analysis)"))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.horizontal)
                        ForEach(selected.questions) { item in
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "bubble.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color(.accent))
                                    Text(NSLocalizedString("InterviewAnalysisView_qnaItemLabel", comment: "Label for an individual question-answer item"))
                                        .bold()
                                    Spacer()
                                }
                                Text(NSLocalizedString("InterviewAnalysisView_questionSublabel", comment: "Sublabel for 'Question' within Q&A item"))
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.caption)
                                    .padding(.top, 5)
                                Text(item.question)
                                
                                Text(NSLocalizedString("InterviewAnalysisView_answerSublabel", comment: "Sublabel for 'Answer' within Q&A item"))
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.caption)
                                    .padding(.top, 5)
                                Text(item.answer)
                                
                                Text(NSLocalizedString("InterviewAnalysisView_feedbackSublabel", comment: "Sublabel for 'Feedback' within Q&A item"))
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.caption)
                                    .padding(.top, 5)
                                Text(item.feedback)
                                
                                Text(NSLocalizedString("InterviewAnalysisView_referenceScoreSublabel", comment: "Sublabel for 'Reference Score' within Q&A item"))
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.caption)
                                    .padding(.top, 5)
                                Text("\(item.score)")
                                    .bold()
                                    .font(.title3)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.accentColor ,
                                        lineWidth: 2
                                    )
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // 空白
                    Color.clear
                        .frame(height: 300)
                }
            case 1: // 草稿
                VStack(alignment: .leading, spacing: 20){
                    // Header
                    VStack(alignment: .leading, spacing: 10){
                        HStack{
                            Text(selected.templateName)
                                .font(.largeTitle)
                                .bold()
                            Text("草稿")
                                .padding(3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(
                                            Color(.white),
                                            lineWidth: 1
                                        )
                                )
                            Spacer()
                        }
                        Text(selected.templateDescription)
                        Text({
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd HH:mm"
                            return formatter.string(from: selected.date)
                        }())
                        .padding(.top, 40)
                    }
                    .foregroundStyle(Color(.white))
                    .padding()
                    .background(
                        Image(systemName: "\(selected.templateImage)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .offset(x: 160, y: 70)
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
                    
                    // Start Back
                    VStack(alignment: .leading){
                        Text("草稿")
                            .foregroundStyle(Color(.systemGray))
                            .padding(.horizontal)
                        Button {
                            ViewManager.shared.addPage(view: InterviewView(interviewProfile: selected))
                        } label: {
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "arrow.circlepath")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color(.accent))
                                    Text("還原草稿")
                                        .bold()
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color(.systemGray))
                                }
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.accentColor,
                                        lineWidth: 2
                                    )
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // 空白
                    Color.clear
                        .frame(height: 300)
                }
            default:
                EmptyView()
            }
        }
        .background(Color(.systemBackground))
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }
}

#Preview {
    InterviewAnalysisView(selected: .constant(DefaultInterviewType.test))
}
