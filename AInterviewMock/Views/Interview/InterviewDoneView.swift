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
                Text(NSLocalizedString("InterviewDoneView_titleLine1", comment: "First line of the title on the final review screen before starting interview"))
                Text(NSLocalizedString("InterviewDoneView_titleLine2", comment: "Second line of the title on the final review screen"))
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
                            Text(NSLocalizedString("InterviewDoneView_section1TitleInterviewType", comment: "Section title for 'Interview Type' review"))
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
                            Text(NSLocalizedString("InterviewDoneView_section2TitleInterviewDetails", comment: "Section title for 'Interview Details' (pre-questions) review"))
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
                                        Text(NSLocalizedString("InterviewDoneView_noAnswerProvided", comment: "Indicator text when no answer was provided for a pre-question"))
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
                            Text(NSLocalizedString("InterviewDoneView_section3TitleDataPreparation", comment: "Section title for 'Data Preparation' (files) review"))
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
                                Text(NSLocalizedString("InterviewDoneView_noDataProvided", comment: "Indicator text when no files were provided"))
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
                    .frame(height: 100)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
    }
}

#Preview {
    InterviewDoneView(selected: .constant(DefaultInterviewProfile.college))
}
