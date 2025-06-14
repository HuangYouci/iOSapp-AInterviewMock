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
                            SignInWithAppleButton(
                                .signIn, // 按鈕樣式
                                onRequest: { request in
                                    // 1. 生成 Nonce
                                    let nonce = authManager.generateNonce()
                                    appleSignInNonce = nonce
                                    // 2. 請求用戶的 email
                                    request.requestedScopes = [.fullName, .email]
                                    // 3. 將 Nonce 的 SHA256 哈希值設置到請求中
                                    request.nonce = sha256(nonce)
                                    print("AuthView | Apple Sign In onRequest - Nonce generated and set.")
                                },
                                onCompletion: { result in
                                    print("AuthView | Apple Sign In onCompletion - Result received.")
                                    switch result {
                                    case .success(let authorization):
                                        print("AuthView | Apple Sign In onCompletion - Succeeded.")
                                        // 成功獲取 Apple 授權憑證
                                        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                                            print("AuthView | Apple Sign In onCompletion - Error: Failed to cast credential to ASAuthorizationAppleIDCredential.")
                                            // 設置 AuthManager 的錯誤狀態
                                            authManager.errorMessage = .appleSignInMissingCredentialOrToken
                                            return
                                        }
                                        
                                        // 獲取之前在 onRequest 中保存的原始 Nonce
                                        guard let rawNonce = appleSignInNonce else {
                                            print("AuthView | Apple Sign In onCompletion - Error: Missing rawNonce.")
                                            // 這是一個應用程式內部邏輯錯誤
                                            authManager.errorMessage = .unexpectedInternalError(underlyingError: nil)
                                            return
                                        }
                                        
                                        // 將憑證和原始 Nonce 傳遞給 AuthManager 以便使用 Firebase 進行登入
                                        print("AuthView | Apple Sign In onCompletion - Calling authManager.handleAppleSignIn.")
                                        authManager.handleAppleSignIn(credential: appleIDCredential, nonce: rawNonce)
                                        
                                    case .failure(let error):
                                        print("AuthView | Apple Sign In onCompletion - Failed with error: \(error.localizedDescription)")
                                        // 處理 Apple 登入本身的錯誤 (ASAuthorizationError)
                                        if let authError = error as? ASAuthorizationError {
                                            if authError.code == .canceled {
                                                print("AuthView | Apple Sign In onCompletion - User cancelled.")
                                                authManager.errorMessage = .userCancelledOperation
                                                // 通常用戶取消不需要彈出錯誤提示，或者只是一個溫和的提示
                                            } else {
                                                authManager.errorMessage = .appleSignInFailed(underlyingError: error)
                                            }
                                        } else {
                                            authManager.errorMessage = .appleSignInFailed(underlyingError: error)
                                        }
                                    }
                                }
                            )
                            .frame(height: 50)
                            
                            // Google 登入按鈕
                            GoogleSignInButton() {
                                print("AuthView | Google Sign In button tapped.")
                                appleSignInNonce = nil
                                authManager.signInWithGoogle()
                            }
                            .frame(height: 50)
                        }
                        .padding(.vertical)
                        
                        if let em = authManager.errorMessage {
                            VStack(alignment: .leading){
                                Text("錯誤")
                                    .bold()
                                HStack{
                                    Text(em.errorDescription ?? "Unknown Bug")
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
            Color.clear.frame(height: 1)
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
                        Text("Apple")
                        .frame(height: 50)
                        
                        // Google 登入按鈕
                        Text("Google")
                        .frame(height: 50)
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
        Color.clear.frame(height: 1)
    }
    .background(Color("Background"))
}
