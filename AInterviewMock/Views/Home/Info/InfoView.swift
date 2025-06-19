//
//  InfoView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/18.
//

import SwiftUI

struct InfoView: View {
    
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var uc: UpdateChecker
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Button{
                    vm.perviousPage()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color("AccentBackgroundP1"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
            }
            .foregroundStyle(Color(.white))
            .padding(.horizontal)
            .padding(.vertical, 5)
            .padding(.bottom, 5)
            
            ScrollView{
                VStack(alignment: .leading){
                    
                    HStack{
                        Text("inif")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(Color(.white))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    VStack(alignment: .leading){
                        
                        Text("程式資訊")
                            .foregroundStyle(Color(.systemGray))
                            .font(.caption)
                        
                        VStack{
                            HStack{
                                Text("版本")
                                Spacer()
                                if(uc.status == .higher){
                                    Text("測試版")
                                        .foregroundStyle(Color(.systemGray))
                                }
                                Text(uc.thisVersion)
                                    .foregroundStyle(Color(.systemGray))
                            }
                        }
                        .padding()
                        .background(Color("BackgroundR1"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom, 10)
                        
                        Text("開發者資訊")
                            .foregroundStyle(Color(.systemGray))
                            .font(.caption)
                        
                        VStack{
                            HStack{
                                Text("開發者")
                                Spacer()
                                Text("YC")
                                    .foregroundStyle(Color(.systemGray))
                            }
                            Divider()
                                .padding(.vertical, 6.5)
                            HStack{
                                Text("開發者信箱")
                                Spacer()
                                Text("ycdev@icloud.com")
                            }
                        }
                        .padding()
                        .background(Color("BackgroundR1"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom, 10)
                        
                        Text("條款與政策")
                            .foregroundStyle(Color(.systemGray))
                            .font(.caption)
                        
                        VStack{
                            Link(destination: URL(string: "https://huangyouci.github.io/app/eula")!){
                                HStack{
                                    Text("使用條款")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color(.systemGray))
                                        .frame(width: 15, height: 15)
                                }
                            }
                            Divider()
                                .padding(.vertical, 6.5)
                            Link(destination: URL(string: "https://huangyouci.github.io/app/privacypolicy")!){
                                HStack{
                                    Text("隱私政策")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color(.systemGray))
                                        .frame(width: 15, height: 15)
                                }
                            }
                        }
                        .padding()
                        .background(Color("BackgroundR1"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom, 10)
                        
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
        .navigationBarHidden(true)
    }
}
