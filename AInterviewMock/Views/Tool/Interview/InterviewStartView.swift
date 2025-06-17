//
//  InterviewStartView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct InterviewStartView: View {
    
    enum InterviewStartViewState: Equatable {
        case readyToStart
        case generating
        case answering(current: Int)
        case analyzing
    }
    
    @Binding var selected: InterviewProfile?
    
    @StateObject private var recording = AudioRecorder()
    @State private var state: InterviewStartViewState = .readyToStart
    @State private var timerSeconds: Int = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                switch (state){
                case .readyToStart:
                    ScrollView{
                        VStack(alignment: .leading, spacing: 15){
                            Image("InterviewProfile_\(selected!.templateImage)")
                                .resizable()
                                .frame(height: 250)
                                .scaledToFill()
                                .clipped()
                            VStack(alignment: .leading){
                                HStack{
                                    Text(selected!.templateName)
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                Text(selected!.templateDescription)
                                    .foregroundStyle(Color(.systemGray))
                            }
                            .padding(.horizontal)
                            Divider()
                                .padding(.horizontal)
                            HStack {
                                Spacer()
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        VStack {
                                            Image(systemName: "clock")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundStyle(Color(.systemGray))
                                            Text(String(format: NSLocalizedString("InterviewStartView_timeLimit", comment: "Time Limit, Need a placeholder"), selected!.questionNumbers*2))
                                                .bold()
                                            Text(NSLocalizedString("InterviewStartView_timeLimitTitle", comment: "Title 'Time Limit'"))
                                                .font(.caption)
                                                .foregroundStyle(Color(.systemGray))
                                        }
                                        VStack {
                                            Image(systemName: "questionmark.message")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundStyle(Color(.systemGray))
                                            Text(String(format: NSLocalizedString("InterviewStartView_numberOfQuestionsFormat", comment: "shows question counts"), selected!.questionNumbers))
                                                .bold()
                                            Text(NSLocalizedString("InterviewStartView_questionsTitle", comment: ""))
                                                .font(.caption)
                                                .foregroundStyle(Color(.systemGray))
                                        }
                                    }
                                    .frame(minWidth: UIScreen.main.bounds.width - 40)
                                }
                                Spacer()
                            }
                            
                            .padding(.horizontal)
                            Divider()
                                .padding(.horizontal)
                            Text(NSLocalizedString("InterviewStartView_preparationDisclaimer", comment: "Disclaimer text on the preparation screen advising caution as the mock interview cannot be paused or restarted."))
                                .padding(.horizontal)
                            if (!recording.checkPermission()){
                                VStack(alignment: .leading){
                                    HStack{
                                        Image(systemName: "microphone.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color(.red))
                                        Text(NSLocalizedString("InterviewStartView_microphonePermissionTitle", comment: "Title for microphone permission status section (reused for denied state)"))
                                            .bold()
                                        Spacer()
                                    }
                                    Text(NSLocalizedString("InterviewStartView_microphonePermissionDenied", comment: "Microphone permission status: Denied. Instructs user to go to settings."))
                                }
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.red),
                                                lineWidth: 2
                                               )
                                )
                                .padding(.horizontal)
                                .onAppear {
                                    recording.requestMicrophonePermissionOnly()
                                }
                            }
                            
                            Color.clear.frame(height: 100)
                        }
                        .onAppear {
                            recording.requestMicrophonePermissionOnly()
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                case .generating:
                    VStack(alignment: .leading, spacing: 15){
                        VStack(alignment: .leading){
                            Spacer()
                            HStack{
                                Text(NSLocalizedString("InterviewStartView_statusAnalyzing", comment: "Status text: Generating"))
                                    .bold()
                                    .font(.title)
                                Spacer()
                            }
                            Text(NSLocalizedString("InterviewStartView_pleaseWaitMessage", comment: "Message: Please wait!"))
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .background(
                            LoopingVideoBackground(videoName: "InterviewStartView_generateQuestions", fileExtension: "mp4")
                                .scaledToFill()
                                .ignoresSafeArea(.all)
                        )
                    }
                    .onAppear {
                        Task {
                            selected!.questions = await GeminiService.shared.generateInterviewQuestions(from: selected!)
                            state = .answering(current: 0)
                            recording.startRecording()
                            startTimer()
                        }
                    }
                case .answering(current: let current):
                    VStack(alignment: .leading, spacing: 15){
                        VStack(alignment: .leading){
                            Spacer()
                            VStack(alignment: .leading, spacing: 10){
                                HStack{
                                    Text(String(format: NSLocalizedString("InterviewStartView_statusAnsweringQuestion", comment: "Status text: question n"), current+1))
                                    Spacer()
                                }
                                Text(selected!.questions[current].question)
                                    .bold()
                                    .font(.title)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .padding(.horizontal)
                        .background(
                            Image("InterviewStartView_answering")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea(.all)
                        )
                    }
                case .analyzing:
                    VStack(alignment: .leading, spacing: 15){
                        VStack(alignment: .leading){
                            Spacer()
                            HStack{
                                Text(NSLocalizedString("InterviewStartView_statusAnalyzing", comment: "Status text: Analyzing"))
                                    .bold()
                                    .font(.title)
                                Spacer()
                            }
                            Text(NSLocalizedString("InterviewStartView_pleaseWaitMessage", comment: "Message: Please wait!"))
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .background(
                            LoopingVideoBackground(videoName: "InterviewStartView_analyzing", fileExtension: "mp4")
                                .scaledToFill()
                                .ignoresSafeArea(.all)
                        )
                    }
                    .onAppear{
                        Task {
                            DataManager.shared.saveInterviewProfileAudios(interviewProfile: &selected!)
                            for index in selected!.questions.indices {
                                selected!.questions[index].answer = await GeminiService.shared.generateAudioText(source: selected!.questions[index].answerAudioPath)
                            }
                            var selectedTemp = selected!
                            await GeminiService.shared.generateInterviewFeedback(target: &selectedTemp)
                            selected! = selectedTemp
                            DataManager.shared.saveInterviewProfileJSON(selected!)
                            
                            CoinManager.shared.addCoin(-selected!.cost)
                            
//                            ViewManager.shared.backHomePage()
//                            ViewManager.shared.addPage(view: InterviewAnalysisView(selected: .constant(selected!)))
                        }
                    }
                }
            }
            
            VStack(spacing: 0){
                Color.clear
                    .frame(height: 55)
                VStack{
                    HStack{
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        Text(NSLocalizedString("InterviewStartView_headerTitleMockInterview", comment: "Header title for the mock Interview screen"))
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color(.accent))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(.ultraThinMaterial)
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 0
                )
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0){
                VStack(spacing: 0){
                    Color.clear
                        .frame(height: 10)
                    VStack{
                        HStack(spacing: 20){
                            switch(state){
                            case .readyToStart:
                                if (recording.checkPermission()){
                                    Button {
                                        state = .generating
                                    } label: {
                                        HStack{
                                            Text(NSLocalizedString("InterviewStartView_buttonStart", comment: "Button text: Start"))
                                                .font(.title3)
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 15, height: 15)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .foregroundStyle(Color(.white))
                                    .padding()
                                    .background(Color(.accent))
                                    .clipShape(Capsule())
                                } else {
                                    HStack{
                                        Text(NSLocalizedString("InterviewStartView_buttonStart", comment: "Button text: Start"))
                                            .font(.title3)
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(Color(.white))
                                    .padding()
                                    .background(Color(.systemGray2))
                                    .clipShape(Capsule())
                                }
                            case .generating:
                                EmptyView()
                            case .answering(current: let current):
                                VStack{
                                    Color.clear
                                        .frame(height: 5)
                                    HStack{
                                        Circle()
                                            .frame(width: 10, height: 10)
                                        Text(NSLocalizedString("InterviewStartView_recordingIndicator", comment: "Indicator text: Recording"))
                                    }
                                    .foregroundStyle(Color(.red))
                                    Text(timerSecToString())
                                        .font(.largeTitle)
                                        .bold()
                                    if (timerSeconds > (selected!.questionNumbers*2*55)){
                                        Text(String(format: NSLocalizedString("InterviewStartView_timeLimitWarningFormat", comment: "Time Limit Warning"), selected!.questionNumbers*2 - timerSeconds))
                                    }
                                    if (current+1 < selected!.questionNumbers){
                                        Button {
                                            selected!.questions[current].answerAudioPath = recording.stopRecording()!.path
                                            state = .answering(current: current+1)
                                            recording.startRecording()
                                        } label: {
                                            HStack{
                                                Text(NSLocalizedString("InterviewStartView_buttonNextQuestion", comment: "Button text: Next Question"))
                                                    .font(.title3)
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .foregroundStyle(Color(.white))
                                        .padding()
                                        .background(Color(.accent))
                                        .clipShape(Capsule())
                                    } else {
                                        Button {
                                            stopTimer()
                                            selected!.questions[current].answerAudioPath = recording.stopRecording()!.path
                                            state = .analyzing
                                        } label: {
                                            HStack{
                                                Text(NSLocalizedString("InterviewStartView_buttonFinish", comment: "Button text: Finish (for last question)"))
                                                    .font(.title3)
                                                Image(systemName: "chevron.right")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .foregroundStyle(Color(.white))
                                        .padding()
                                        .background(Color(.accent))
                                        .clipShape(Capsule())
                                    }
                                }
                            case .analyzing:
                                EmptyView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    Color.clear
                        .frame(height: 50)
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
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
    
    private func timerSecToString() -> String {
        return String(format: "%02d:%02d", timerSeconds/60, timerSeconds%60)
    }
    
    private func startTimer() {
        stopTimer()
        timerSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerSeconds += 1
            if (timerSeconds > (selected!.questionNumbers*2*60)){
                state = .analyzing
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}

#Preview{
    InterviewStartView(selected: .constant(DefaultInterviewProfile.test))
}
