//
//  InterviewEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI

struct InterviewEntryView: View {
    
    @Binding var selected: InterviewProfile?
    @State private var oldUnfinishedProfiles: [InterviewProfile] = []
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(NSLocalizedString("InterviewEntryView_titleLine1", comment: "First line of the title on the interview type selection screen"))
                Text(NSLocalizedString("InterviewEntryView_titleLine2", comment: "Second line of the title on the interview type selection screen"))
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                VStack(alignment: .leading){
                    Color.clear
                        .frame(height: 5)
                    Text(NSLocalizedString("InterviewEntryView_templateSectionTitle", comment: "Section title for 'Templates' list"))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    typeBuilder(of: DefaultInterviewType.college)
                    typeBuilder(of: DefaultInterviewType.jobGeneral)
                    typeBuilder(of: DefaultInterviewType.internship)
                    if (!oldUnfinishedProfiles.isEmpty){
                        Text(NSLocalizedString("InterviewEntryView_unfinishedRecordsSectionTitle", comment: "Section title for 'Unfinished Records' list"))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.horizontal)
                        ForEach(oldUnfinishedProfiles) { item in
                            typeBuilder(of: item)
                        }
                    }
                    Color.clear
                        .frame(height: 200)
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            oldUnfinishedProfiles = DataManager.shared.loadAllInterviewTypes().filter({$0.status == 1})
        }
    }
    
    private func typeBuilder(of obj: InterviewProfile) -> some View {
        VStack{
            HStack(spacing: 5){
                Image(systemName: "\(obj.templateImage)") // This is dynamic from obj
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color(.accent))
                    .padding()
                VStack(alignment: .leading){
                    Text(obj.templateName) // Assumed to be already localized string from InterviewProfile
                        .font(.title2)
                        .bold()
                    Text(obj.templateDescription) // Assumed to be already localized string from InterviewProfile
                        .foregroundStyle(Color(.systemGray))
                }
                Spacer()
            }
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selected?.templateName == obj.templateName ? Color(.accent) : Color(.systemGray3), lineWidth: selected?.templateName == obj.templateName ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selected = obj
        }
        .padding(.horizontal)
    }
}

#Preview{
    InterviewEntryView(selected: .constant(nil))
}
