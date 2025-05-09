//
//  InterviewEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI

struct InterviewView: View {
    
    // 第一步
    @Binding var running: Bool
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
                        InterviewStartView(selected: $interviewProfile, running: $running)
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
                                                Text("進度")
                                                    .font(.title2)
                                                    .bold()
                                                progressBuilder(s: 1, t: "面試類型")
                                                progressBuilder(s: 2, t: "面試細節")
                                                progressBuilder(s: 3, t: "資料準備")
                                                progressBuilder(s: 4, t: "資料確認")
                                                progressBuilder(s: 5, t: "準備開始")
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
                                                    Text(perviousButtonText())
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
                                                Text(nextButtonText())
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
    private func nextButtonText() -> String {
        switch (session){
        case 5:
            return "開始面試"
        default:
            return "下一步"
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
    private func perviousButtonText() -> String {
        switch (session){
        case 6:
            return "離開"
        case 5:
            return "暫存"
        case 1:
            return "取消"
        default:
            return "上一步"
        }
    }
    private func perviousButtonAction() {
        switch (session){
        case 1:
            interviewProfile = nil
            running = false
        case 5:
            DataManager.shared.saveInterviewTypeJSON(interviewProfile!)
            running = false
        case 6:
            // 需要做 Confirmation
            running = false
        default:
            sessionIsForward = false
            DispatchQueue.main.async {
                session -= 1
            }
        }
    }
    
}

#Preview {
    InterviewView(running: .constant(true))
}
