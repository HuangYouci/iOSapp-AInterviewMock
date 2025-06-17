//
//  InterviewAnalysisView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI

struct InterviewAnalysisView: View {

    enum InterviewAnalysisViewPage: Equatable {
        case rating
        case review
        case method
    }
    
    @Binding var selected: InterviewProfile
    @State private var currentPage: InterviewAnalysisViewPage = .rating
    @State private var scoringBarWidth: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 0){
            VStack{
                HStack{
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Text(NSLocalizedString("InterviewAnalysisView_Title", comment: "Title displayed at the top of the coin list screen"))
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color(.accent))
                    Spacer()
                    Button {
                        // ViewManager.shared.backHomePage()
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
            }
            ScrollView{
                LazyVStack(alignment: .leading, spacing: 15, pinnedViews: .sectionHeaders){
                    Section {
                        Image("InterviewProfile_\(selected.templateImage)")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250, alignment: .bottom)
                            .clipped()

                        VStack(alignment: .leading){
                            HStack{
                                Text(selected.templateName)
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text(selected.templateDescription)
                                .foregroundStyle(Color(.systemGray))
                            HStack{
                                Spacer()
                                Text({
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                                    return formatter.string(from: selected.date)
                                }())
                            }
                        }
                        .padding(.horizontal)
                    }

                    Section {
                        switch(currentPage){
                        case .rating:
                            VStack(alignment: .leading, spacing: 20){
                                VStack(alignment: .leading){
                                    Text(overallScoreToText(selected.overallRating))
                                        .font(.title3)
                                    Text("\(selected.overallRating)")
                                        .font(.largeTitle)
                                        .bold()
                                    HStack(spacing: 0){
                                        Rectangle()
                                            .fill(Color(.accent))
                                            .frame(width: (scoringBarWidth/100 * CGFloat(selected.overallRating)))
                                        Rectangle()
                                            .fill(Color(.systemGray))
                                    }
                                    .frame(height: 5)
                                    .clipShape(Capsule())
                                    .padding(.top, -10)
                                    .background(GeometryReader { proxy in
                                        Color.clear
                                            .onAppear {
                                                self.scoringBarWidth = proxy.size.width
                                            }
                                            .onChange(of: proxy.size){ t in
                                                self.scoringBarWidth = t.width
                                            }
                                    })
                                }
                                VStack(alignment: .leading, spacing: 5){
                                    Text(NSLocalizedString("InterviewAnalysisView_ratingFeedbackSectionTitle", comment: "ratingFeedbackSectionTitle (General)"))
                                        .bold()
                                    Text(selected.feedback)
                                }
                                if(selected.feedbacks.count > 0){
                                    VStack(alignment: .leading, spacing: 5){
                                        Text(NSLocalizedString("InterviewAnalysisView_ratingFeedbacksSectionTitle", comment: "ratingFeedbacksSectionTitle (Sub)"))
                                            .bold()
                                        ForEach(selected.feedbacks){ i in
                                            VStack(alignment: .leading){
                                                Text(i.content)
                                            }
                                            .padding(10)
                                            .background(Color(.secondarySystemBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                                if(selected.questions.count > 0){
                                    VStack(alignment: .leading, spacing: 5){
                                        Text(NSLocalizedString("InterviewAnalysisView_ratingQuestionsFeedbackSectionTitle", comment: "Rating feedback for questions"))
                                            .bold()
                                        ForEach(selected.questions){ i in
                                            VStack(alignment: .leading){
                                                Text(i.question)
                                                    .padding(10)
                                                    .background(Color(.systemBackground))
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .padding(.trailing)
                                                HStack{
                                                    Text(i.answer)
                                                    Spacer()
                                                }
                                                .padding(10)
                                                .background(Color(.systemBackground))
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .padding(.leading)
                                                Divider()
                                                HStack{
                                                    Text("\(i.score)")
                                                        .bold()
                                                        .font(.title3)
                                                    Text(subScoreToText(i.score))
                                                }
                                                .padding(.bottom, 3)
                                                Text(i.feedback)
                                            }
                                            .padding(10)
                                            .background(Color(.secondarySystemBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        case .review:
                            VStack(alignment: .leading, spacing: 20){
                                if(selected.questions.count > 0){
                                    VStack(alignment: .leading, spacing: 5){
                                        Text(NSLocalizedString("InterviewAnalysisView_ratingQuestionsFeedbackSectionTitle", comment: "Rating feedback for questions"))
                                            .bold()
                                        ForEach(selected.questions){ i in
                                            VStack(alignment: .leading){
                                                Text(i.question)
                                                    .padding(10)
                                                    .background(Color(.systemBackground))
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .padding(.trailing)
                                                HStack{
                                                    Text(i.answer)
                                                    Spacer()
                                                }
                                                .padding(10)
                                                .background(Color(.systemBackground))
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .padding(.leading)
                                            }
                                            .padding(10)
                                            .background(Color(.secondarySystemBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        case .method:
                            VStack(alignment: .leading, spacing: 20){
                                VStack(alignment: .leading, spacing: 5){
                                    if selected.status == .completed {
                                        Button {
                                            var reuse = selected
                                            reuse.id = UUID()
                                            reuse.date = Date()
                                            // ViewManager.shared.addPage(view: InterviewView(interviewProfile: reuse))
                                        } label: {
                                            VStack(alignment: .leading){
                                                HStack{
                                                    Image(systemName: "arrow.uturn.down.circle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 15, height: 15)
                                                    Text(NSLocalizedString("InterviewAnalysisView_reuseSublabel", comment: "Sublabel for 'Reuse Template' within delete item"))
                                                        .bold()
                                                    Spacer()
                                                }
                                                .foregroundStyle(Color(.accent))
                                            }
                                            .padding()
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        Color(.accent),
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                    } else {
                                        Button {
                                            // ViewManager.shared.addPage(view: InterviewView(interviewProfile: selected))
                                        } label: {
                                            VStack(alignment: .leading){
                                                HStack{
                                                    Image(systemName: "arrow.uturn.down.circle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 15, height: 15)
                                                    Text(NSLocalizedString("InterviewAnalysisView_useDraftSublabel", comment: "Sublabel for 'Use Draft' within method page"))
                                                        .bold()
                                                    Spacer()
                                                }
                                                .foregroundStyle(Color(.accent))
                                            }
                                            .padding()
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        Color(.accent),
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                    }
                                    Button {
//                                        ViewManager.shared.setTopView(view:
//                                            ConfirmationDialog(
//                                                title: NSLocalizedString("SpeechAnalysisView_deleteInterviewProfileSectionTitle", comment: "Section title of delete this speech profile"),
//                                                message: NSLocalizedString("SpeechAnalysisView_deleteInterviewProfileSectionDescription", comment: "Section description of delete this speech profile"),
//                                                onConfirm: {
//                                                    ViewManager.shared.perviousPage()
//                                                    DataManager.shared.deleteInterviewProfile(withId: selected.id.uuidString)
//                                                },
//                                                onCancel: {}
//                                            )
//                                        )
                                    } label: {
                                        VStack(alignment: .leading){
                                            HStack{
                                                Image(systemName: "trash.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                                Text(NSLocalizedString("InterviewAnalysisView_deleteRecordSublabel", comment: "Sublabel for 'Delete Record' within delete item"))
                                                    .bold()
                                                Spacer()
                                            }
                                            .foregroundStyle(Color(.red))
                                        }
                                        .padding()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    Color(.red),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } header: {
                        VStack(alignment: .leading){
                            HStack(spacing: 10){
                                if (selected.status == .completed){
                                    pageTab(title: NSLocalizedString("InterviewAnalysisView_tabBarRating", comment: "Tab bar Rating"), page: .rating)
                                    pageTab(title: NSLocalizedString("InterviewAnalysisView_tabBarReview", comment: "Tab bar Review"), page: .review)
                                }
                                pageTab(title: NSLocalizedString("InterviewAnalysisView_tabBarMethod", comment: "Tab bar Method"), page: .method)
                            }
                            .padding(.horizontal)
                            Divider()
                        }
                        .background(Color(.systemBackground))
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            if (selected.status != .completed) { currentPage = .method }
        }
    }
    
    @ViewBuilder
    private func pageTab(title: String, page: InterviewAnalysisViewPage) -> some View {
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
    
    private func overallScoreToText(_ i: Int) -> String {
        if (i >= 90){
            return NSLocalizedString("InterviewAnalysisView_scoreText_A", comment: "Score to text A")
        } else if (i >= 80){
            return NSLocalizedString("InterviewAnalysisView_scoreText_B", comment: "Score to text B")
        } else if (i >= 70){
            return NSLocalizedString("InterviewAnalysisView_scoreText_C", comment: "Score to text C")
        } else if (i >= 60){
            return NSLocalizedString("InterviewAnalysisView_scoreText_D", comment: "Score to text D")
        } else if (i >= 50){
            return NSLocalizedString("InterviewAnalysisView_scoreText_E", comment: "Score to text E")
        } else if (i >= 40){
            return NSLocalizedString("InterviewAnalysisView_scoreText_F", comment: "Score to text F")
        } else {
            return NSLocalizedString("InterviewAnalysisView_scoreText_G", comment: "Score to text G")
        }
    }
    
    private func subScoreToText(_ i: Int) -> String {
        if (i >= 9){
            return NSLocalizedString("InterviewAnalysisView_scoreText_A", comment: "Score to text A")
        } else if (i >= 8){
            return NSLocalizedString("InterviewAnalysisView_scoreText_B", comment: "Score to text B")
        } else if (i >= 7){
            return NSLocalizedString("InterviewAnalysisView_scoreText_C", comment: "Score to text C")
        } else if (i >= 6){
            return NSLocalizedString("InterviewAnalysisView_scoreText_D", comment: "Score to text D")
        } else if (i >= 5){
            return NSLocalizedString("InterviewAnalysisView_scoreText_E", comment: "Score to text E")
        } else if (i >= 4){
            return NSLocalizedString("SpeechAnalysisView_scoreText_F", comment: "Score to text F")
        } else {
            return NSLocalizedString("InterviewAnalysisView_scoreText_G", comment: "Score to text G")
        }
    }
}

#Preview {
    InterviewAnalysisView(selected: .constant(DefaultInterviewProfile.test))
}
