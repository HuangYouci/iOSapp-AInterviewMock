//
//  HomeEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct HomeEntryView: View {
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                Color.clear
                    .frame(height: 10)
                
                HStack{
                    Button {
                        ViewManager.shared.addPage(view: InterviewView())
                    } label: {
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("HomeEntryView_startMockInterviewButton", comment: "Button text to start a mock interview"))
                                .font(.title)
                                .bold()
                                .foregroundStyle(Color(.white))
                            HStack{
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(height: 200, alignment: .topLeading)
                        .background(
                            Image("HomeEntryView_interviewIllu")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 400, height: 200)
                                .mask(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .white]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .offset(x: 50)
                        )
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 122 / 255, green: 121 / 255, blue: 217 / 255),
                                    Color(red: 88 / 255, green: 86 / 255, blue: 207 / 255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                
                HStack{
                    Button {
                        ViewManager.shared.addPage(view: SpeechView())
                    } label: {
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("HomeEntryView_startMockSpeechButton", comment: "Button text to start a mock speech"))
                                .font(.title)
                                .bold()
                                .foregroundStyle(Color(.white))
                            HStack{
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(height: 200, alignment: .topLeading)
                        .background(
                            Image("HomeEntryView_speechIllu")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 400, height: 200)
                                .mask(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .white]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .offset(x: 50)
                        )
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 122 / 255, green: 121 / 255, blue: 217 / 255),
                                    Color(red: 88 / 255, green: 86 / 255, blue: 207 / 255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                
            }
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        
    }
    
}

#Preview {
    HomeView()
}

#Preview{
    HomeEntryView()
}
