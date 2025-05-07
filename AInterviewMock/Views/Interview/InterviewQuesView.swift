//
//  InterviewQuesView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/5.
//
import SwiftUI

struct InterviewQuesView: View {
    
    enum FocusedField: Hashable {
        case question(index: Int)
    }
    
    @Binding var selected: InterviewProfile?
    @State private var selectionQuestions: [InterviewProfilePreQuestions] = []
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                Text("告訴我們")
                Text("面試的細節吧！")
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
                                    Text("必填")
                                        .foregroundStyle(Color(.red))
                                }
                            }
                            TextField("答案", text: $selectionQuestions[index].answer)
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
                    .frame(height: 200)
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
    InterviewQuesView(selected: .constant(DefaultInterviewType.college))
}
