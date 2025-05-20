//
//  SpeechQuesView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//

import SwiftUI

struct SpeechQuesView: View {
    
    enum FocusedField: Hashable {
        case question(index: Int)
    }
    
    @Binding var selected: SpeechProfile?
    @State private var selectionQuestions: [SpeechProfilePreQuestions] = []
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(NSLocalizedString("SpeechQuesView_titleLine1", comment: "First line of the title on the pre-speech questions screen"))
                Text(NSLocalizedString("SpeechQuesView_titleLine2", comment: "Second line of the title on the pre-speech questions screen"))
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                Color.clear
                    .frame(height: 5)
                VStack(alignment: .leading, spacing: 15){
                    ForEach(selectionQuestions.indices, id: \.self){ index in
                        VStack(alignment: .leading){
                            HStack{
                                Text("\(index+1)")
                                    .bold()
                                    .foregroundStyle(Color(.accent))
                                    .frame(minWidth: 20)
                                Text(selectionQuestions[index].question)
                                if (selectionQuestions[index].required){
                                    Spacer()
                                    Text(NSLocalizedString("SpeechQuesView_requiredFieldIndicator", comment: "Indicator text for a required field, e.g., 'Required'"))
                                        .foregroundStyle(Color(.red))
                                }
                            }
                            TextField(NSLocalizedString("SpeechQuesView_answerTextFieldPlaceholder", comment: "Placeholder text for the answer input field"), text: $selectionQuestions[index].answer)
                                .focused($focusedField, equals: .question(index: index))
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    focusedField == .question(index: index)
                                    ? Color.accentColor
                                    : Color(.systemGray3),
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                    }
                }
                
                Color.clear
                    .frame(height: 300)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            if let selected = selected {
                selectionQuestions = selected.preQuestions
            }
        }
        .onChange(of: selectionQuestions){ _ in
            if selected != nil {
                selected!.preQuestions = selectionQuestions
            }
        }
    }
}

#Preview{
    SpeechQuesView(selected: .constant(DefaultSpeechProfile.test))
}

