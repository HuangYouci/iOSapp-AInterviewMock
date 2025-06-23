//
//  SpeechView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//

import SwiftUI

/*

struct SpeechView: View {
    
    // 第一步
    @State private var target: SpeechProfile?
    
    // 任務元件
    @State private var session: Int = 1
    @State private var sessionIsForward: Bool = true
    
    init(){}
    init(SpeechProfile: SpeechProfile){
        self._target = State(initialValue: SpeechProfile)
        self._session = State(initialValue: 5)
    }
    
    var body: some View {
        ZStack{
            VStack{
                switch (session){
                case 1:
                    SpeechEntryView(selected: $target)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                removal: .move(edge: sessionIsForward ? .leading : .trailing)
                            )
                        )
                case 2:
                    SpeechQuesView(selected: $target)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                removal: .move(edge: sessionIsForward ? .leading : .trailing)
                            )
                        )
                case 3:
                    SpeechFileView(selected: $target)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                removal: .move(edge: sessionIsForward ? .leading : .trailing)
                            )
                        )
                case 4:
                    SpeechDoneView(selected: $target)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                removal: .move(edge: sessionIsForward ? .leading : .trailing)
                            )
                        )
                case 5:
                    SpeechModifierView(selected: $target)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: sessionIsForward ? .trailing : .leading),
                                removal: .move(edge: sessionIsForward ? .leading : .trailing)
                            )
                        )
                case 6:
                    SpeechStartView(selected: $target)
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
            
            BottomSlidingBar(
                isVisible: .constant(session < 6),
                currentSession: $session,
                maxHeight: 150,
                content: {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(NSLocalizedString("SpeechView_progressTitle", comment: "Title for the progress steps list"))
                                .font(.title2)
                                .bold()
                                progressBuilder(s: 1, t: NSLocalizedString("SpeechView_progressStep1SpeechType", comment: "Progress step 1: Speech Type"))
                                progressBuilder(s: 2, t: NSLocalizedString("SpeechView_progressStep2SpeechDetails", comment: "Progress step 2: Speech Details"))
                                progressBuilder(s: 3, t: NSLocalizedString("SpeechView_progressStep3DataPreparation", comment: "Progress step 3: Data Preparation (Files)"))
                                progressBuilder(s: 4, t: NSLocalizedString("SpeechView_progressStep4DataConfirmation", comment: "Progress step 4: Data Confirmation"))
                                progressBuilder(s: 5, t: NSLocalizedString("SpeechView_progressStep5ReadyToStart", comment: "Progress step 5: Ready to Start"))
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
    
    // MARK: - 視覺元素
    // 進度按鈕
    
    private func progressBuilder(s: Int, t: String) -> some View {
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
                Text(t)
                .bold()
            } else if (session < s){
                Text(t)
            } else {
                Text(t)
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
            if (target == nil){
                return false
            }
        case 2:
            // Step 2
            if let SpeechProfile = target {
                for item in (SpeechProfile.preQuestions) {
                    if (item.answer.isEmpty && item.required){
                        return false
                    }
                }
            } else {
                return false
            }
        case 3:
            // Step 3
            if let SpeechProfile = target {
                for item in SpeechProfile.filesPath {
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
            if (target!.cost > CoinManager.shared.coins){
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
            return NSLocalizedString("SpeechView_nextButtonStartSpeech", comment: "Button text: Start Speech")
        default:
            return NSLocalizedString("SpeechView_nextButtonNextStep", comment: "Button text: Next")
        }
    }
    private func slidingBarOnNext() {
        sessionIsForward = true
        DispatchQueue.main.async {
            session += 1
            
            // 切換後執行操作
            switch (session){
            case 5:
                DataManager.shared.saveSpeechProfileDocuments(speechProfile: &target!)
                target!.status = .prepared // 1 回答完問題
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
            return NSLocalizedString("SpeechView_previousButtonLeave", comment: "Button text: Leave")
        case 5:
            return NSLocalizedString("SpeechView_previousButtonSaveChanges", comment: "Button text: Save Changes / Save Draft")
        case 1:
            return NSLocalizedString("SpeechView_previousButtonCancel", comment: "Button text: Cancel")
        default:
            return NSLocalizedString("SpeechView_previousButtonPreviousStep", comment: "Button text: Previous Step")
        }
    }
    private func slidingBarOnPrevious() {
        switch (session){
        case 1:
            target = nil
//            ViewManager.shared.perviousPage()
        case 5:
            DataManager.shared.saveSpeechProfileDocuments(speechProfile: &target!)
            DataManager.shared.saveSpeechProfileJSON(target!)
//            ViewManager.shared.perviousPage()
        case 6:
            print("NO")
            // 需要做 Confirmation
//            ViewManager.shared.perviousPage()
        default:
            sessionIsForward = false
            DispatchQueue.main.async {
                session -= 1
            }
        }
    }
    
}

#Preview {
    SpeechView()
}

*/
