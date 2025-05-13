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
    
    // 拖曳爸元件
    @State private var barHeight: CGFloat = 150
    @State private var isBarDraging: Bool = true
    
    // 任務元件
    @State private var session: Int = 1
    @State private var sessionIsForward: Bool = true
    
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
                VStack(spacing: 0){
                    if (session < 6){
                        VStack(spacing: 0){
                            VStack(spacing: 0){
                                VStack{
                                    Capsule()
                                        .fill(Color(.systemGray))
                                        .frame(width: 40, height: 6)
                                        .padding(8)
                                        .opacity(isBarDraging ? 1 : 0.3)
                                    Color.clear
                                        .frame(height: 10)
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            barHeight -= value.translation.height
                                            barHeight = max(barHeight, 0)
                                            barHeight = min(barHeight, 300)
                                            
                                            isBarDraging = true
                                        }
                                        .onEnded { value in
                                            if (value.translation.height > 0){
                                                withAnimation(.easeInOut(duration: 0.3)){
                                                    barHeight = 0
                                                }
                                            }
                                            if (value.translation.height < 0){
                                                withAnimation(.easeInOut(duration: 0.3)){
                                                    barHeight = 150
                                                }
                                            }
                                            
                                            withAnimation(.easeInOut(duration: 0.3)){
                                                isBarDraging = false
                                            }
                                        }
                                )
                                
                                VStack{
                                    ScrollViewReader { proxy in
                                        ScrollView{
                                            VStack(alignment: .leading, spacing: 10){
                                                Text(NSLocalizedString("InterviewView_progressTitle", comment: "Title for the progress steps list"))
                                                    .font(.title2)
                                                    .bold()
                                                progressBuilder(s: 1, t: NSLocalizedString("InterviewView_progressStep1InterviewType", comment: "Progress step 1: Interview Type"))
                                                progressBuilder(s: 2, t: NSLocalizedString("InterviewView_progressStep2InterviewDetails", comment: "Progress step 2: Interview Details"))
                                                progressBuilder(s: 3, t: NSLocalizedString("InterviewView_progressStep3DataPreparation", comment: "Progress step 3: Data Preparation (Files)"))
                                                progressBuilder(s: 4, t: NSLocalizedString("InterviewView_progressStep4DataConfirmation", comment: "Progress step 4: Data Confirmation"))
                                                progressBuilder(s: 5, t: NSLocalizedString("InterviewView_progressStep5ReadyToStart", comment: "Progress step 5: Ready to Start"))
                                                Color.clear
                                                    .frame(height: 0)
                                                    .frame(maxWidth: .infinity)
                                            }
                                            .padding(.horizontal)
                                        }
                                        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                                        .onChange(of: session){ _ in
                                            proxy.scrollTo(session, anchor: .center)
                                        }
                                    }
                                }
                                .frame(height: barHeight)
                                
                                VStack{
                                    HStack(spacing: 20){
                                        if (isPerviousButtonAvailable()){
                                            Button {
                                                perviousButtonAction()
                                            } label: {
                                                HStack{
                                                    Text(perviousButtonText()) // This function returns a String (already localized)
                                                        .font(.title3)
                                                }
                                            }
                                            .foregroundStyle(Color(.systemGray))
                                            .padding()
                                        }
                                        
                                        Button {
                                            nextButtonAction()
                                        } label: {
                                            HStack{
                                                Text(nextButtonText()) // This function returns a String (already localized)
                                                    .font(.title3)
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .foregroundStyle(isNextButtonAvailable() ? Color(.white) : Color(.systemGray))
                                        .padding()
                                        .background(isNextButtonAvailable() ? Color(.accent) : Color(.systemGray2))
                                        .clipShape(Capsule())
                                        .disabled(!isNextButtonAvailable())
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                            .background(.ultraThinMaterial)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 20,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 20
                                )
                            )
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            Color.clear
                                .background(.ultraThinMaterial)
                                .frame(height: 0)
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: session)
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
    
    private func isNextButtonAvailable() -> Bool {
        
        switch (session){
        case 1:
            // Step 1
            if (interviewProfile == nil){
                return false
            }
        case 2:
            // Step 2
            if let interviewType = interviewProfile {
                for item in (interviewType.preQuestions) {
                    if (item.answer.isEmpty && item.required){
                        return false
                    }
                }
            } else {
                return false
            }
        case 3:
            // Step 3
            if let interviewType = interviewProfile {
                for item in interviewType.filesPath {
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
    private func nextButtonText() -> String { // Returns String (already localized)
        switch (session){
        case 5:
            return NSLocalizedString("InterviewView_nextButtonStartInterview", comment: "Button text: Start Interview")
        default:
            return NSLocalizedString("InterviewView_nextButtonNextStep", comment: "Button text: Next")
        }
    }
    private func nextButtonAction() {
        sessionIsForward = true
        DispatchQueue.main.async {
            session += 1
            
            // 切換後執行操作
            switch (session){
            case 2:
                withAnimation(.easeInOut(duration: 0.3)){
                    barHeight = 0
                }
            case 5:
                DataManager.shared.saveInterviewTypeDocuments(interviewProfile: &interviewProfile!)
                interviewProfile!.status = 1 // 1 回答完問題
            default:
                break
            }
            
        }
    }
    
    // 上一步
    
    private func isPerviousButtonAvailable() -> Bool {
        switch (session){
        default:
            return true
        }
    }
    private func perviousButtonText() -> String { // Returns String (already localized)
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
    private func perviousButtonAction() {
        switch (session){
        case 1:
            interviewProfile = nil
            ViewManager.shared.backHomePage()
        case 5:
            DataManager.shared.saveInterviewTypeJSON(interviewProfile!)
            ViewManager.shared.backHomePage()
        case 6:
            // 需要做 Confirmation
            ViewManager.shared.backHomePage()
        default:
            sessionIsForward = false
            DispatchQueue.main.async {
                session -= 1
            }
        }
    }
    
    // MARK: - 從舊有進度開始
    
}

#Preview {
    InterviewView()
}
