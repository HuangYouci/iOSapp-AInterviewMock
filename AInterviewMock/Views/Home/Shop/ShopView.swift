//
//  ShopView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/18.
//

import SwiftUI

struct ShopView: View {
    
    @EnvironmentObject var vm: ViewManager
    @EnvironmentObject var ups: UserProfileService
    @EnvironmentObject var iap: IAPManager
    @StateObject var co = CoinManager.shared // Depreciated
    @StateObject var ad = AdManager.shared
    
    var body: some View {
        VStack{
            if let up = ups.currentUserProfile {
                HStack{
                    Button{
                        vm.perviousPage()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .foregroundStyle(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Text("inif")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.accentColor)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .padding(.bottom, 5)
                
                ScrollView{
                    VStack(alignment: .leading){
                        
                        Text("代幣")
                            .foregroundStyle(Color(.systemGray))
                            .font(.caption)
                        
                        VStack{
                            HStack{
                                Spacer()
                                Image(systemName: "hockey.puck.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding(5)
                                    .foregroundStyle(Color("AppGold"))
                                Spacer()
                            }
                            Text("\(up.coins)")
                                .font(.title)
                                .bold()
                        }
                        .inifBlock(bgColor: Color("BackgroundR1"))
                        .frame(alignment: .center)
                        .padding(.bottom, 10)
                        
                        Text("獲得代幣")
                            .foregroundStyle(Color(.systemGray))
                            .font(.caption)
                        
                        if(ad.isAdLoaded){
                            
                            Button {
                                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let root = scene.windows.first?.rootViewController {
                                    
                                    // 往上遞迴找出最上層的 ViewController
                                    var topVC = root
                                    while let presented = topVC.presentedViewController {
                                        topVC = presented
                                    }
                                    
                                    // 如果沒有正在 present 的畫面，再顯示廣告
                                    if topVC.presentedViewController == nil {
                                        ad.showAd(from: topVC) {
                                            ups.pendingModifyCoinType = .addWatchAd
                                            ups.setPendingCoins(amount: 5)
                                        }
                                    } else {
                                        print("ShopView | 目前有畫面正在展示，無法顯示廣告")
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading){
                                    Text("觀看廣告")
                                        .font(.title)
                                        .bold()
                                    Text("輕鬆獲得代幣")
                                    Text("在一段期間內可觀看一定次數")
                                    Text("點擊觀看")
                                        .padding(.top, 10)
                                        .bold()
                                }
                                .inifBlock(fgColor: Color(.white), bgColor: LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 161 / 255, green: 66 / 255, blue: 245 / 255),
                                        Color(red: 255 / 255, green: 95 / 255, blue: 207 / 255)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .padding(.bottom, 10)
                            }
                            
                        } else {
                            VStack(alignment: .leading){
                                Text("觀看廣告")
                                    .font(.title)
                                    .bold()
                                Text("輕鬆獲得代幣")
                                Text("在一段期間內可觀看一定次數")
                                Text("加載中")
                                    .padding(.top, 10)
                                    .bold()
                            }
                            .inifBlock(bgColor: Color("BackgroundR1"))
                            .padding(.bottom, 10)
                        }
                        
                        // Depreciatied: Remove after sss version
                        if(co.coins > 0){
                            Button {
                                ups.pendingModifyCoinType = .general
                                ups.setPendingCoins(amount: co.coins)
                                co.resetKeychainDataForTesting()
                                // clear
                            } label: {
                                VStack(alignment: .leading){
                                    Text("遷移代幣")
                                        .font(.title)
                                        .bold()
                                    Text("將先前存於本機的代幣轉移到本帳號中")
                                    Text("請確認現在登入的是要轉移到的帳號")
                                    Text("此操作無法復原")
                                    Text("點擊遷移 \(co.coins) 代幣")
                                        .padding(.top, 10)
                                        .bold()
                                }
                                .inifBlock(bgColor: Color("BackgroundR1"))
                                .padding(.bottom, 10)
                            }
                        }
                        
                        Text("購買代幣")
                            .foregroundStyle(Color(.systemGray))
                            .font(.caption)
                        
                        Button {
                            if let product = iap.products.first(where: { $0.id == ConstantStoreItems.coinSetA }) {
                                Task {
                                    do {
                                        try await iap.purchase(product)
                                    } catch {
                                        _ = error
                                    }
                                }
                            }
                        } label: {
                            VStack(alignment: .leading){
                                Text("100 代幣")
                                    .font(.title)
                                    .bold()
                                Text("一次性獲得代幣")
                                Text(iap.priceString(for: ConstantStoreItems.coinSetA))
                                    .padding(.top, 10)
                                    .bold()
                            }
                            .inifBlock(fgColor: Color(.white), bgColor: LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 22 / 255, green: 101 / 255, blue: 17 / 255),
                                    Color(red: 25 / 255, green: 95 / 255, blue: 207 / 255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .padding(.bottom, 10)
                        }
                        
                        Button {
                            if let product = iap.products.first(where: { $0.id == ConstantStoreItems.coinSetB }) {
                                Task {
                                    do {
                                        try await iap.purchase(product)
                                    } catch {
                                        _ = error
                                    }
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text("300 代幣")
                                    .font(.title)
                                    .bold()
                                Text("一次性獲得代幣")
                                Text(iap.priceString(for: ConstantStoreItems.coinSetB))
                                    .padding(.top, 10)
                                    .bold()
                            }
                            .inifBlock(fgColor: Color(.white), bgColor: LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 22 / 255, green: 101 / 255, blue: 17 / 255),
                                    Color(red: 25 / 255, green: 95 / 255, blue: 207 / 255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .padding(.bottom, 10)
                        }
                        
                        Button {
                            Task {
                                await iap.restorePurchases()
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text("復原購買")
                                    .font(.title)
                                    .bold()
                                Text("嘗試復原帳號的訂閱型或非消耗型購買紀錄")
                                Text("點擊嘗試")
                                    .padding(.top, 10)
                                    .bold()
                            }
                            .inifBlock(fgColor: Color(.white), bgColor: LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 252 / 255, green: 151 / 255, blue: 7 / 255),
                                    Color(red: 255 / 255, green: 155 / 255, blue: 207 / 255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .padding(.bottom, 10)
                        }
                        
                        Text("條款與說明")
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
                            Divider()
                                .padding(.vertical, 6.5)
                            Link(destination: URL(string: "mailto:ycdev@icloud.com")!){
                                HStack{
                                    Text("開發者信箱")
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
                            Link(destination: URL(string: "https://reportaproblem.apple.com")!){
                                HStack{
                                    Text("要求退款")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
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
                    .padding(25)
                    .frame(maxWidth: .infinity)
                    .background(Color("Background"))
                    .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .navigationBarHidden(true)
            } else {
                LoadView()
            }
        }
        .background(Color("Background"))
    }
    
}
