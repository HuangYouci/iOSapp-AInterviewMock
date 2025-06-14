import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit // 為了 SHA256，雖然 Firebase SDK 會處理，但 good practice to know it's there

// MARK: - AuthManager
/// `AuthManager` 類別負責處理應用程式中所有與 Firebase 身份驗證相關的操作。
/// 它使用 `ObservableObject` 協定，使其屬性可以在 SwiftUI 視圖中被觀察，從而實現 UI 的自動更新。
/// 主要功能包括：監聽 Firebase Auth 狀態變化、處理 Google 登入、Apple 登入以及登出操作。
/// 同時，它會與 `UserProfileService` 協作，在用戶登入後觸發用戶 Profile 數據的加載或創建。
class AuthManager : ObservableObject {

    // MARK: - @Published 公開屬性 (Published Properties)
    // 這些屬性值的任何改變都會通知所有觀察此 AuthManager 實例的 SwiftUI 視圖進行更新。

    /// 當前通過 Firebase 身份驗證的用戶對象。
    /// 如果沒有用戶登入，或者用戶已登出，此值為 `nil`。
    /// 此屬性由 `authStateDidChangeListener` 自動更新。
    @Published var user: User? // User 是 FirebaseAuth.User 的簡稱

    /// 一個布爾值，指示當前是否有身份驗證相關的操作（如登入、登出、加載用戶 Profile）正在進行中。
    /// `true` 表示正在加載，`false` 表示操作完成或空閒。
    /// SwiftUI 視圖可以使用此狀態來顯示進度指示器或禁用交互。
    @Published var isLoading: Bool = false

    /// 保存最近一次身份驗證操作中發生的錯誤。
    /// 如果操作成功或沒有錯誤，此值為 `nil`。
    /// SwiftUI 視圖可以觀察此屬性以向用戶顯示錯誤信息。
    @Published var errorMessage: AuthManagerErrorType?

    // MARK: - 私有屬性 (Private Properties)

    /// `UserProfileService` 的實例，通過依賴注入（Dependency Injection）傳入。
    /// 這種設計將身份驗證邏輯與用戶數據管理邏輯解耦，提高了程式碼的可測試性和可維護性。
    private let userProfileService: UserProfileService

    /// Firebase Auth 狀態監聽器的句柄 (handle)。
    /// 用於在 `AuthManager` 實例被銷毀 (`deinit`) 時，能夠正確地從 Firebase Auth 系統中移除監聽器，以防止記憶體洩漏。
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    // MARK: - 錯誤類型枚舉 (Error Type Enumeration)
    /// `AuthManagerErrorType` 定義了在身份驗證過程中可能發生的各種錯誤類型。
    /// 它符合 `Error` 和 `LocalizedError` 協定，以提供用戶友好的錯誤訊息。
    /// 同時符合 `Identifiable`，使其能方便地在 SwiftUI 的 `.alert(item: ...)` 修飾符中使用。
    enum AuthManagerErrorType: Error, LocalizedError, Identifiable {
        
        // MARK: - Cases
        /// 當用戶取消了某個身份驗證操作時（例如，關閉了 Google 登入視窗）。
        case userCancelledOperation
        /// Google 登入過程中發生的錯誤。關聯值是底層的 `Error` 對象。
        case googleSignInFailed(underlyingError: Error)
        /// 從 Google 登入成功後，無法獲取到必要的 ID Token。
        case googleSignInMissingToken
        /// Apple 登入過程中發生的錯誤。關聯值是底層的 `Error` 對象。
        case appleSignInFailed(underlyingError: Error)
        /// 從 Apple 登入成功後，無法獲取到必要的身份憑證 (`ASAuthorizationAppleIDCredential`) 或 ID Token。
        case appleSignInMissingCredentialOrToken
        /// 使用從第三方提供商（如 Google, Apple）獲取的憑證登入 Firebase 時失敗。關聯值是底層的 Firebase `Error` 對象。
        case firebaseSignInFailed(underlyingError: Error)
        /// Firebase 登出操作失敗。關聯值是底層的 `Error` 對象。
        case firebaseSignOutFailed(underlyingError: Error)
        /// 與用戶 Profile 數據相關的操作失敗。關聯值是來自 `UserProfileService` 的 `UserProfileServiceError`。
        case userProfileOperationFailed(profileError: UserProfileServiceError) // UserProfileServiceError 需要被定義
        /// 無法獲取到應用程式的頂層視圖控制器 (Top View Controller)。
        case topViewControllerNotFound
        /// 為 Apple 登入生成隨機 Nonce 字串時失敗。
        case nonceGenerationFailed(osStatus: OSStatus)
        /// 其他未被明確分類的內部錯誤或未知錯誤。
        case unexpectedInternalError(underlyingError: Error?)

        // MARK: - Identifiable Conformance
        /// 為了符合 `Identifiable`，提供一個唯一的 ID。這裡我們使用錯誤描述作為 ID。
        var id: String {
            self.localizedDescription
        }
        
        // MARK: - LocalizedError Conformance
        /// 提供一個用戶友好的錯誤描述。
        var errorDescription: String? {
            switch self {
            case .userCancelledOperation:
                return "使用者已取消操作。"
            case .googleSignInFailed(let error):
                return "Google 登入失敗: \(error.localizedDescription)"
            case .googleSignInMissingToken:
                return "無法從 Google 獲取登入憑證，請重試。"
            case .appleSignInFailed(let error):
                return "Apple 登入失敗: \(error.localizedDescription)"
            case .appleSignInMissingCredentialOrToken:
                return "無法獲取 Apple 登入憑證，請重試。"
            case .firebaseSignInFailed(let error):
                return "無法登入到我們的服務: \(error.localizedDescription)"
            case .firebaseSignOutFailed(let error):
                return "登出時發生錯誤: \(error.localizedDescription)"
            case .userProfileOperationFailed(let profileError):
                return "處理用戶資料時發生錯誤: \(profileError.localizedDescription)"
            case .topViewControllerNotFound:
                return "應用程式內部錯誤，無法啟動登入流程。"
            case .nonceGenerationFailed(let osStatus):
                return "安全驗證初始化失敗 (錯誤碼: \(osStatus))，請重試。"
            case .unexpectedInternalError(let error):
                if let underlyingError = error {
                    return "發生未預期的內部錯誤: \(underlyingError.localizedDescription)"
                } else {
                    return "發生未預期的內部錯誤，請稍後再試。"
                }
            }
        }
    }

    // MARK: - 初始化與反初始化 (Initialization and Deinitialization)

    /// `AuthManager` 的初始化方法。
    /// - Parameter userProfileService: 一個 `UserProfileService` 的實例，用於後續的用戶 Profile 操作。
    /// 在初始化過程中，會立即註冊一個 Firebase Auth 狀態監聽器。
    init(userProfileService: UserProfileService) {
        self.userProfileService = userProfileService
        print("AuthManager | INIT | AuthManager 已初始化，並注入 UserProfileService。")

        // 添加 Firebase 身份驗證狀態變更的監聽器。
        // 這個監聽器是一個閉包，當 Firebase 的用戶認證狀態發生任何改變時（例如用戶登入、登出，或身份令牌刷新），
        // Firebase SDK 都會自動調用這個閉包。
        // `[weak self]` 用於避免 AuthManager 與閉包之間的循環引用。
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, firebaseUser) in
            guard let self = self else {
                print("AuthManager | AuthStateListener | self (AuthManager) 已被釋放，提前返回。")
                return
            }
            print("AuthManager | AuthStateListener | 監聽到 Firebase Auth 狀態變化。Firebase User UID: \(firebaseUser?.uid ?? "未登入")")
            
            // 確保 UI 更新在主線程執行。雖然 Firebase 通常在此處調用主線程，但明確指定是更安全的做法。
            DispatchQueue.main.async {
                let wasUserLoggedIn = self.user != nil
                let isUserLoggedInNow = firebaseUser != nil
                
                self.user = firebaseUser
                
                // 狀態從登入變為登出
                if wasUserLoggedIn && !isUserLoggedInNow {
                    print("AuthManager | AuthStateListener | 用戶已登出。清除本地用戶 Profile。")
                    self.userProfileService.clearLocalUserProfile()
                    self.isLoading = false // 確保登出後結束加載狀態
                }
            }
        }
    }

    /// `AuthManager` 的反初始化方法 (deinitializer)。
    /// 當 `AuthManager` 的實例即將被系統釋放時調用。
    /// 主要目的是移除之前註冊的 Firebase Auth 狀態監聽器，以防止潛在的記憶體洩漏。
    deinit {
        print("AuthManager | DEINIT | AuthManager 正在反初始化。")
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
            print("AuthManager | DEINIT | Firebase AuthStateDidChangeListener 已成功移除。")
        } else {
            print("AuthManager | DEINIT | 沒有需要移除的 AuthStateDidChangeListener。")
        }
    }

    // MARK: - 輔助方法 (Helper Methods)

    /// 獲取當前應用程式中最頂層的 `UIViewController`。
    /// 此方法主要供 Google 登入 SDK (`GIDSignIn`) 使用，因為它需要一個 präsentierende (presenting)
    /// 視圖控制器來在其上顯示 Google 的登入界面。
    /// - Returns: 如果成功獲取，則返回最頂層的 `UIViewController`；否則返回 `nil`。
    private func getTopViewController() -> UIViewController? {
        print("AuthManager | getTopViewController | 嘗試獲取頂層視圖控制器。")
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            print("AuthManager | getTopViewController | 錯誤：無法獲取到有效的 window scene 或 root view controller。")
            return nil
        }

        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        print("AuthManager | getTopViewController | 成功獲取到頂層視圖控制器: \(String(describing: type(of: topController)))")
        return topController
    }

    /// 為 Apple 登入流程生成一個隨機的、加密安全的 Nonce (Number used once) 字串。
    /// Nonce 用於防止重放攻擊 (replay attacks)，確保 Apple 返回的身份令牌是針對當前這次登入請求的。
    /// - Parameter length: 生成的 Nonce 字串的長度，默認為 32 個字符。
    /// - Returns: 成功時返回隨機 Nonce 字串。
    /// - Throws: `AuthManagerErrorType.nonceGenerationFailed` 如果 `SecRandomCopyBytes` 失敗。
    func generateNonce(length: Int = 32) -> String {
        print("AuthManager | generateNonce | 開始生成 Nonce，請求長度: \(length)。")
        precondition(length > 0, "Nonce 長度必須大於 0。")

        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        guard errorCode == errSecSuccess else {
            print("AuthManager | generateNonce | 嚴重錯誤：無法生成隨機字節。SecRandomCopyBytes 失敗，OSStatus: \(errorCode)。")
            self.errorMessage = AuthManagerErrorType.nonceGenerationFailed(osStatus: errorCode)
            return "0"
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonceString = String(randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        })
        print("AuthManager | generateNonce | Nonce 生成成功。")
        return nonceString
    }


    // MARK: - 登入方法 (Sign-In Methods)

    // --- Google 登入 (Google Sign-In) ---
    /// 啟動通過 Google 帳戶進行身份驗證的流程。
    /// 此方法獲取 Google 憑證後，會調用內部的 `signInToFirebase` 方法來完成登入。
    func signInWithGoogle() {
        print("AuthManager | signInWithGoogle | 開始 Google 登入流程。")
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        guard let topVC = getTopViewController() else {
            print("AuthManager | signInWithGoogle | 錯誤：無法獲取頂層視圖控制器。")
            DispatchQueue.main.async {
                self.errorMessage = .topViewControllerNotFound
                self.isLoading = false
            }
            return
        }

        print("AuthManager | signInWithGoogle | 調用 GIDSignIn.sharedInstance.signIn...")
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { [weak self] result, error in
            guard let self = self else {
                print("AuthManager | signInWithGoogle | GIDSignIn 回調中 self (AuthManager) 已被釋放。")
                return
            }

            if let gidError = error {
                print("AuthManager | signInWithGoogle | Google SDK 返回錯誤: \(gidError.localizedDescription)")
                DispatchQueue.main.async {
                    if (gidError as NSError).code == GIDSignInError.canceled.rawValue {
                        self.errorMessage = .userCancelledOperation
                    } else {
                        self.errorMessage = .googleSignInFailed(underlyingError: gidError)
                    }
                    self.isLoading = false
                }
                return
            }

            guard let googleUser = result?.user,
                  let idToken = googleUser.idToken?.tokenString else {
                print("AuthManager | signInWithGoogle | 錯誤：無法從 Google User 結果中獲取 idToken。")
                DispatchQueue.main.async {
                    self.errorMessage = .googleSignInMissingToken
                    self.isLoading = false
                }
                return
            }
            print("AuthManager | signInWithGoogle | 成功從 Google 獲取 ID Token。")

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: googleUser.accessToken.tokenString)
            
            // 調用統一的 Firebase 登入方法
            self.signInToFirebase(with: credential, providerName: "Google", initialDisplayName: googleUser.profile?.name)
        }
    }

    // --- Apple 登入 (Apple Sign-In) ---
    /// 處理通過 Apple ID 獲取的 `ASAuthorizationAppleIDCredential`。
    /// 此方法創建 Apple 憑證後，會調用內部的 `signInToFirebase` 方法來完成登入。
    /// - Parameters:
    ///   - credential: 從 Apple 登入成功後獲取的 `ASAuthorizationAppleIDCredential` 對象。
    ///   - nonce: 在發起 Apple 登入請求時生成的、未經哈希的原始 Nonce 字串。
    func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential, nonce: String) {
        print("AuthManager | handleAppleSignIn | 開始處理 Apple 登入憑證。")
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        guard let appleIDTokenData = credential.identityToken,
              let idTokenString = String(data: appleIDTokenData, encoding: .utf8) else {
            print("AuthManager | handleAppleSignIn | 錯誤：無法從 Apple Credential 獲取 ID Token。")
            DispatchQueue.main.async {
                self.errorMessage = .appleSignInMissingCredentialOrToken
                self.isLoading = false
            }
            return
        }
        print("AuthManager | handleAppleSignIn | 成功從 Apple Credential 獲取 ID Token。")

        var initialDisplayName: String?
        if let fullName = credential.fullName, let givenName = fullName.givenName, let familyName = fullName.familyName {
            initialDisplayName = PersonNameComponents(givenName: givenName, familyName: familyName).formatted()
            print("AuthManager | handleAppleSignIn | 首次登入，獲取到 Apple 全名: \(initialDisplayName!)")
        } else {
            print("AuthManager | handleAppleSignIn | 非首次登入或用戶未分享姓名。")
        }
        
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        // 調用統一的 Firebase 登入方法
        self.signInToFirebase(with: firebaseCredential, providerName: "Apple", initialDisplayName: initialDisplayName)
    }
    
    // --- 統一的 Firebase 登入處理器 ---
    /// 使用給定的 AuthCredential 登入 Firebase，並觸發後續的用戶 Profile 處理。
    /// 這是 Google 和 Apple 登入流程的共同終點。
    /// - Parameters:
    ///   - credential: 從第三方提供商（Google, Apple）獲取的 Firebase 憑證。
    ///   - providerName: 提供商名稱（用於日誌記錄）。
    ///   - initialDisplayName: 從提供商處獲得的初始顯示名稱（如果有的話）。
    private func signInToFirebase(with credential: AuthCredential, providerName: String, initialDisplayName: String?) {
        print("AuthManager | signInToFirebase | 使用 \(providerName) 憑證登入 Firebase...")
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let self = self else { return }

            if let fbError = error {
                print("AuthManager | signInToFirebase | Firebase Auth (使用 \(providerName) 憑證) 登入失敗: \(fbError.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = .firebaseSignInFailed(underlyingError: fbError)
                    self.isLoading = false
                }
                return
            }
            
            guard let user = authResult?.user else {
                print("AuthManager | signInToFirebase | Firebase Auth 成功但未返回 User 物件，這不應該發生。")
                DispatchQueue.main.async {
                    self.errorMessage = .unexpectedInternalError(underlyingError: nil)
                    self.isLoading = false
                }
                return
            }
            
            print("AuthManager | signInToFirebase | Firebase Auth 成功! User UID: \(user.uid)。準備處理用戶 Profile。")
            // 登入成功，authStateDidChangeListener 會更新 self.user，
            // 接著我們手動觸發 Profile 的檢查和創建。
            Task {
                await self.handleUserSignedIn(user: user, initialDisplayName: initialDisplayName)
            }
        }
    }

    // --- 登入後的 Profile 處理 ---
    /// 在 Firebase 用戶成功登入後，協調 `UserProfileService` 進行 Profile 的檢查、創建和監聽。
    /// 這是一個異步方法，並確保所有 UI 更新都在主線程上。
    /// - Parameters:
    ///   - user: 剛剛登入的 Firebase User 對象。
    ///   - initialDisplayName: 從登入提供商處獲得的初始顯示名稱，用於創建新 Profile。
    @MainActor
    private func handleUserSignedIn(user: User, initialDisplayName: String?) async {
        print("AuthManager | handleUserSignedIn | 開始處理登入後續事宜，UID: \(user.uid)。")
        self.isLoading = true // 確保在 profile 處理期間，UI 仍處於加載狀態
        self.errorMessage = nil
        
        do {
            // 步驟 1: 確保 ID token 已準備好（通常是立即的，除非需要刷新）
            let _ = try await user.getIDToken()
            print("AuthManager | handleUserSignedIn | 步驟 1/3: Firebase ID Token 已驗證。")

            // 步驟 2: 調用 UserProfileService 檢查或創建 Profile。
            // 使用 withCheckedThrowingContinuation 將閉包 API 轉換為 async/await 風格。
            print("AuthManager | handleUserSignedIn | 步驟 2/3: 調用 UserProfileService 檢查/創建 Profile...")
            let profile = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UserProfile, Error>) in
                userProfileService.checkAndCreateUserProfile(for: user, initialDisplayName: initialDisplayName) { result in
                    continuation.resume(with: result)
                }
            }
            print("AuthManager | handleUserSignedIn | UserProfileService 成功返回 Profile。UserID: \(profile.userId)。")
            
            // 步驟 3: 為 Profile 建立實時監聽器
            print("AuthManager | handleUserSignedIn | 步驟 3/3: 建立用戶 Profile 的實時監聽器。")
            userProfileService.listenForUserProfileChanges(uid: user.uid)
            
            print("AuthManager | handleUserSignedIn | 登入及 Profile 處理流程全部成功完成。")
            
        } catch {
            print("AuthManager | handleUserSignedIn | 處理過程中發生錯誤: \(error.localizedDescription)")
            if let profileError = error as? UserProfileServiceError {
                self.errorMessage = .userProfileOperationFailed(profileError: profileError)
            } else {
                self.errorMessage = .firebaseSignInFailed(underlyingError: error)
            }
            // 發生錯誤，考慮是否要將用戶登出
            // signOut() // 可選：如果 profile 創建失敗是不可接受的，則強制登出。
        }
        
        self.isLoading = false
    }
    
    // MARK: - 登出方法 (Sign-Out Method)

    /// 執行用戶登出操作。
    /// 此方法會登出所有關聯的提供商（如 Google）和 Firebase 本身。
    func signOut() {
        print("AuthManager | signOut | 開始用戶登出流程。")
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        // 登出 Google，清除 Google 的本地會話。
        print("AuthManager | signOut | 步驟 1/2: 執行 Google 登出 (GIDSignIn.sharedInstance.signOut())。")
        GIDSignIn.sharedInstance.signOut()

        // 登出 Firebase，這會觸發 authStateDidChangeListener。
        do {
            print("AuthManager | signOut | 步驟 2/2: 執行 Firebase 登出 (Auth.auth().signOut())。")
            try Auth.auth().signOut()
            print("AuthManager | signOut | Firebase 登出指令已成功發送。authStateDidChangeListener 將處理後續狀態更新。")
            // 成功登出後，authStateDidChangeListener 會將 self.user 設為 nil，
            // 並將 isLoading 設為 false。
        } catch let signOutError {
            print("AuthManager | signOut | Firebase 登出操作失敗: \(signOutError.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = .firebaseSignOutFailed(underlyingError: signOutError)
                self.isLoading = false // 確保在錯誤時重置 isLoading
            }
        }
    }
}
