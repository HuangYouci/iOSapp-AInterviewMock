//
//  InterviewModifierView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

/*

struct InterviewModifierView: View {
    
    @Binding var selected: InterviewProfile?
    @State private var focusState: Int = -1

    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(NSLocalizedString("InterviewModifierView_titleLine1", comment: "First line of the title on the interview modification/start screen"))
                Text(NSLocalizedString("InterviewModifierView_titleLine2", comment: "Second line of the title on the interview modification/start screen"))
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                Color.clear
                    .frame(height: 5)
                VStack(alignment: .leading, spacing: 15){
                    
                    Text(NSLocalizedString("InterviewModifierView_costSectionTitle", comment: "Section title for 'Cost to start'"))
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
                                Text("\(selected!.cost)") // Dynamic value
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
                            Text(NSLocalizedString("InterviewModifierView_explanationTitle", comment: "Title for the explanation section about cost and starting the interview"))
                                .bold()
                            Spacer()
                        }
                        Text(String(format: NSLocalizedString("InterviewModifierView_explanationBodyCost", comment: "Explanation text about the cost of the interview. Contains one integer placeholder for the cost."), selected!.cost))
                        Text(NSLocalizedString("InterviewModifierView_explanationBodyInsufficientCoins", comment: "Explanation text for what to do if coins are insufficient."))
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
                                Text(NSLocalizedString("InterviewModifierView_insufficientCoinsTitle", comment: "Title for the insufficient coins warning section"))
                                    .bold()
                                Spacer()
                            }
                            Text(String(format: NSLocalizedString("InterviewModifierView_insufficientCoinsBody", comment: "Warning message when user has insufficient coins. Contains two integer placeholders: required cost and current coins."), selected!.cost, CoinManager.shared.coins))
                            Text(NSLocalizedString("InterviewModifierView_insufficientCoinsSuggestion", comment: "Suggestion when user has insufficient coins."))
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
                    
                    
                    Text(NSLocalizedString("InterviewModifierView_questionCountSectionTitle", comment: "Section title for 'Number of Questions'"))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 5){
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("InterviewModifierView_questionCountLabel", comment: "Label for 'Number of Questions' display"))
                                .bold()
                                .foregroundStyle(Color(.accent))
                            HStack(alignment: .bottom){
                                Text("\(selected!.questionNumbers)") // Dynamic value
                                    .bold()
                                    .font(.largeTitle)
                                Text(NSLocalizedString("InterviewModifierView_questionCountUnit", comment: "Unit for question count, e.g., 'questions' or 'items'"))
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
                                    Text(NSLocalizedString("InterviewModifierView_questionCountButtonBasic", comment: "Button text for basic number of questions (e.g., 5)"))
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
                                    Text(NSLocalizedString("InterviewModifierView_questionCountButtonModerate", comment: "Button text for moderate number of questions (e.g., 10)"))
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
                                    Text(NSLocalizedString("InterviewModifierView_questionCountButtonFull", comment: "Button text for full number of questions (e.g., 15)"))
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
                                    Text(NSLocalizedString("InterviewModifierView_questionCountButtonExtensive", comment: "Button text for extensive number of questions (e.g., 20)"))
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
                    
                    Text(NSLocalizedString("InterviewModifierView_advancedAdjustmentsSectionTitle", comment: "Section title for 'Advanced Adjustments'"))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text(NSLocalizedString("InterviewModifierView_formalityLevelLabel", comment: "Label for 'Formality Level'"))
                                .bold()
                                .foregroundStyle(Color(.accent))
                            Text(styleDescription(s: NSLocalizedString("InterviewModifierView_formalityLevelAdj", comment: "Adj for 'Formality Level'"), i: selected!.questionFormalStyle))
                                .bold()
                            Spacer()
                        }
                        Text(NSLocalizedString("InterviewModifierView_formalityLevelDescription", comment: "Description for formality level slider."))
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
                            Text(NSLocalizedString("InterviewModifierView_strictnessLevelLabel", comment: "Label for 'Strictness Level'"))
                                .bold()
                                .foregroundStyle(Color(.accent))
                            Text(styleDescription(s: NSLocalizedString("InterviewModifierView_strictnessLevelAdj", comment: "Adj for 'Strictness Level'"), i: selected!.questionStrictStyle))
                                .bold()
                            Spacer()
                        }
                        Text(NSLocalizedString("InterviewModifierView_strictnessLevelDescription", comment: "Description for strictness level slider."))
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
                            Text(NSLocalizedString("InterviewModifierView_resetToDefaultButton", comment: "Button text to reset settings to default"))
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
                    .frame(height: 300)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            selected!.cost = calculatecost()
        }
    }
    
    private func styleDescription(s: String, i: Double) -> String {
        if(i == 1) {
            NSLocalizedString("InterviewModifierView_adjExtremely", comment: "Adj Extremely") + s
        } else if(i > 0.8){
            s
        } else if (i > 0.6) {
            NSLocalizedString("InterviewModifierView_adjBit", comment: "Adj Bit") + s
        } else if (i > 0.4) {
            NSLocalizedString("InterviewModifierView_adjNormal", comment: "Adj Normal")
        } else if (i > 0.2) {
            NSLocalizedString("InterviewModifierView_adjBitNot", comment: "Adj Bit not") + s
        } else if (i > 0) {
            NSLocalizedString("InterviewModifierView_adjNot", comment: "Adj Not") + s
        } else {
            NSLocalizedString("InterviewModifierView_adjExtremelyNot", comment: "Adj Extremely Not") + s
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
    InterviewModifierView(selected: .constant(DefaultInterviewProfile.college))
}

*/
