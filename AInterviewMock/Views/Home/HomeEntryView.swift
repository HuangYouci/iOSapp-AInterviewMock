//
//  HomeEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct HomeEntryView: View {
    
    @State private var runningMockInterview: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading){
            HStack{
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("模擬面試")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color(.accent))
                Spacer()
            }
            .padding(.bottom)
            .padding(.horizontal)
            .background(Color(.systemBackground).opacity(0.3))
            .background(.ultraThinMaterial)
            .padding(.bottom)
            
            HStack{
                Button {
                    runningMockInterview = true
                } label: {
                    VStack{
                        Text("開始模擬面試")
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color(.white))
                    }
                    .padding()
                    .frame(width: 250, height: 200, alignment: .topLeading)
                    .background(
                        Image("appasset01") // 請換成你的圖片資源名稱
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .white]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: 50, y: 20)
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
                
                VStack(alignment: .leading){
                    Text("管理結果")
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
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: 30, y: 50)
                )
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 72 / 255, green: 70 / 255, blue: 157 / 255),   // 更深的紫藍
                            Color(red: 52 / 255, green: 50 / 255, blue: 137 / 255)    // 更深的藍紫
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .fullScreenCover(isPresented: $runningMockInterview){
            InterviewView(running: $runningMockInterview)
        }
    }
}

#Preview {
    HomeView()
}

#Preview{
    HomeEntryView()
}
