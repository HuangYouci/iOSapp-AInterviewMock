//
//  CoinView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI

struct CoinView: View {
    
    @ObservedObject private var iap = IAPManager.shared
    @ObservedObject private var adViewModel = AdManager.shared
    @ObservedObject private var cm = CoinManager.shared
    
    @State private var safariItem: SafariItem?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15){
                
                Text("代幣")
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal)
            
                VStack(alignment: .leading){
                    HStack{
                        Spacer()
                        VStack{
                            Image(systemName: "hockey.puck.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(Color("AppGold"))
                            Text("\(cm.coins)")
                                .font(.title)
                                .bold()
                                .foregroundStyle(Color(.accent))
                        }
                        Spacer()
                    }
                }
                .padding()
                .padding(.horizontal)
                
                VStack(alignment: .leading){
                    HStack{
                        Image(systemName: "info.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(Color(.accent))
                        Text("說明")
                            .bold()
                        Spacer()
                    }
                    Text("代幣是啟用模擬面試的來源，需要一些代幣才能進行模擬面試。一次模擬面試需要約 10 到 20 枚代幣。代幣可透過單次購買或訂閱無限取用方案來獲得。")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.accentColor,
                            lineWidth: 2
                        )
                )
                .padding(.horizontal)
                
                Text("獲得代幣")
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal)
                
                if (iap.hasSubscription){
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "checkmark.diamond.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.accent))
                            Text("訂閱用戶")
                                .bold()
                            Spacer()
                        }
                        Text("目前訂閱啟用中。每一小時可獲取 50 代幣（無法累計）。如果目前代幣大於 50，則不會進行更動。")
                        if (cm.isPremiumCoinAvailable){
                            Button {
                                cm.premiumGetCoin()
                            } label: {
                                Text("取得")
                                    .padding(10)
                                    .foregroundStyle(Color(.white))
                                    .background(Color.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        } else {
                            Text("冷卻中")
                                .padding(10)
                                .foregroundStyle(Color(.white))
                                .background(Color(.systemGray2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor,
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                }
                
                if (adViewModel.isAdLoaded){
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = scene.windows.first?.rootViewController {
                            adViewModel.showAd(from: rootViewController) {
                                cm.addCoin(5)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading){
                            HStack{
                                Text("觀看廣告")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text("輕鬆獲得代幣")
                            Text("（在一段期間內有次數限制）")
                            Text("獲得一些代幣")
                                .padding(.top, 20)
                                .font(.title2)
                        }
                        .foregroundStyle(Color(.white))
                        .padding()
                        .background(
                            Image("appasset04")
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
                                .offset(x: 50, y: 60)
                        )
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 161 / 255, green: 66 / 255, blue: 245 / 255),
                                    Color(red: 255 / 255, green: 95 / 255, blue: 207 / 255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }
                } else {
                    VStack(alignment: .leading){
                        HStack{
                            Text("觀看廣告")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        Text("輕鬆獲得代幣")
                        Text("（在一段期間內有次數限制）")
                        Text("不可用")
                            .padding(.top, 20)
                            .font(.title2)
                    }
                    .foregroundStyle(Color(.white))
                    .padding()
                    .background(
                        Image("appasset04")
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
                            .offset(x: 50, y: 60)
                    )
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 100 / 255, green: 100 / 255, blue: 100 / 255),
                                Color(red: 135 / 255, green: 130 / 255, blue: 130 / 255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }
                
                Text("購買")
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal)
                
                if (iap.hasSubscription){
                    VStack(alignment: .leading){
                        HStack{
                            Text("月訂閱方案")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        Text("無限次模擬面試*")
                        Text("訂閱中")
                            .padding(.top, 30)
                            .font(.title2)
                    }
                    .foregroundStyle(Color(.white))
                    .padding()
                    .background(
                        Image("appasset02")
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
                            .offset(x: 50, y: 60)
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
                    .padding(.horizontal)
                } else {
                    Button {
                        if let product = iap.products.first(where: { $0.id == "com.huangyouci.AInterviewMock.subscription.monthly" }) {
                            Task {
                                let _ = await iap.purchase(product)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading){
                            HStack{
                                Text("月訂閱方案")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text("無限次模擬面試*")
                            Text(IAPManager.shared.priceString(for: "com.huangyouci.AInterviewMock.subscription.monthly"))
                                .padding(.top, 30)
                                .font(.title2)
                        }
                        .foregroundStyle(Color(.white))
                        .padding()
                        .background(
                            Image("appasset02")
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
                                .offset(x: 50, y: 60)
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
                        .padding(.horizontal)
                    }
                }
                
                HStack(spacing: 15) {
                    Button {
                        if let product = iap.products.first(where: { $0.id == "com.huangyouci.AInterviewMock.iap.coinseta" }) {
                            Task {
                                let _ = await iap.purchase(product)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading){
                            HStack{
                                Text("100 代幣")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text("單次獲得代幣")
                            Text(IAPManager.shared.priceString(for: "com.huangyouci.AInterviewMock.iap.coinseta"))
                                .padding(.top, 30)
                                .font(.title2)
                        }
                        .foregroundStyle(Color(.white))
                        .padding()
                        .background(
                            Image("appasset03")
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
                                .offset(x: 20, y: 60)
                        )
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 22 / 255, green: 101 / 255, blue: 17 / 255),
                                    Color(red: 25 / 255, green: 95 / 255, blue: 207 / 255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button {
                        if let product = iap.products.first(where: { $0.id == "com.huangyouci.AInterviewMock.iap.coinsetb" }) {
                            Task {
                                let _ = await iap.purchase(product)
                            }
                        }
                    } label: {
                        VStack(alignment: .leading){
                            HStack{
                                Text("300 代幣")
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text("單次獲得代幣")
                            Text(IAPManager.shared.priceString(for: "com.huangyouci.AInterviewMock.iap.coinsetb"))
                                .padding(.top, 30)
                                .font(.title2)
                        }
                        .foregroundStyle(Color(.white))
                        .padding()
                        .background(
                            Image("appasset03")
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
                                .offset(x: 20, y: 60)
                        )
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 22 / 255, green: 101 / 255, blue: 17 / 255),
                                    Color(red: 25 / 255, green: 95 / 255, blue: 207 / 255)
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
                    Task {
                        await iap.restorePurchases()
                    }
                } label: {
                    VStack(alignment: .leading){
                        HStack{
                            Text("還原購買")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        Text("恢復訂閱狀態")
                    }
                    .foregroundStyle(Color(.white))
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 252 / 255, green: 151 / 255, blue: 7 / 255),
                                Color(red: 255 / 255, green: 155 / 255, blue: 207 / 255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }
                
                Text("注意事項")
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal)
                
                Text("""
                [1] 單次購買代幣後，若刪除程式，可能將導致代幣遺失，無法還原。
                [2] 購買訂閱方案，可在啟用期間每一小時領取一次 50 代幣（約可進行 3 次模擬面試）。
                [3] 購買前請詳閱使用條款與隱私政策。
                [4] 進行模擬面試次數係由一次約消耗 10 ~ 20 代幣計算，實際使用會有所差異。
                """)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal)
                    .font(.caption)
                
                Button {
                    safariItem = SafariItem(url: URL(string: "https://huangyouci.github.io/app/eula/")!)
                } label: {
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.accent))
                            Text("使用條款")
                                .bold()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor,
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                }
                
                Button {
                    safariItem = SafariItem(url: URL(string: "https://huangyouci.github.io/app/privacypolicy/")!)
                } label: {
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "book.closed.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.accent))
                            Text("隱私政策")
                                .bold()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor,
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                }
                
                Link(destination: URL(string: "mailto:ycdev@icloud.com")!){
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "envelope.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.accent))
                            Text("聯絡開發者")
                                .bold()
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor,
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                }
                
                Link(destination: URL(string: "https://reportaproblem.apple.com")!){
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "dollarsign.arrow.circlepath")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.accent))
                            Text("要求退款")
                                .bold()
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.accentColor,
                                lineWidth: 2
                            )
                    )
                    .padding(.horizontal)
                }
            }
        }
        .sheet(item: $safariItem) { item in
                    SafariView(url: item.url)
                }
    }
}

#Preview {
    CoinView()
}
