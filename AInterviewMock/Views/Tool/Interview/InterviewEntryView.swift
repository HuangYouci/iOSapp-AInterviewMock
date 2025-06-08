//
//  InterviewEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI

struct InterviewEntryView: View {
    
    @Binding var selected: InterviewProfile?
    @State private var templates: [InterviewProfile] = []
    
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
                        .padding(.vertical, 5)
                    ForEach(templates) { template in
                        typeBuilder(of: template)
                    }
                    Color.clear
                        .frame(height: 300)
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            templates = [
                    DefaultInterviewProfile.college,
                    DefaultInterviewProfile.jobGeneral,
                    DefaultInterviewProfile.internship
                ]
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
                .stroke(selected?.id == obj.id ? Color(.accent) : Color(.systemGray3), lineWidth: selected?.id == obj.id ? 2 : 1)
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
