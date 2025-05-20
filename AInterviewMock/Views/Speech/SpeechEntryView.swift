//
//  SpeechEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//

import SwiftUI

struct SpeechEntryView: View {
    @Binding var selected: SpeechProfile?
    @State private var templates: [SpeechProfile] = []
    @State private var alreadyHaveData: Bool = false
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text(NSLocalizedString("SpeechEntryView_titleLine1", comment: "First line of the title on the interview type selection screen"))
                Text(NSLocalizedString("SpeechEntryView_titleLine2", comment: "Second line of the title on the interview type selection screen"))
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                VStack(alignment: .leading){
                    Color.clear
                        .frame(height: 5)
                    if (alreadyHaveData){
                        Text(NSLocalizedString("SpeechEntryView_draftSectionTitle", comment: "Section Title for Draft"))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        if let selected = selected {
                            typeBuilder(of: selected)
                        }
                    } else {
                        Text(NSLocalizedString("SpeechEntryView_templateSectionTitle", comment: "Section title for 'Templates' list"))
                            .foregroundStyle(Color(.systemGray))
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        ForEach(templates) { template in
                            typeBuilder(of: template)
                        }
                    }
                    Color.clear
                        .frame(height: 300)
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
        .onAppear {
            templates = [
                DefaultSpeechProfile.general,
                DefaultSpeechProfile.academic,
                DefaultSpeechProfile.selfIntro,
                DefaultSpeechProfile.inspirational,
                DefaultSpeechProfile.instructional,
                DefaultSpeechProfile.persuasive,
                DefaultSpeechProfile.ceremonial,
                DefaultSpeechProfile.demonstrative
                ]
            
            if selected?.status == .prepared {
                // 外部傳入
                alreadyHaveData = true
            }
        }
    }
    
    private func typeBuilder(of obj: SpeechProfile) -> some View {
        VStack{
            HStack(spacing: 5){
                Image(systemName: "\(obj.templateImage)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color(.accent))
                    .padding()
                VStack(alignment: .leading){
                    Text(obj.templateName)
                        .font(.title2)
                        .bold()
                    Text(obj.templateDescription)
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


#Preview {
    SpeechEntryView(selected: .constant(DefaultSpeechProfile.test))
}
