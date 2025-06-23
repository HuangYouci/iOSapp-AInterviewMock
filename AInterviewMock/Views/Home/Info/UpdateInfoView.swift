//
//  UpdateInfoView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/18.
//

import SwiftUI

struct UpdateInfoView: View {
    
    @EnvironmentObject var uc: UpdateChecker
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack{
                Text("inif")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.bottom, 5)
                Text("檢測到版本更新！")
                Text("目前程式版本是 \(uc.thisVersion)，最新版本為 \(uc.newestVersion)")
            }
            .foregroundStyle(Color(.white))
            Spacer()
            VStack{
                Link(destination: URL(string: "https://apps.apple.com/tw/app/id6745684106")!){
                    HStack{
                        Text("至 App Store 更新")
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color(.systemGray))
                            .frame(width: 15, height: 15)
                    }
                }
            }
            .inifBlock(bgColor: Color("BackgroundR1"))
            .padding(.bottom, 10)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AccentBackground"))
    }
}

#Preview {
    UpdateInfoView()
        .environmentObject(UpdateChecker())
}
