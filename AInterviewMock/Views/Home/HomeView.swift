//
//  HomeView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var ups: UserProfileService
    @EnvironmentObject var vm: ViewManager
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack{
                Text("inif")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
                Button {
                    vm.addPage(.appinfo)
                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color("AccentBackgroundP1"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Button {
                    vm.addPage(.profile)
                } label: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color("AccentBackgroundP1"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .foregroundStyle(Color(.white))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .padding(.bottom, 5)
            
            ScrollView{
                VStack(alignment: .leading){
                    
                    VStack(alignment: .leading){
                        HStack{
                            Button {
                                vm.addPage(.toolInterview)
                            } label: {
                                VStack(alignment: .leading){
                                    Text("模擬面試")
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
                                    Image("HomeView_Img1")
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
                                .background(Color("AccentBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        HStack{
                            Button {
                                // vm.addPage(view: SpeechView())
                            } label: {
                                VStack(alignment: .leading){
                                    Text("模擬演講")
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
                                    Image("HomeView_Img2")
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
                                .background(Color("AccentBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        HStack{
                            Button {
                                vm.addPage(.shop)
                            } label: {
                                VStack(alignment: .leading){
                                    Text("代幣")
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(Color(.white))
                                    HStack{
                                        Spacer()
                                    }
                                }
                                .padding()
                                .background(
                                    Image("HomeView_Img3")
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
                                .background(Color("AccentBackground"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(25)
                    .frame(maxWidth: .infinity)
                    .background(Color("Background"))
                    .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .fixedSize(horizontal: false, vertical: true)
            
            Color("Background")
                .ignoresSafeArea(edges: [.bottom])
        }
        .background(Color("AccentBackground"))
    }
    
}
