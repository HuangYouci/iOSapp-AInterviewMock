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
    @State private var questionNum: Int = -2 //
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
                                Text("發生錯誤")
                                    .bold()
                                Spacer()
                            }
                            Text("模擬面試執行時發生錯誤。")
                            Text("請再次嘗試。若需協助，請來信開發者信箱。")
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
                                Text("模擬面試說明")
                                    .bold()
                                Spacer()
                            }
                            Text("已進入模擬面試。請在本畫面進行準備，點選下一步後將即刻開始模擬面試。模擬面試無法暫停、亦無法重新開始，請務必謹慎進行！")
                            Text("開始後，程式將依序詢問 \(selected!.questionNumbers) 個問題，每個問題都需語音錄製回答。在完成該題後，請點選「下一步」直至完成。每一題都需回答。")
                            Text("模擬面試進行時請保持程式開啟並保持網路暢通。點選「開始」後代幣將扣除，此時意外的離開程式將導致不可逆的代幣扣款。")
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
                                Text("時間限制")
                                    .bold()
                                Spacer()
                            }
                            Text("本面試的回答時間上限為 \(selected!.questionNumbers * 2) 分鐘。")
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
                                    Text("麥克風權限")
                                        .bold()
                                    Spacer()
                                }
                                Text("程式需要麥克風權限以進行模擬面試。目前權限已正確賦予。")
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
                                    Text("麥克風權限")
                                        .bold()
                                    Spacer()
                                }
                                Text("程式需要麥克風權限以進行模擬面試，請至設定中讓本程式擁有麥克風權限。")
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
                                    Text("模擬面試載入中")
                                        .bold()
                                    Spacer()
                                    ProgressView()
                                        .frame(width: 15, height: 15)
                                }
                                Text("請勿關閉程式且請保持網路暢通！")
                                Text("程式正在依據面試設定與檔案資料生成面試問題。生成完畢之後，將即刻開始進行模擬面試！")
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
                                    questionNum = 0 // 開始並扣款
                                    CoinManager.shared.removeCoin(selected!.cost)
                                    recording.startRecording()
                                    startTimer()
                                } else {
                                    questionNum = -1 // 錯誤訊息不扣款
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
                                    Text("分析中")
                                        .bold()
                                    Spacer()
                                    ProgressView()
                                        .frame(width: 15, height: 15)
                                }
                                Text("請勿關閉程式且請保持網路暢通！")
                                Text("程式正在依據您的回答來產生面試結果。")
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
                                // 轉存檔案
                                DataManager.shared.saveInterviewTypeAudios(interviewProfile: &selected!)
                                // 分析音訊
                                for index in selected!.questions.indices {
                                    selected!.questions[index].answer = await GeminiService.shared.generateAudioText(source: selected!.questions[index].answerAudioPath)
                                }
                                // 重頭戲：分析結果
                                var selectedTemp = selected!
                                await GeminiService.shared.generateInterviewFeedback(interviewProfile: &selectedTemp)
                                selected! = selectedTemp
                                // 完成後切換
                                DataManager.shared.saveInterviewTypeJSON(selected!)
                                questionNum = -5
                            }
                        }
                    case -5:
                        InterviewAnalysisView(selected: .constant(selected!))
                    default:
                        // 正式題目
                        VStack(alignment: .leading){
                            HStack{
                                Text("題目")
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
                                Text("回答錄製中")
                                    .bold()
                                Spacer()
                            }
                            Text("目前正錄製您的回答。")
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
                                    Text("時間限制")
                                        .bold()
                                    Spacer()
                                }
                                Text("即將超過時間限制。到達時間限制後，將直接結束面試，未回答的問題可能導致低分。剩餘 \((selected!.questionNumbers*2*60) - timerSeconds) 秒。")
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
                                    Text("問題")
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
                                Text("模擬面試")
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
                                        Text(questionNum+1 == selected!.questionNumbers ? "完成" : "下一題")
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
                                    // 正常開始
                                    Button {
                                        questionNum = -3
                                    } label: {
                                        HStack{
                                            Text("開始")
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
                                    // 無麥克風
                                    HStack{
                                        Text("開始")
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
                                        Text("完成")
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
            
            // 時間限制
            if (timerSeconds > (selected!.questionNumbers*2*60)){
                questionNum = -4
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
            // NEXT QUESTION
            selected!.questions[questionNum].answerAudioPath = recording.stopRecording()!.path
            questionNum += 1
            recording.startRecording()
        } else {
            // FINAL QUESTION
            stopTimer()
            selected!.questions[questionNum].answerAudioPath = recording.stopRecording()!.path
            questionNum = -4 // 結束等待分析
        }
    }
    
}

#Preview{
    InterviewStartView(selected: .constant(DefaultInterviewType.test), running: .constant(true))
}
