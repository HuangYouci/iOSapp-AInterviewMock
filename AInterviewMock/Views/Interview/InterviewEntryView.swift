//
//  InterviewEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI

struct InterviewEntryView: View {
    
    @Binding var selected: InterviewProfile?
    @State private var selectionID: UUID = UUID()
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text("你想練習")
                Text("什麼面試呢？")
            }
            .font(.largeTitle)
            .bold()
            .padding(.horizontal)
            ScrollView{
                Color.clear
                    .frame(height: 5)
                typeBuilder(of: DefaultInterviewType.college)
                Color.clear
                    .frame(height: 200)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        }
    }
    
    private func typeBuilder(of obj: InterviewProfile) -> some View {
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
                .stroke(selectionID == obj.id ? Color(.accent) : Color(.systemGray3), lineWidth: selectionID == obj.id ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectionID = obj.id
            selected = obj
        }
        .padding(.horizontal)
    }
}

#Preview{
    InterviewEntryView(selected: .constant(nil))
}
