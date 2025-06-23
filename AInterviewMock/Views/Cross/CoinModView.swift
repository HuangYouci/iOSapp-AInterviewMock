//
//  CoinModView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/19.
//

import SwiftUI

struct CoinModView: View {
    
    enum CoinModViewType {
        case general
        case addBuy
        case addWatchAd
        case removePay
        case restore        // 預設，錯誤回覆
        
        var title: String {
            switch self {
            case .general:
                return "代幣異動"
            case .addBuy:
                return "購買代幣"
            case .addWatchAd:
                return "代幣獎勵"
            case .removePay:
                return "代幣支付"
            case .restore:
                return "未實現的代幣異動"
            }
        }
    }
    
    @EnvironmentObject var ups: UserProfileService
    @EnvironmentObject var am: AuthManager
    
    @State private var appear: Bool = false
    @State private var appearInitCoins: Int = 0
    @State private var buttonPushed: Bool = false
    
    var body: some View {
        ZStack{
            Color.clear.background(.ultraThinMaterial)
                .opacity(appear ? 1 : 0)
            
            VStack{
                Spacer()
                VStack(alignment: .leading, spacing: 12){
                    HStack{
                        Text("inif")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                    }
                    .padding([.horizontal, .top], 10)
                    
                    VStack(alignment: .leading, spacing: 10){
                        HStack(spacing: 10){
                            Image(systemName: "hockey.puck.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .padding(5)
                                .foregroundStyle(Color(.white))
                                .background(Color("AppGold"))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            Text(ups.pendingModifyCoinType.title)
                            Spacer()
                        }
                        VStack(alignment: .leading){
                            Text("異動數量")
                                .font(.caption)
                                .foregroundStyle(Color(.systemGray))
                            Text("\(ups.pendingModifyCoinNumber)")
                                .font(.title2)
                                .bold()
                        }
                        if let up = ups.currentUserProfile {
                            Divider()
                            Text("異動前 \(appearInitCoins) → 異動後 \(appearInitCoins + ups.pendingModifyCoinNumber)")
                            .font(.caption)
                            .foregroundStyle(Color(.systemGray))
                            .onAppear {
                                appearInitCoins = up.coins
                            }
                        }
                        if let email = ups.currentUserProfile?.userEmail {
                            Divider()
                            VStack(alignment: .leading){
                                Text("帳號：\(email)")
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color("BackgroundR1"))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    
                    if let error = ups.serviceError {
                        VStack(alignment: .leading, spacing: 10){
                            HStack(spacing: 10){
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .padding(5)
                                    .foregroundStyle(Color(.white))
                                    .background(Color("AppGold"))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text("發生錯誤")
                                Spacer()
                            }
                            Text(error.errorDescription)
                            Divider()
                            Text("尚未異動的代幣數量將保留，重啟 app 將會重新嘗試")
                                .foregroundStyle(Color(.systemGray))
                                .font(.caption)
                        }
                        .padding()
                        .background(Color("BackgroundR1"))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    } else {
                        HStack{
                            Spacer()
                            Button{
                                buttonPushed = true
                                ups.claimPendingCoins(for: am.user!.uid) { error in
                                    if let error = error {
                                        _ = error
                                    } else {
                                        withAnimation(.spring(duration: 0.3)) {
                                            appear = false
                                        }
                                        Task {
                                           try? await Task.sleep(for: .seconds(0.3))
                                            ups.setPendingCoins(amount: 0)
                                        }
                                    }
                                }
                            } label: {
                                if (buttonPushed) {
                                    LoadViewElement(circleLineWidth: 7)
                                        .frame(width: 40, height: 40)
                                } else {
                                    HStack{
                                        Text("確認")
                                            .font(.title3)
                                    }
                                    .padding(10)
                                    .padding(.horizontal)
                                    .foregroundStyle(Color.accentColor)
                                    .background(Color("BackgroundR1"))
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                }
                            }
                            .disabled(!appear || buttonPushed)
                            Spacer()
                        }
                    }
                    
                }
                .padding()
                .background(Color("Background"))
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .padding(10)
            }
            .offset(y: appear ? 0 : 500)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.spring(duration: 0.3)) {
                appear = true
            }
        }
        .onDisappear {
            appear = false
        }
    }
}

//#Preview {
//    ZStack{
//        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
//            .ignoresSafeArea(.all)
//        CoinModView()
//    }
//}
