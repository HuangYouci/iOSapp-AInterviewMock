//
//  AuthView.swift // 或者 AuthEntryView.swift，根據你的文件名
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/8.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import CryptoKit

struct AuthView: View {
    
    @EnvironmentObject var authManager: AuthManager

    @State private var appleSignInNonce: String?

    var body: some View {
        VStack(spacing: 0){
            VStack(spacing: 0){
                VStack{
                    Spacer()
                    Text("inif")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color(.white))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack{
                    VStack(alignment: .leading){
                        HStack{
                            Text("登入")
                                .font(.title)
                                .bold()
                            if (authManager.isLoading){
                                ProgressView()
                            }
                            Spacer()
                        }
                        
                        Text("使用您的 Apple 帳號或 Google 帳號登入 inif")
                        
                        VStack(alignment: .leading, spacing: 10){
                            Button {
                                authManager.signInWithApple()
                            } label: {
                                HStack(alignment: .center, spacing: 10){
                                    Spacer()
                                    Image(systemName: "apple.logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    Text("使用 Apple 登入")
                                        .font(.title3)
                                    Spacer()
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentColorP1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            // Google 登入按鈕
                            Button {
                                authManager.signInWithGoogle()
                            } label: {
                                HStack(alignment: .center, spacing: 10){
                                    Spacer()
                                    Image(systemName: "g.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    Text("使用 Google 登入")
                                        .font(.title3)
                                    Spacer()
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color(.white))
                            .background(Color("AccentColorP1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                        }
                        .padding(.vertical)
                        
                        if let em = authManager.errorMessage {
                            VStack(alignment: .leading){
                                HStack{
                                    Text("錯誤")
                                        .bold()
                                    Spacer()
                                }
                                Text(em.errorDescription ?? "Unknown Bug")
                            }
                            .padding(10)
                            .background(Color(.red).opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(.red), lineWidth: 1)
                            )
                        }
                        
                        FlowLayout(horizontalSpacing: 0, verticalSpacing: 10){
                            Text("登入表示您同意 inif 的")
                            Text("隱私政策").foregroundStyle(Color.accentColor)
                            Text("與")
                            Text("使用條款").foregroundStyle(Color.accentColor)
                        }
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray))
                        .padding(.top, 60)
                    }
                    .padding(25)
                }
                .frame(maxWidth: .infinity)
                .background(Color("Background"))
                .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
                .disabled(authManager.isLoading)
            }
            .background(Color.accentColor)
            Color("Background")
                .frame(height: 1)
                .ignoresSafeArea(edges: [.bottom])
        }
        .background(Color("Background"))
    }
    
    /// 計算輸入字符串的 SHA256 哈希值。
    /// Apple 登入時，需要將原始 Nonce 的 SHA256 哈希值提供給 `ASAuthorizationAppleIDRequest`。
    /// - Parameter input: 需要計算哈希的原始字符串。
    /// - Returns: SHA256 哈希後的十六進制字符串。
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8) // 將輸入字符串轉換為 UTF-8 編碼的 Data
        let hashedData = SHA256.hash(data: inputData) // 使用 CryptoKit 的 SHA256 進行哈希計算
        // 將哈希後的 Data (字節數組) 轉換為十六進制字符串表示
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}


#Preview("This") {
    VStack(spacing: 0){
        VStack(spacing: 0){
            VStack{
                Spacer()
                Text("inif")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(.white))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack{
                VStack(alignment: .leading){
                    HStack{
                        Text("登入")
                            .font(.title)
                            .bold()
                            ProgressView()
                        Spacer()
                    }
                    
                    Text("使用您的 Apple 帳號或 Google 帳號登入 inif")
                    
                    VStack(alignment: .leading, spacing: 10){
                        Button {
                            
                        } label: {
                            HStack(alignment: .center, spacing: 10){
                                Spacer()
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("使用 Apple 登入")
                                    .font(.title3)
                                Spacer()
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color(.white))
                        .background(Color("AccentColorP1"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Google 登入按鈕
                        Button {
                            
                        } label: {
                            HStack(alignment: .center, spacing: 10){
                                Spacer()
                                Image(systemName: "g.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("使用 Google 登入")
                                    .font(.title3)
                                Spacer()
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color(.white))
                        .background(Color("AccentColorP1"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.vertical)
                    
                    VStack(alignment: .leading){
                        Text("錯誤")
                            .bold()
                        HStack{
                            Text("Unknown Bug唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷唷六一八")
                            Spacer()
                        }
                    }
                    .padding(10)
                    .background(Color(.red).opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(.red), lineWidth: 1)
                    )
                    
                    FlowLayout(horizontalSpacing: 0, verticalSpacing: 10){
                        Text("登入表示您同意 inif 的")
                        Text("隱私政策").foregroundStyle(Color.accentColor)
                        Text("與")
                        Text("使用條款").foregroundStyle(Color.accentColor)
                    }
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.top, 60)
                }
                .padding(25)
            }
            .frame(maxWidth: .infinity)
            .background(Color("Background"))
            .clipShape(.rect(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20))
        }
        .background(Color.accentColor)
        Color("Background")
            .frame(height: 1)
            .ignoresSafeArea(edges: [.bottom])
    }
    .background(Color("Background"))
}
