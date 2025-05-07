//
//  InterviewStartView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct InterviewStartView: View {
    
    @Binding var selected: InterviewProfile?
    
    @State private var questionNum: Int = 0
    @State private var timerSeconds: Int = 0
    
    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                ScrollView{
                    Color.clear
                        .frame(height: 50)
                    if (questionNum == 0){
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
                            // 注意測試時要關掉自動
                            Task {
                                selected!.questions = await GeminiService.shared.generateInterviewQuestions(from: selected!)
                                if (selected!.questions.count) > 0 {
                                    questionNum = 1 // 開始並扣款
                                } else {
                                    questionNum = -1 // 錯誤訊息不扣款
                                }
                            }
                        }
                    } else {
                        ForEach(selected!.questions) { q in
                            VStack(alignment: .leading){
                                HStack{
                                    Text("題目")
                                        .foregroundStyle(Color(.accent))
                                        .bold()
                                    Spacer()
                                }
                                Text(q.question)
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
                    }
                    
                    Color.clear
                        .frame(height: 200)
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
                            if (questionNum > 0){
                                HStack(alignment: .top, spacing: 3){
                                    Text("問題")
                                        .padding(.top, 3)
                                    Text("\(questionNum)")
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                HStack(alignment: .top, spacing: 3){
                                    Spacer()
                                    Text("00:01")
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
        }
    }
    
}

#Preview{
    InterviewStartView(selected: .constant(DefaultInterviewType.college))
}
