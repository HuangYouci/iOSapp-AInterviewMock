//
//  CoinModView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/19.
//

import SwiftUI

/// PendingAdd：用於「代幣異動（正）」
/// 只能同意，不能取消。用於保存持久性（關閉 app 後會自動復原 -> 搭配 UPS, IAP）
/// 分類：general（未知原因）、addBuy（IAP）、addWatchAd（AdManager）、restore（關閉 app 復原）
struct CoinModView: View {
    
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
                    
                    if let request = ups.coinModifyRequest {
                        
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
                                Text(request.type.title)
                                Spacer()
                            }
                            VStack(alignment: .leading){
                                Text("異動數量")
                                    .font(.caption)
                                    .foregroundStyle(Color(.systemGray))
                                Text("\(request.amount)")
                                    .font(.title2)
                                    .bold()
                            }
                            if let up = ups.currentUserProfile {
                                Divider()
                                Text("異動前 \(appearInitCoins) → 異動後 \(appearInitCoins + ups.coinModifyRequest!.amount)")
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
                            
                            // 沒錯誤
                            
                            if (buttonPushed || !appear){
                                
                                // 載入中
                                HStack{
                                    Spacer()
                                    LoadViewElement(circleLineWidth: 7)
                                        .frame(width: 40, height: 40)
                                    Spacer()
                                }
                                .padding(.vertical, 3)
                                
                            } else {
                             
                                // 載入成功
                                
                                HStack{
                                    Spacer()
                                    
                                    if let oC = request.onCancel {
                                        Button {
                                            buttonPushed = true
                                            withAnimation(.spring(duration: 0.3)) {
                                                appear = false
                                            }
                                            Task {
                                                try? await Task.sleep(for: .seconds(0.3))
                                                ups.clearRequest()
                                            }
                                        } label: {
                                            HStack{
                                                Text("取消")
                                                    .font(.title3)
                                            }
                                            .padding(10)
                                            .padding(.horizontal)
                                            .foregroundStyle(Color.accentColor)
                                            .background(Color("BackgroundR1"))
                                            .clipShape(RoundedRectangle(cornerRadius: 25))
                                        }
                                    }
                                    
                                    Button {
                                        buttonPushed = true
                                        ups.modifyCoins(amount: ups.coinModifyRequest!.amount) { error in
                                            if let error = error {
                                                _ = error
                                            } else {
                                                if let oC = request.onConfirm {
                                                    oC()
                                                }
                                                withAnimation(.spring(duration: 0.3)) {
                                                    appear = false
                                                }
                                                Task {
                                                    try? await Task.sleep(for: .seconds(0.3))
                                                    ups.clearRequest()
                                                }
                                            }
                                        }
                                    } label: {
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
                                    .disabled(!appear || buttonPushed)
                                    
                                    Spacer()
                                }
                                
                            }
                            
                        }
                        
                    } else {
                        
                        LoadViewElement()
                            .frame(width: 50, height: 50)
                        
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
