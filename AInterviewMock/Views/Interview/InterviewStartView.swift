//
//  InterviewStartView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct InterviewStartView: View {
    
    @Binding var selected: InterviewProfile?
    @Binding var running: Bool
    
    @StateObject private var recording = AudioRecorder()
    @State private var questionNum: Int = -2
    // 0 以上開始，-1 錯誤，-2 準備，-3 準備開始，-4 分析中，-5 分析完畢
    @State private var timerSeconds: Int = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                ScrollView{
                    Color.clear
                        .frame(height: 50)
                    
                    switch (questionNum){
                    case -1:
                        Color.clear
                            .frame(height: 200)
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "exclamationmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.red))
                                Text(NSLocalizedString("InterviewStartView_errorOccurredTitle", comment: "Title for error message display"))
                                    .bold()
                                Spacer()
                            }
                            Text(NSLocalizedString("InterviewStartView_errorOccurredDuringMockInterview", comment: "Error message: an error occurred during the mock interview."))
                            Text(NSLocalizedString("InterviewStartView_errorSuggestionContactDeveloper", comment: "Error suggestion: Please try again. If assistance is needed, contact the developer."))
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.red),
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                    case -2:
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.accent))
                                Text(NSLocalizedString("InterviewStartView_mockInterviewInstructionsTitle", comment: "Title for mock interview instructions section"))
                                    .bold()
                                Spacer()
                            }
                            Text(NSLocalizedString("InterviewStartView_instructionsLine1", comment: "Instruction line 1: Entered mock interview, prepare on this screen..."))
                            Text(String(format: NSLocalizedString("InterviewStartView_instructionsLine2Format", comment: "Instruction line 2: After starting, program will ask %d questions... Each question requires voice recording... Click 'Next' to complete. Answer every question."), selected!.questionNumbers))
                            Text(NSLocalizedString("InterviewStartView_instructionsLine3", comment: "Instruction line 3: Keep program open and network connected... Coins will be deducted upon starting... Accidental exit will result in irreversible coin deduction."))
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor,
                                        lineWidth: 2
                                       )
                        )
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "clock.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.accent))
                                Text(NSLocalizedString("InterviewStartView_timeLimitTitle", comment: "Title for time limit information section"))
                                    .bold()
                                Spacer()
                            }
                            Text(String(format: NSLocalizedString("InterviewStartView_timeLimitDescriptionFormat", comment: "Time limit description: The response time limit for this interview is %d minutes."), selected!.questionNumbers * 2))
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor,
                                        lineWidth: 2
                                       )
                        )
                        .padding(.horizontal)
                        
                        if (recording.checkPermission()){
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "microphone.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color("AppGreen"))
                                    Text(NSLocalizedString("InterviewStartView_microphonePermissionTitle", comment: "Title for microphone permission status section"))
                                        .bold()
                                    Spacer()
                                }
                                Text(NSLocalizedString("InterviewStartView_microphonePermissionGranted", comment: "Microphone permission status: Granted."))
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("AppGreen"),
                                            lineWidth: 2
                                           )
                            )
                            .padding(.horizontal)
                        } else {
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
                    case -3:
                        VStack(spacing: 10){
                            Color.clear
                                .frame(height: 200)
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "info.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color(.accent))
                                    Text(NSLocalizedString("InterviewStartView_loadingMockInterviewTitle", comment: "Title when mock interview is loading questions"))
                                        .bold()
                                    Spacer()
                                    ProgressView()
                                        .frame(width: 15, height: 15)
                                }
                                Text(NSLocalizedString("InterviewStartView_loadingWarningKeepOpen", comment: "Warning during loading: Do not close the app and keep network connected!"))
                                Text(NSLocalizedString("InterviewStartView_loadingDescriptionGeneratingQuestions", comment: "Description during loading: Program is generating questions..."))
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor,
                                        lineWidth: 2
                                    )
                            )
                            .padding(.horizontal)
                        }
                        .onAppear {
                            Task {
                                selected!.questions = await GeminiService.shared.generateInterviewQuestions(from: selected!)
                                if (selected!.questions.count) > 0 {
                                    questionNum = 0
                                    CoinManager.shared.removeCoin(selected!.cost)
                                    recording.startRecording()
                                    startTimer()
                                } else {
                                    questionNum = -1
                                }
                            }
                        }
                    case -4:
                        VStack(spacing: 10){
                            Color.clear
                                .frame(height: 200)
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "info.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color(.accent))
                                    Text(NSLocalizedString("InterviewStartView_analyzingTitle", comment: "Title when interview results are being analyzed"))
                                        .bold()
                                    Spacer()
                                    ProgressView()
                                        .frame(width: 15, height: 15)
                                }
                                Text(NSLocalizedString("InterviewStartView_loadingWarningKeepOpen", comment: "Warning during loading/analyzing: Do not close the app and keep network connected! (reused)"))
                                Text(NSLocalizedString("InterviewStartView_analyzingDescription", comment: "Description during analysis: Program is generating results based on your answers."))
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor,
                                        lineWidth: 2
                                    )
                            )
                            .padding(.horizontal)
                        }
                        .onAppear {
                            Task {
                                DataManager.shared.saveInterviewTypeAudios(interviewProfile: &selected!)
                                for index in selected!.questions.indices {
                                    selected!.questions[index].answer = await GeminiService.shared.generateAudioText(source: selected!.questions[index].answerAudioPath)
                                }
                                var selectedTemp = selected!
                                await GeminiService.shared.generateInterviewFeedback(interviewProfile: &selectedTemp)
                                selected! = selectedTemp
                                DataManager.shared.saveInterviewTypeJSON(selected!)
                                questionNum = -5
                            }
                        }
                    case -5:
                        InterviewAnalysisView(selected: .constant(selected!))
                    default:
                        VStack(alignment: .leading){
                            HStack{
                                Text(NSLocalizedString("InterviewStartView_questionLabel", comment: "Label for the current interview question"))
                                    .foregroundStyle(Color(.accent))
                                    .bold()
                                Spacer()
                            }
                            Text(selected!.questions[questionNum].question)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor,
                                        lineWidth: 2
                                       )
                        )
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "microphone.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.accent))
                                Text(NSLocalizedString("InterviewStartView_recordingAnswerTitle", comment: "Title indicating that answer is being recorded"))
                                    .bold()
                                Spacer()
                            }
                            Text(NSLocalizedString("InterviewStartView_recordingAnswerDescription", comment: "Description: Currently recording your answer."))
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray),
                                        lineWidth: 2
                                       )
                        )
                        .padding(.horizontal)
                        
                        if (timerSeconds+60 > (selected!.questionNumbers*2*60)){
                            VStack(alignment: .leading){
                                HStack{
                                    Image(systemName: "clock.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color(.accent))
                                    Text(NSLocalizedString("InterviewStartView_timeLimitTitle", comment: "Title for time limit warning (reused)"))
                                        .bold()
                                    Spacer()
                                }
                                Text(String(format: NSLocalizedString("InterviewStartView_timeLimitWarningFormat", comment: "Time limit warning: Approaching time limit... Remaining %d seconds."), (selected!.questionNumbers*2*60) - timerSeconds))
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray),
                                            lineWidth: 2
                                           )
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    Color.clear
                        .frame(height: 50)
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            }
            VStack(spacing: 0){
                Color.clear
                    .background(.ultraThinMaterial)
                    .frame(height: 0)
                VStack(spacing: 0){
                    VStack{
                        ZStack{
                            if (questionNum >= 0){
                                HStack(alignment: .top, spacing: 3){
                                    Text(NSLocalizedString("InterviewStartView_questionLabelWithNumberPrefix", comment: "Prefix for question number display, e.g., 'Question'"))
                                        .padding(.top, 3)
                                    Text("\(questionNum+1)")
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                HStack(alignment: .top, spacing: 3){
                                    Spacer()
                                    Text(timerSecToString())
                                        .font(.title2)
                                }
                            }
                            HStack{
                                Image("Logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text(NSLocalizedString("InterviewStartView_headerTitleMockInterview", comment: "Header title for the mock interview screen"))
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(Color(.accent))
                            }
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
            }
            VStack(spacing: 0){
                VStack(spacing: 0){
                    Color.clear
                        .frame(height: 10)
                    VStack{
                        HStack(spacing: 20){
                            if (questionNum >= 0){
                                Button {
                                    attemptToNext()
                                } label: {
                                    HStack{
                                        Text(questionNum+1 == selected!.questionNumbers ? NSLocalizedString("InterviewStartView_buttonFinish", comment: "Button text: Finish (for last question)") : NSLocalizedString("InterviewStartView_buttonNextQuestion", comment: "Button text: Next Question"))
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
                                
                            } else if (questionNum == -2){
                                if (recording.checkPermission()){
                                    Button {
                                        questionNum = -3
                                    } label: {
                                        HStack{
                                            Text(NSLocalizedString("InterviewStartView_buttonStart", comment: "Button text: Start (to begin interview setup)"))
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
                                        Text(NSLocalizedString("InterviewStartView_buttonStart", comment: "Button text: Start (disabled state when no mic permission)"))
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
                                
                            } else if (questionNum == -5) {
                                Button {
                                    running = false
                                } label: {
                                    HStack{
                                        Text(NSLocalizedString("InterviewStartView_buttonComplete", comment: "Button text: Complete (after interview analysis is done)"))
                                            .font(.title3)
                                        Image(systemName: "checkmark")
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
                attemptToNext()
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func attemptToNext() {
        if (questionNum < (selected!.questionNumbers-1)){
            selected!.questions[questionNum].answerAudioPath = recording.stopRecording()!.path
            questionNum += 1
            recording.startRecording()
        } else {
            stopTimer()
            selected!.questions[questionNum].answerAudioPath = recording.stopRecording()!.path
            questionNum = -4
        }
    }
    
}

#Preview{
    InterviewStartView(selected: .constant(DefaultInterviewType.test), running: .constant(true))
}
