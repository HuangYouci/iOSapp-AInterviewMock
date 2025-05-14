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
        VStack(spacing: 0) {
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
                    ViewManager.shared.perviousPage()
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
            ScrollView {
                Color.clear
                    .frame(height: 5)
                VStack(alignment: .leading, spacing: 15){
                    
                    Text(NSLocalizedString("CoinView_sectionTitleCoins", comment: "Section title for 'Coins' display area"))
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
                                Text("\(cm.coins)") // Dynamic content
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
                            Text(NSLocalizedString("CoinView_explanationTitle", comment: "Title for the coin explanation section"))
                                .bold()
                            Spacer()
                        }
                        Text(NSLocalizedString("CoinView_explanationBody", comment: "Explanation text about what coins are and how to get them"))
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
                    
                    Text(NSLocalizedString("CoinView_sectionTitleGetCoins", comment: "Section title for 'Get Coins' options"))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    
                    if (!iap.hasSubscription){
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "checkmark.diamond.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(Color(.accent))
                                Text(NSLocalizedString("CoinView_subscriberUserTitle", comment: "Title for subscribed user section"))
                                    .bold()
                                Spacer()
                            }
                            Text(NSLocalizedString("CoinView_subscriberUserDescription", comment: "Description for subscribed user benefits regarding coins"))
                            if (cm.isPremiumCoinAvailable){
                                Button {
                                    cm.premiumGetCoin()
                                } label: {
                                    Text(NSLocalizedString("CoinView_getCoinButton", comment: "Button text to claim free coins for subscribers"))
                                        .padding(10)
                                        .foregroundStyle(Color(.white))
                                        .background(Color.accentColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            } else {
                                Text(NSLocalizedString("CoinView_cooldownStatus", comment: "Status text when coin claim is on cooldown"))
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
                               let root = scene.windows.first?.rootViewController {
                                
                                // 往上遞迴找出最上層的 ViewController
                                var topVC = root
                                while let presented = topVC.presentedViewController {
                                    topVC = presented
                                }
                                
                                // 如果沒有正在 present 的畫面，再顯示廣告
                                if topVC.presentedViewController == nil {
                                    adViewModel.showAd(from: topVC) {
                                        AnalyticsLogger.shared.watchAd()
                                        cm.addCoin(5)
                                    }
                                } else {
                                    print("⚠️ 目前有畫面正在展示，無法顯示廣告")
                                }
                            }
                        } label: {
                            VStack(alignment: .leading){
                                HStack{
                                    Text(NSLocalizedString("CoinView_watchAdTitle", comment: "Title for the watch ad to get coins card"))
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                Text(NSLocalizedString("CoinView_watchAdSubtitleEasy", comment: "Subtitle for watch ad: 'Easily get coins'"))
                                Text(NSLocalizedString("CoinView_watchAdSubtitleLimit", comment: "Subtitle for watch ad: '(Limited times within a period)'"))
                                Text(NSLocalizedString("CoinView_watchAdBenefit", comment: "Benefit text for watch ad: 'Get some coins'"))
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
                                Text(NSLocalizedString("CoinView_watchAdTitle", comment: "Title for the watch ad to get coins card (also used when ad is unavailable)"))
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text(NSLocalizedString("CoinView_watchAdSubtitleEasy", comment: "Subtitle for watch ad: 'Easily get coins' (also used when ad is unavailable)"))
                            Text(NSLocalizedString("CoinView_watchAdSubtitleLimit", comment: "Subtitle for watch ad: '(Limited times within a period)' (also used when ad is unavailable)"))
                            Text(NSLocalizedString("CoinView_watchAdUnavailable", comment: "Status text when watch ad is unavailable"))
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
                    
                    
                    Text(NSLocalizedString("CoinView_sectionTitlePurchase", comment: "Section title for 'Purchase' options"))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    if (iap.hasSubscription){
                        VStack(alignment: .leading){
                            HStack{
                                Text(NSLocalizedString("CoinView_monthlySubscriptionTitle", comment: "Title for monthly subscription card"))
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text(NSLocalizedString("CoinView_monthlySubscriptionBenefit", comment: "Benefit description for monthly subscription"))
                            Text(NSLocalizedString("CoinView_monthlySubscriptionStatusSubscribed", comment: "Status text when user is subscribed"))
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
                                    Text(NSLocalizedString("CoinView_monthlySubscriptionTitle", comment: "Title for monthly subscription card (also used when not subscribed)"))
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                Text(NSLocalizedString("CoinView_monthlySubscriptionBenefit", comment: "Benefit description for monthly subscription (also used when not subscribed)"))
                                Text(IAPManager.shared.priceString(for: "com.huangyouci.AInterviewMock.subscription.monthly")) // Dynamic price
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
                                    Text(NSLocalizedString("CoinView_coinPack100Title", comment: "Title for the 100 coins pack"))
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                Text(NSLocalizedString("CoinView_coinPackSubtitle", comment: "Subtitle for coin packs: 'One-time coin acquisition'"))
                                Text(IAPManager.shared.priceString(for: "com.huangyouci.AInterviewMock.iap.coinseta")) // Dynamic price
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
                                    Text(NSLocalizedString("CoinView_coinPack300Title", comment: "Title for the 300 coins pack"))
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                Text(NSLocalizedString("CoinView_coinPackSubtitle", comment: "Subtitle for coin packs: 'One-time coin acquisition' (reused)"))
                                Text(IAPManager.shared.priceString(for: "com.huangyouci.AInterviewMock.iap.coinsetb")) // Dynamic price
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
                                Text(NSLocalizedString("CoinView_restorePurchasesTitle", comment: "Title for restore purchases button/card"))
                                    .font(.title)
                                    .bold()
                                Spacer()
                            }
                            Text(NSLocalizedString("CoinView_restorePurchasesSubtitle", comment: "Subtitle for restore purchases: 'Restore subscription status'"))
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
                    
                    Text(NSLocalizedString("CoinView_sectionTitleNotes", comment: "Section title for 'Notes' or 'Important Information'"))
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal)
                    
                    Text(NSLocalizedString("CoinView_notesBody", comment: "Body text for important notes regarding purchases and app usage"))
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
                                Text(NSLocalizedString("CoinView_termsOfUseButton", comment: "Button text for 'Terms of Use'"))
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
                                Text(NSLocalizedString("CoinView_privacyPolicyButton", comment: "Button text for 'Privacy Policy'"))
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
                                Text(NSLocalizedString("CoinView_contactDeveloperButton", comment: "Button text for 'Contact Developer'"))
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
                                Text(NSLocalizedString("CoinView_requestRefundButton", comment: "Button text for 'Request a Refund'"))
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
        }
        .sheet(item: $safariItem) { item in
                    SafariView(url: item.url)
                }
        .background(Color(.systemBackground))
    }
}

#Preview {
    CoinView()
}
