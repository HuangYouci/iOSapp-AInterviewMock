//
//  SpeechStartView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//

import SwiftUI

struct SpeechStartView: View {
    
    enum SpeechStartViewState: Equatable {
        case readyToStart
        case presenting
        case analysingPresent
        case asking(current: Int)
        case analysingAsking
    }
    
    @Binding var selected: SpeechProfile?
    
    @StateObject private var recording = AudioRecorder()
    @State private var state: SpeechStartViewState = .readyToStart
    @State private var timerSeconds: Int = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack{
            VStack{
                switch (state){
                case .readyToStart:
                    ScrollView{
                        VStack(alignment: .leading, spacing: 15){
                            Image("SpeechProfile_\(selected!.templateImage)")
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
                                            Text(NSLocalizedString("SpeechStartView_timeLimit60m", comment: "60 minutes"))
                                                .bold()
                                            Text(NSLocalizedString("SpeechStartView_timeLimitTitle", comment: "Title 'Time Limit'"))
                                                .font(.caption)
                                                .foregroundStyle(Color(.systemGray))
                                        }
                                        VStack {
                                            Image(systemName: "questionmark.message")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundStyle(Color(.systemGray))
                                            Text(String(format: NSLocalizedString("SpeechStartView_numberOfQuestionsFormat", comment: ""), selected!.askedQuestionNumbers))
                                                .bold()
                                            Text(NSLocalizedString("SpeechStartView_audienceQuestionsTitle", comment: ""))
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
                            Text(NSLocalizedString("SpeechStartView_preparationDisclaimer", comment: "Disclaimer text on the preparation screen advising caution as the mock speech cannot be paused or restarted."))
                                .padding(.horizontal)
                            if (!recording.checkPermission()){
                                VStack(alignment: .leading){
                                    HStack{
                                        Image(systemName: "microphone.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color(.red))
                                        Text(NSLocalizedString("SpeechStartView_microphonePermissionTitle", comment: "Title for microphone permission status section (reused for denied state)"))
                                            .bold()
                                        Spacer()
                                    }
                                    Text(NSLocalizedString("SpeechStartView_microphonePermissionDenied", comment: "Microphone permission status: Denied. Instructs user to go to settings."))
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
                        }
                        .onAppear {
                            recording.requestMicrophonePermissionOnly()
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                case .presenting:
                    VStack(alignment: .leading, spacing: 15){
                        VStack(alignment: .leading){
                            Spacer()
                            HStack{
                                Text(NSLocalizedString("SpeechStartView_statusPresenting", comment: "Status text: Currently presenting"))
                                    .bold()
                                    .font(.title)
                                Spacer()
                            }
                            Text(NSLocalizedString("SpeechStartView_presentingInstruction", comment: "Instruction: Start your speech and press 'Finish' when done."))
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .background(
                            Image("SpeechStartView_presenting")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea(.all)
                        )
                    }
                case .analysingPresent:
                    VStack(alignment: .leading, spacing: 15){
                        VStack(alignment: .leading){
                            Spacer()
                            HStack{
                                Text(NSLocalizedString("SpeechStartView_statusAnalyzing", comment: "Status text: Analyzing"))
                                    .bold()
                                    .font(.title)
                                Spacer()
                            }
                            Text(NSLocalizedString("SpeechStartView_pleaseWaitMessage", comment: "Message: Please wait!"))
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .background(
                            LoopingVideoBackground(videoName: "SpeechStartView_analyzingPresent", fileExtension: "mp4")
                                .scaledToFill()
                                .ignoresSafeArea(.all)
                        )
                    }
                    .onAppear {
                        Task {
                            selected!.speechContent = await GeminiService.shared.generateAudioText(source: selected!.speechAudioPath)
                            if (selected!.askedQuestionNumbers > 0){
                                selected!.askedQuestions = await GeminiService.shared.generateSpeechAskedQuestions(from: selected!)
                                recording.startRecording()
                                state = .asking(current: 0)
                            } else {
                                state = .analysingAsking
                            }
                        }
                    }
                case .asking(current: let current):
                    VStack(alignment: .leading, spacing: 15){
                        VStack(alignment: .leading){
                            Spacer()
                            VStack(alignment: .leading, spacing: 10){
                                HStack{
                                    Text(String(format: NSLocalizedString("SpeechStartView_statusAskingQuestion", comment: "Status text: Asking question"), current+1))
                                    Spacer()
                                }
                                Text(selected!.askedQuestions[current].question)
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
                            Image("SpeechStartView_asking")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea(.all)
                        )
                    }
                case .analysingAsking:
                    VStack(alignment: .leading, spacing: 15){
                        VStack(alignment: .leading){
                            Spacer()
                            HStack{
                                Text(NSLocalizedString("SpeechStartView_statusAnalyzing", comment: "Status text: Analyzing"))
                                    .bold()
                                    .font(.title)
                                Spacer()
                            }
                            Text(NSLocalizedString("SpeechStartView_pleaseWaitMessage", comment: "Message: Please wait!"))
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .background(
                            LoopingVideoBackground(videoName: "SpeechStartView_analyzingPresent", fileExtension: "mp4")
                                .scaledToFill()
                                .ignoresSafeArea(.all)
                        )
                    }
                    .onAppear{
                        Task {
                            DataManager.shared.saveSpeechProfileAudios(speechProfile: &selected!)
                            for index in selected!.askedQuestions.indices {
                                selected!.askedQuestions[index].answer = await GeminiService.shared.generateAudioText(source: selected!.askedQuestions[index].answerAudioPath)
                            }
                            var temp = selected!
                            await GeminiService.shared.generateSpeechFeedback(target: &temp)
                            selected! = temp
                            DataManager.shared.saveSpeechProfileJSON(selected!)
                            
                            ViewManager.shared.backHomePage()
                            ViewManager.shared.addPage(view: SpeechAnalysisView(selected: .constant(selected!)))
                            
                            CoinManager.shared.addCoin(-selected!.cost)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            
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
                        Text(NSLocalizedString("SpeechStartView_headerTitleMockSpeech", comment: "Header title for the mock Speech screen"))
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
                Color.clear
                    .frame(height: 10)
                VStack{
                    HStack(spacing: 20){
                        switch (state){
                        case .readyToStart:
                            if (recording.checkPermission()){
                                Button {
                                    state = .presenting
                                    startTimer()
                                    recording.startRecording()
                                } label: {
                                    HStack{
                                        Text(NSLocalizedString("SpeechStartView_buttonStart", comment: "Button text: Start"))
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
                                    Text(NSLocalizedString("SpeechStartView_buttonStart", comment: "Button text: Start"))
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
                        case .presenting:
                            VStack{
                                Color.clear
                                    .frame(height: 5)
                                HStack{
                                    Circle()
                                        .frame(width: 10, height: 10)
                                    Text(NSLocalizedString("SpeechStartView_recordingIndicator", comment: "Indicator text: Recording"))
                                }
                                .foregroundStyle(Color(.red))
                                Text(timerSecToString())
                                    .font(.largeTitle)
                                    .bold()
                                Button {
                                    selected!.speechAudioPath = recording.stopRecording()!.path
                                    state = .analysingPresent
                                } label: {
                                    HStack{
                                        Text(NSLocalizedString("SpeechStartView_buttonStopPresenting", comment: "Button text: Finish Presenting"))
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
                            EmptyView()
                        case .analysingPresent:
                            EmptyView()
                        case .asking(current: let current):
                            VStack{
                                if (current+1 < selected!.askedQuestionNumbers){
                                    Button {
                                        selected!.askedQuestions[current].answerAudioPath = recording.stopRecording()!.path
                                        recording.startRecording()
                                        state = .asking(current: current+1)
                                    } label: {
                                        HStack{
                                            Text(NSLocalizedString("SpeechStartView_buttonNextAsking", comment: "Button text: Next Asking"))
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
                                        selected!.askedQuestions[current].answerAudioPath = recording.stopRecording()!.path
                                        stopTimer()
                                        state = .analysingAsking
                                    } label: {
                                        HStack{
                                            Text(NSLocalizedString("SpeechStartView_buttonStopAsking", comment: "Button text: Finish Asking"))
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
                        case .analysingAsking:
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
    
    private func timerSecToString() -> String {
        return String(format: "%02d:%02d", timerSeconds/60, timerSeconds%60)
    }
    
    private func startTimer() {
        stopTimer()
        timerSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerSeconds += 1
            if (timerSeconds > 3600){ // 60 minutes
                if state == .presenting {
                     selected!.speechAudioPath = recording.stopRecording()!.path
                     state = .analysingPresent
                }
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
    SpeechStartView(selected: .constant(DefaultSpeechProfile.test))
}
