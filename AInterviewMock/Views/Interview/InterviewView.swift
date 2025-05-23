//
//  InterviewEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI

struct InterviewView: View {
    
    // 第一步
    @State private var interviewProfile: InterviewProfile?
    
    // 任務元件
    @State private var session: Int = 1
    @State private var sessionIsForward: Bool = true
    
    init(){}
    init(interviewProfile: InterviewProfile){
        self._interviewProfile = State(initialValue: interviewProfile)
        self._session = State(initialValue: 5)
    }
    
    var body: some View {
        VStack(alignment: .leading){
            ZStack{
                VStack{
                    switch (session){
                    case 1:
                        InterviewEntryView(selected: $interviewProfile)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                    removal: .move(edge: sessionIsForward ? .leading : .trailing)
                                )
                            )
                    case 2:
                        InterviewQuesView(selected: $interviewProfile)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                    removal: .move(edge: sessionIsForward ? .leading : .trailing)
                                )
                            )
                    case 3:
                        InterviewFileView(selected: $interviewProfile)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                    removal: .move(edge: sessionIsForward ? .leading : .trailing)
                                )
                            )
                    case 4:
                        InterviewDoneView(selected: $interviewProfile)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                    removal: .move(edge: sessionIsForward ? .leading : .trailing)
                                )
                            )
                    case 5:
                        InterviewModifierView(selected: $interviewProfile)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                    removal: .move(edge: sessionIsForward ? .leading : .trailing)
                                )
                            )
                    case 6:
                        InterviewStartView(selected: $interviewProfile)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                    removal: .move(edge: sessionIsForward ? .leading : .trailing)
                                )
                            )
                    default:
                        Color.clear
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: session)
                
                // 底部控制 bar（只顯示於設置時，6 是特殊的）
                BottomSlidingBar(
                    isVisible: .constant(session < 6),
                    currentSession: $session,
                    maxHeight: 150,
                    content: {
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(NSLocalizedString("InterviewView_progressTitle", comment: "Title for the progress steps list"))
                                    .font(.title2)
                                    .bold()
                                    progressBuilder(s: 1, t: NSLocalizedString("InterviewView_progressStep1InterviewType", comment: "Progress step 1: Interview Type"))
                                    progressBuilder(s: 2, t: NSLocalizedString("InterviewView_progressStep2InterviewDetails", comment: "Progress step 2: Interview Details"))
                                    progressBuilder(s: 3, t: NSLocalizedString("InterviewView_progressStep3DataPreparation", comment: "Progress step 3: Data Preparation (Files)"))
                                    progressBuilder(s: 4, t: NSLocalizedString("InterviewView_progressStep4DataConfirmation", comment: "Progress step 4: Data Confirmation"))
                                    progressBuilder(s: 5, t: NSLocalizedString("InterviewView_progressStep5ReadyToStart", comment: "Progress step 5: Ready to Start"))
                                    Color.clear.frame(height: 0)
                                }
                                .padding(.horizontal)
                            }
                            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                            .onChange(of: session) { _ in
                                proxy.scrollTo(session, anchor: .center)
                            }
                        }
                    },
                    onNext: slidingBarOnNext,
                    onPrevious: slidingBarOnPrevious,
                    isNextEnabled: slidingBarNextEnabled(),
                    isPreviousEnabled: slidingBarPreviousEnabled(),
                    nextText: slidingBarNextText(),
                    previousText: slidingBarPreviousText()
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
    
    // MARK: - 視覺元素
    // 進度按鈕
    
    private func progressBuilder(s: Int, t: String) -> some View { // t is now a String (already localized)
        HStack{
            if (session == s){
                Image(systemName: "\(s).circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .bold()
            } else if (session < s){
                Image(systemName: "\(s).circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color(.systemGray))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color("AppGreen"))
            }
            
            if (session == s){
                Text(t) // Text receives the already localized string
                .bold()
            } else if (session < s){
                Text(t) // Text receives the already localized string
            } else {
                Text(t) // Text receives the already localized string
                .foregroundStyle(Color(.systemGray))
            }
            
        }
        .id(s)
    }
    
    // 下一步
    
    private func slidingBarNextEnabled() -> Bool {
        
        switch (session){
        case 1:
            // Step 1
            if (interviewProfile == nil){
                return false
            }
        case 2:
            // Step 2
            if let interviewProfile = interviewProfile {
                for item in (interviewProfile.preQuestions) {
                    if (item.answer.isEmpty && item.required){
                        return false
                    }
                }
            } else {
                return false
            }
        case 3:
            // Step 3
            if let interviewProfile = interviewProfile {
                for item in interviewProfile.filesPath {
                    if (item.isEmpty) {
                        return false
                    }
                }
            }
        case 4:
            // Step 4
            return true
        case 5:
            // Step 5
            if (interviewProfile!.cost > CoinManager.shared.coins){
                return false
            }
            return true
        default:
            return false
        }
        
        return true
    }
    private func slidingBarNextText() -> String { // Returns String (already localized)
        switch (session){
        case 5:
            return NSLocalizedString("InterviewView_nextButtonStartInterview", comment: "Button text: Start Interview")
        default:
            return NSLocalizedString("InterviewView_nextButtonNextStep", comment: "Button text: Next")
        }
    }
    private func slidingBarOnNext() {
        sessionIsForward = true
        DispatchQueue.main.async {
            session += 1
            
            // 切換後執行操作
            switch (session){
            case 5:
                DataManager.shared.saveInterviewProfileDocuments(interviewProfile: &interviewProfile!)
                interviewProfile!.status = .prepared // 1 回答完問題
            default:
                break
            }
            
        }
    }
    
    // 上一步
    
    private func slidingBarPreviousEnabled() -> Bool {
        switch (session){
        default:
            return true
        }
    }
    private func slidingBarPreviousText() -> String {
        switch (session){
        case 6:
            return NSLocalizedString("InterviewView_previousButtonLeave", comment: "Button text: Leave")
        case 5:
            return NSLocalizedString("InterviewView_previousButtonSaveChanges", comment: "Button text: Save Changes / Save Draft")
        case 1:
            return NSLocalizedString("InterviewView_previousButtonCancel", comment: "Button text: Cancel")
        default:
            return NSLocalizedString("InterviewView_previousButtonPreviousStep", comment: "Button text: Previous Step")
        }
    }
    private func slidingBarOnPrevious() {
        switch (session){
        case 1:
            interviewProfile = nil
            ViewManager.shared.perviousPage()
        case 5:
            DataManager.shared.saveInterviewProfileDocuments(interviewProfile: &interviewProfile!)
            DataManager.shared.saveInterviewProfileJSON(interviewProfile!)
            ViewManager.shared.perviousPage()
        case 6:
            // 需要做 Confirmation
            ViewManager.shared.perviousPage()
        default:
            sessionIsForward = false
            DispatchQueue.main.async {
                session -= 1
            }
        }
    }
    
}

#Preview {
    InterviewView()
}
