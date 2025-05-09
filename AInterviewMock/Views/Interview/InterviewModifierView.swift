//
//  InterviewModifierView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct InterviewModifierView: View {
    
    @Binding var selected: InterviewProfile?
    @State private var focusState: Int = -1

    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text("面試")
                Text("準備開始！")
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                Color.clear
                    .frame(height: 5)
                VStack(alignment: .leading, spacing: 15){
                    
                    Text("啟動花費")
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                
                    VStack(alignment: .leading){
                        HStack{
                            Spacer()
                            VStack{
                                Image(systemName: "hockey.puck.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundStyle(Color("AppGold"))
                                Text("\(selected!.cost)")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(Color(.accent))
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "info.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.accent))
                            Text("說明")
                                .bold()
                            Spacer()
                        }
                        Text("此模擬面試需花費 \(selected!.cost) 個代幣。下一步開始面試，將生成面試題目並開始回答，此時已扣除面試花費，請勿離開程式！")
                        Text("代幣不足嗎？您可以點選「暫存」，本頁之前的設定都已保留，之後再從紀錄選取進行面試。")
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                focusState == -1
                                ? Color.accentColor
                                : Color(.systemGray3),
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                    
                    if (selected!.cost > CoinManager.shared.coins){
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "exclamationmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.red))
                                Text("代幣不足")
                                    .bold()
                                Spacer()
                            }
                            Text("此模擬面試需花費 \(selected!.cost) 個代幣，您只有 \(CoinManager.shared.coins)) 個代幣。")
                            Text("請先「暫存」，並購買或獲得一些代幣再嘗試。")
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke( Color(.red),
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                    }
                    
                    
                    Text("題目數量")
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 5){
                        VStack(alignment: .leading){
                            Text("題目數量")
                                .bold()
                                .foregroundStyle(Color(.accent))
                            HStack(alignment: .bottom){
                                Text("\(selected!.questionNumbers)")
                                    .bold()
                                    .font(.largeTitle)
                                Text("題")
                                    .bold()
                                    .padding(.bottom, 5)
                                Spacer()
                            }
                        }
                        HStack(spacing: 3){
                            Button {
                                selected!.questionNumbers = 5
                                selected!.cost = calculatecost()
                                focusState = 3
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("基礎")
                                    Spacer()
                                }
                            }
                            .padding(5)
                            .foregroundStyle(Color(.white))
                            .background(Color(.accent))
                            .clipShape(
                                .rect(topLeadingRadius: 5, bottomLeadingRadius: 5, bottomTrailingRadius: 0, topTrailingRadius: 0)
                            )
                            Button {
                                selected!.questionNumbers = 10
                                selected!.cost = calculatecost()
                                focusState = 3
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("適中")
                                    Spacer()
                                }
                            }
                            .padding(5)
                            .foregroundStyle(Color(.white))
                            .background(Color(.accent))
                            Button {
                                selected!.questionNumbers = 15
                                selected!.cost = calculatecost()
                                focusState = 3
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("完整")
                                    Spacer()
                                }
                            }
                            .padding(5)
                            .foregroundStyle(Color(.white))
                            .background(Color(.accent))
                            Button {
                                selected!.questionNumbers = 20
                                selected!.cost = calculatecost()
                            } label: {
                                HStack{
                                    Spacer()
                                    Text("大量")
                                    Spacer()
                                }
                            }
                            .padding(5)
                            .foregroundStyle(Color(.white))
                            .background(Color(.accent))
                            .clipShape(
                                .rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 5, topTrailingRadius: 5)
                            )
                        }
                        
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                focusState == 3
                                ? Color.accentColor
                                : Color(.systemGray3),
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                    
                    Text("進階調整器")
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("正式程度")
                                .bold()
                                .foregroundStyle(Color(.accent))
                            Text(styleDescription(s: "正式", i: selected!.questionFormalStyle))
                                .bold()
                            Spacer()
                        }
                        Text("決定模擬面試的語氣與氣氛，輕鬆或正式。")
                            .foregroundStyle(Color(.systemGray))
                        
                        Slider(
                            value: Binding(
                                get: { selected!.questionFormalStyle },
                                set: { newValue in
                                    selected!.questionFormalStyle = newValue
                                }
                            ),
                            in: 0...1,
                            onEditingChanged: { _ in
                                focusState = 1
                            }
                        )
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                focusState == 1
                                ? Color.accentColor
                                : Color(.systemGray3),
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("嚴格程度")
                                .bold()
                                .foregroundStyle(Color(.accent))
                            Text(styleDescription(s: "嚴格", i: selected!.questionStrictStyle))
                                .bold()
                            Spacer()
                        }
                        Text("控制問題的深度與難度，根據你的準備程度來調整。")
                            .foregroundStyle(Color(.systemGray))
                        
                        Slider(
                            value: Binding(
                                get: { selected!.questionStrictStyle },
                                set: { newValue in
                                    selected!.questionStrictStyle = newValue
                                }
                            ),
                            in: 0...1,
                            onEditingChanged: { _ in
                                focusState = 2
                            }
                        )
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                focusState == 2
                                ? Color.accentColor
                                : Color(.systemGray3),
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "trash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("回復預設")
                                .bold()
                                .frame(minWidth: 20)
                            Spacer()
                        }
                        .foregroundStyle(Color(.red))
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke( Color(.red),
                                lineWidth: 2
                            )
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selected!.questionFormalStyle = 0.5
                        selected!.questionStrictStyle = 0.5
                        focusState = -1
                    }
                    .padding(.horizontal)
                }
                Color.clear
                    .frame(height: 200)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            selected!.cost = calculatecost()
        }
    }
    
    private func styleDescription(s: String, i: Double) -> String {
        if(i == 1) {
            "極為\(s)"
        } else if(i > 0.8){
            "\(s)"
        } else if (i > 0.6) {
            "偏\(s)"
        } else if (i > 0.4) {
            "一般"
        } else if (i > 0.2) {
            "偏不\(s)"
        } else if (i > 0) {
            "不\(s)"
        } else {
            "極為不\(s)"
        }
    }
    
    private func calculatecost() -> Int {
        // 初始：10
        var cost: Int = 10
        
        // 一個檔案 +2
        cost += selected!.filesPath.count
        
        // 一個題目 +1
        cost += selected!.questionNumbers
        
        return cost
    }
}

#Preview{
    InterviewModifierView(selected: .constant(DefaultInterviewType.college))
}
