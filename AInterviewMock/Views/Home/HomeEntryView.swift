//
//  HomeEntryView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct HomeEntryView: View {
    
    @Binding var currentPage: Int
    @State private var runningMockInterview: Bool = false
    
    @State private var displayCoinView: Bool = false
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                HStack{
                    Button {
                        runningMockInterview = true
                    } label: {
                        VStack{
                            Text(NSLocalizedString("HomeEntryView_startMockInterviewButton", comment: "Button text to start a mock interview"))
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
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)){
                            currentPage = 1
                        }
                    } label: {
                        VStack(alignment: .leading){
                            Text(NSLocalizedString("HomeEntryView_manageResultsButton", comment: "Button text to navigate to manage interview results"))
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
                }
                .padding(.horizontal)
                
                Button {
                    displayCoinView = true
                } label: {
                    VStack(alignment: .leading){
                        Text(NSLocalizedString("HomeEntryView_coinsButton", comment: "Button text to navigate to the coin/store view"))
                            .font(.title)
                            .bold()
                            .foregroundStyle(Color(.white))
                        HStack{
                            Spacer()
                        }
                    }
                    .padding()
                    .frame(height: 100, alignment: .topLeading)
                    .background(
                        Image(systemName: "hockey.puck.circle.fill")
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
                            .offset(x: 160, y: 20)
                            .foregroundStyle(Color(.white))
                    )
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 252 / 255, green: 101 / 255, blue: 7 / 255),
                                Color(red: 255 / 255, green: 95 / 255, blue: 207 / 255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
            }
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .fullScreenCover(isPresented: $runningMockInterview){
            InterviewView(running: $runningMockInterview)
        }
        .fullScreenCover(isPresented: $displayCoinView) {
            HStack{
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text(NSLocalizedString("HomeEntryView_coinViewTitle", comment: "Title displayed at the top of the coin view/store screen"))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(.accent))
                Spacer()
                Button {
                    displayCoinView = false
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            .background(Color(.systemBackground).opacity(0.3))
            .background(.ultraThinMaterial)
            CoinView()
        }
        
    }
}

#Preview {
    HomeView()
}

#Preview{
    HomeEntryView(currentPage: .constant(1))
}
