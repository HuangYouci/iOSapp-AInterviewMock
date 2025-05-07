//
//  InterviewDoneView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/6.
//

import SwiftUI

struct InterviewDoneView: View {
    
    @Binding var selected: InterviewProfile?
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text("準備就緒")
                Text("再檢查一下面試設定吧！")
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                Color.clear
                    .frame(height: 5)
                VStack(alignment: .leading, spacing: 25){
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "1.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("面試類型")
                                .bold()
                                .font(.title3)
                            Spacer()
                        }
                        .foregroundStyle(Color(.accent))
                        HStack{
                            Text(selected!.templateName)
                        }
                    }
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "2.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("面試細節")
                                .bold()
                                .font(.title3)
                            Spacer()
                        }
                        .foregroundStyle(Color(.accent))
                        ForEach(selected!.preQuestions){ item in
                            VStack(alignment: .leading, spacing: 5){
                                Text(item.question)
                                HStack{
                                    Image(systemName: "arrow.turn.down.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 10)
                                    if (item.answer.isEmpty){
                                        Text("無作答")
                                            .foregroundStyle(Color(.systemGray))
                                    } else {
                                        Text(item.answer)
                                    }
                                }
                            }
                            .padding(.bottom, 5)
                        }
                    }
                    VStack(alignment: .leading, spacing: 15){
                        HStack{
                            Image(systemName: "3.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("資料準備")
                                .bold()
                                .font(.title3)
                            Spacer()
                        }
                        .foregroundStyle(Color(.accent))
                        if let selected = selected {
                            ForEach(selected.filesPath.indices, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 5) {
                                    let path = selected.filesPath[index]
                                    Text(URL(fileURLWithPath: path).lastPathComponent)
                                        .lineLimit(1)
                                }
                            }
                            if (selected.filesPath.isEmpty){
                                Text("無資料")
                                    .foregroundStyle(Color(.systemGray))
                            }
                        }
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.accentColor,
                            lineWidth: 2
                        )
                )
                .contentShape(Rectangle())
                .padding(.horizontal)
                Color.clear
                    .frame(height: 200)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
    }
}

#Preview {
    InterviewDoneView(selected: .constant(DefaultInterviewType.college))
}
