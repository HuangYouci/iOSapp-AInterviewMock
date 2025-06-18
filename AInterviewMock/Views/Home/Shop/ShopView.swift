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
    @StateObject var ad = AdManager.shared
    @StateObject var iap = IAPManager.shared
    
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
                            Image(systemName: "hockey.puck.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(5)
                                .foregroundStyle(Color("AppGold"))
                            Text("\(up.coins)")
                                .font(.title)
                                .bold()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("BackgroundR1"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
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
                                            //                                            ups.callCloudFunctionToUpdateUserCoins(uid: <#T##String#>, amount: <#T##Int#>, completion: <#T##(UserProfileServiceError?) -> Void#>)
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
                                    Text("觀看")
                                        .padding(.top, 10)
                                        .bold()
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color(.white))
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
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.bottom, 10)
                            }
                            
                        } else {
                            VStack(alignment: .leading){
                                Text("觀看廣告")
                                    .font(.title)
                                    .bold()
                                Text("輕鬆獲得代幣")
                                Text("在一段期間內可觀看一定次數")
                                Text("尚未準備")
                                    .padding(.top, 10)
                                    .bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("BackgroundR1"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.bottom, 10)
                        }
                        
                        Text("購買代幣")
                            .foregroundStyle(Color(.systemGray))
                            .font(.caption)
                        
                        Button {
                            if let product = iap.products.first(where: { $0.id == "com.huangyouci.AInterviewMock.iap.coinseta" }) {
                                Task {
                                    let _ = await iap.purchase(product)
                                }
                            }
                        } label: {
                            VStack(alignment: .leading){
                                Text("100 代幣")
                                    .font(.title)
                                    .bold()
                                Text("一次性獲得代幣")
                                Text(iap.priceString(for: "com.huangyouci.AInterviewMock.iap.coinseta"))
                                    .padding(.top, 10)
                                    .bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color(.white))
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
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.bottom, 10)
                        }
                        
                        Button {
                            if let product = iap.products.first(where: { $0.id == "com.huangyouci.AInterviewMock.iap.coinsetb" }) {
                                Task {
                                    let _ = await iap.purchase(product)
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text("300 代幣")
                                    .font(.title)
                                    .bold()
                                Text("一次性獲得代幣")
                                Text(IAPManager.shared.priceString(for: "com.huangyouci.AInterviewMock.iap.coinsetb"))
                                    .padding(.top, 10)
                                    .bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color(.white))
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
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.bottom, 10)
                        }
                        
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
