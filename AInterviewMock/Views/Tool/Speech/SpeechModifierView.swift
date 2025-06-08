//
//  SpeechModifierView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//

import SwiftUI

struct SpeechModifierView: View {
    
    @Binding var selected: SpeechProfile?
    @State private var focusState: Int = -1

    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(NSLocalizedString("SpeechModifierView_titleLine1", comment: "First line of the title on the Speech modification/start screen"))
                Text(NSLocalizedString("SpeechModifierView_titleLine2", comment: "Second line of the title on the Speech modification/start screen"))
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                Color.clear
                    .frame(height: 5)
                VStack(alignment: .leading, spacing: 15){
                    
                    Text(NSLocalizedString("SpeechModifierView_costSectionTitle", comment: "Section title for 'Cost to start'"))
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
                            Text(NSLocalizedString("SpeechModifierView_explanationTitle", comment: "Title for the explanation section about cost and starting the Speech"))
                                .bold()
                            Spacer()
                        }
                        Text(String(format: NSLocalizedString("SpeechModifierView_explanationBodyCost", comment: "Explanation text about the cost of the Speech. Contains one integer placeholder for the cost."), selected!.cost))
                        Text(NSLocalizedString("SpeechModifierView_explanationBodyInsufficientCoins", comment: "Explanation text for what to do if coins are insufficient."))
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
                                Text(NSLocalizedString("SpeechModifierView_insufficientCoinsTitle", comment: "Title for the insufficient coins warning section"))
                                    .bold()
                                Spacer()
                            }
                            Text(String(format: NSLocalizedString("SpeechModifierView_insufficientCoinsBody", comment: "Warning message when user has insufficient coins. Contains two integer placeholders: required cost and current coins."), selected!.cost, CoinManager.shared.coins))
                            Text(NSLocalizedString("SpeechModifierView_insufficientCoinsSuggestion", comment: "Suggestion when user has insufficient coins."))
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
                    
                    
                    Text(NSLocalizedString("SpeechModifierView_askedQuestionCountSectionTitle", comment: "Section title for 'Number of Questions'"))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 5){
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("SpeechModifierView_questionCountLabel", comment: "Label for 'Number of Asked Questions' display"))
                                .bold()
                                .foregroundStyle(Color(.accent))
                            HStack(alignment: .bottom){
                                Text("\(selected!.askedQuestionNumbers)")
                                    .bold()
                                    .font(.largeTitle)
                                Text(NSLocalizedString("SpeechModifierView_askedQuestionCountUnit", comment: "Unit for question count, e.g., 'questions' or 'items'"))
                                    .bold()
                                    .padding(.bottom, 5)
                                Spacer()
                            }
                        }
                        HStack(spacing: 3){
                            Button {
                                selected!.askedQuestionNumbers = 0
                                selected!.cost = calculatecost()
                                focusState = 3
                            } label: {
                                HStack{
                                    Spacer()
                                    Text(NSLocalizedString("SpeechModifierView_questionCountButtonNone", comment: "Button text for none number of questions (e.g., 0)"))
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
                                selected!.askedQuestionNumbers = 3
                                selected!.cost = calculatecost()
                                focusState = 3
                            } label: {
                                HStack{
                                    Spacer()
                                    Text(NSLocalizedString("SpeechModifierView_questionCountButtonBasic", comment: "Button text for Basic number of questions (e.g., 3)"))
                                    Spacer()
                                }
                            }
                            .padding(5)
                            .foregroundStyle(Color(.white))
                            .background(Color(.accent))
                            Button {
                                selected!.askedQuestionNumbers = 5
                                selected!.cost = calculatecost()
                                focusState = 3
                            } label: {
                                HStack{
                                    Spacer()
                                    Text(NSLocalizedString("SpeechModifierView_questionCountButtonMore", comment: "Button text for moderate number of questions (e.g., 5)"))
                                    Spacer()
                                }
                            }
                            .padding(5)
                            .foregroundStyle(Color(.white))
                            .background(Color(.accent))
                            Button {
                                selected!.askedQuestionNumbers = 10
                                selected!.cost = calculatecost()
                            } label: {
                                HStack{
                                    Spacer()
                                    Text(NSLocalizedString("SpeechModifierView_questionCountButtonFull", comment: "Button text for Full number of questions (e.g., 10)"))
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
                    
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "trash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text(NSLocalizedString("SpeechModifierView_resetToDefaultButton", comment: "Button text to reset settings to default"))
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
                        selected!.askedQuestionNumbers = 0
                        focusState = -1
                    }
                    .padding(.horizontal)
                }
                
                Color.clear
                    .frame(height: 300)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            selected!.cost = calculatecost()
        }
    }
        
    private func calculatecost() -> Int {
        // 初始：10
        var cost: Int = 5
        
        // 一個檔案 +2
        cost += selected!.filesPath.count
        
        // 一個題目 +1
        cost += selected!.askedQuestionNumbers
        
        return cost
    }
}

#Preview{
    SpeechModifierView(selected: .constant(DefaultSpeechProfile.test))
}
