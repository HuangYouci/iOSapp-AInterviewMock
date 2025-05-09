//
//  InterviewAnalysisView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI

struct InterviewAnalysisView: View {
    
    @Binding var selected: InterviewProfile
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 20){
                // Header
                VStack(alignment: .leading, spacing: 10){
                    HStack{
                        Text(selected.templateName)
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    Text(selected.templateDescription)
                    Text({
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd HH:mm"
                        return formatter.string(from: selected.date)
                    }())
                    .padding(.top, 40)
                }
                .foregroundStyle(Color(.white))
                .padding()
                .background(
                    Image(systemName: "\(selected.templateImage)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(x: 160, y: 70)
                        .foregroundStyle(Color(.white))
                )
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 52 / 255, green: 41 / 255, blue: 157 / 255),
                            Color(red: 108 / 255, green: 106 / 255, blue: 237 / 255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                // Overall Rating
                VStack(alignment: .leading){
                    Text("評分")
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "star.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.accent))
                            Text("評分")
                                .bold()
                            Spacer()
                        }
                        Text("\(selected.overallRating)")
                            .bold()
                            .font(.largeTitle)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor ,
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                }
                
                // Feedback
                VStack(alignment: .leading){
                    Text("評語")
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    ForEach(selected.feedbacks) { item in
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "star.bubble.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.accent))
                                Text("評語")
                                    .bold()
                                Spacer()
                                if (item.positive){
                                    Image(systemName: "hand.thumbsup.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color("AppGreen"))
                                }
                            }
                            Text(item.content)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.accentColor ,
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                    }
                }
                
                // Each Question Feedback
                VStack(alignment: .leading){
                    Text("回答")
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    ForEach(selected.questions) { item in
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "bubble.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.accent))
                                Text("問答")
                                    .bold()
                                Spacer()
                            }
                            Text("題目")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                                .padding(.top, 5)
                            Text(item.question)
                            
                            Text("回答")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                                .padding(.top, 5)
                            Text(item.answer)
                            
                            Text("反饋")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                                .padding(.top, 5)
                            Text(item.feedback)
                            
                            Text("參考評分")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                                .padding(.top, 5)
                            Text("\(item.score)")
                                .bold()
                                .font(.title3)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.accentColor ,
                                    lineWidth: 2
                                )
                        )
                        .padding(.horizontal)
                    }
                }
                
                // 空白
                Color.clear
                    .frame(height: 50)
            }
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
    }
}

#Preview {
    InterviewAnalysisView(selected: .constant(DefaultInterviewType.test))
}
