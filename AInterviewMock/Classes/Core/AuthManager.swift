import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

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

    /// `UserProfileService` 的實例，通過依賴注入傳入。
    /// `AuthManager` 使用它來觸發用戶 Profile 數據的相關操作（如檢查、創建、監聽）。
    private let userProfileService: UserProfileService

    /// Firebase Auth 狀態監聽器的句柄 (handle)。
    /// 用於在 `AuthManager` 實例被銷毀 (`deinit`) 時，能夠正確地從 Firebase Auth 系統中移除監聽器，以防止記憶體洩漏。
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    // MARK: - 錯誤類型枚舉 (Error Type Enumeration)
    /// `AuthManagerErrorType` 定義了在身份驗證過程中可能發生的各種錯誤類型。
    /// 它符合 `Error` 協定，並且為了方便在 SwiftUI 中使用（例如 `Alert`），建議使其符合 `Identifiable` 和 `LocalizedError`。
    enum AuthManagerErrorType: Error, Identifiable, LocalizedError {
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
        /// 這使得可以將 Profile 相關的錯誤統一通過 `AuthManager` 暴露給視圖層。
        case userProfileOperationFailed(profileError: UserProfileServiceError) // UserProfileServiceError 需要被定義
        
        /// 無法獲取到應用程式的頂層視圖控制器 (Top View Controller)。
        /// 這通常是 Google 登入 SDK 呈現其 UI 所必需的。
        case topViewControllerNotFound
        
        /// 為 Apple 登入生成隨機 Nonce 字串時失敗。
        case nonceGenerationFailed(osStatus: OSStatus) // OSStatus 可以提供更詳細的系統錯誤碼
        
        /// 其他未被明確分類的內部錯誤或未知錯誤。關聯值可以包含一個可選的底層 `Error` 對象。
        /// 這是為了捕捉那些沒有特定 case 的錯誤，或者作為一個兜底的錯誤類型。
        case unexpectedInternalError(underlyingError: Error?)

        // MARK: Identifiable Conformance
        /// 為了讓 SwiftUI 的 .alert(item:) 可以使用，我們需要一個穩定的 id。
        /// 通常使用 localizedDescription，但如果錯誤類型會頻繁變化，可能需要更穩定的方式。
        /// 這裡我們為每個 case 生成一個唯一的標識符字符串。
        var id: String {
            switch self {
            case .userCancelledOperation: return "userCancelledOperation"
            case .googleSignInFailed: return "googleSignInFailed"
            case .googleSignInMissingToken: return "googleSignInMissingToken"
            case .appleSignInFailed: return "appleSignInFailed"
            case .appleSignInMissingCredentialOrToken: return "appleSignInMissingCredentialOrToken"
            case .firebaseSignInFailed: return "firebaseSignInFailed"
            case .firebaseSignOutFailed: return "firebaseSignOutFailed"
            case .userProfileOperationFailed: return "userProfileOperationFailed"
            case .topViewControllerNotFound: return "topViewControllerNotFound"
            case .nonceGenerationFailed: return "nonceGenerationFailed"
            case .unexpectedInternalError: return "unexpectedInternalError"
            }
        }

        // MARK: LocalizedError Conformance
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
        print("AuthManager | 初始化 (init) 並注入 UserProfileService。")

        // 添加 Firebase 身份驗證狀態變更的監聽器。
        // 這個監聽器是一個閉包，當 Firebase 的用戶認證狀態發生任何改變時（例如用戶登入、登出，或身份令牌刷新），
        // Firebase SDK 都會自動調用這個閉包。
        // `[weak self]` 用於避免 AuthManager 與閉包之間的循環引用。
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, firebaseUser) in
            // 確保 self (AuthManager 實例) 仍然存在。
            guard let self = self else {
                print("AuthManager | AuthStateDidChangeListener - self (AuthManager) 已被釋放，提前返回。")
                return
            }
            print("AuthManager | AuthStateDidChangeListener - 監聽到 Firebase Auth 狀態變化。Firebase User UID: \(firebaseUser?.uid ?? "未登入")")

            // 所有對 @Published 屬性的更新都應在主線程上進行，以確保 SwiftUI 視圖能夠正確響應。
            DispatchQueue.main.async {
                let oldAuthUID = self.user?.uid // 記錄舊的用戶 UID，用於判斷是否是新用戶登入。
                self.user = firebaseUser       // 更新 @Published var user。

                if let fbUser = firebaseUser {
                    // --- 情況：用戶已通過 Firebase Auth 登入 ---
                    self.isLoading = true      // 設置 AuthManager 自身的加載狀態為 true，表示開始處理登入後續流程。
                    self.errorMessage = nil    // 清除任何之前的錯誤信息。

                    // 判斷是否是新用戶登入，或者本地的 UserProfile 尚未加載。
                    // 如果是，則需要觸發 UserProfileService 去檢查或創建用戶的應用程式 Profile。
                    if oldAuthUID != fbUser.uid || self.userProfileService.currentUserProfile == nil {
                        print("AuthManager | 新用戶登入或本地 Profile 未加載。UID: \(fbUser.uid)。將調用 UserProfileService 檢查/創建 Profile。")
                        self.userProfileService.checkAndCreateUserProfile(for: fbUser) { result in
                            // UserProfileService 的操作完成後的回調。
                            switch result {
                            case .success(let profile):
                                // Profile 成功加載或創建。
                                print("AuthManager | UserProfileService 成功加載/創建 Profile。App UserID: \(profile.userId)")
                                // 開始監聽此用戶 Profile 在 Firestore 中的後續變化。
                                self.userProfileService.listenForUserProfileChanges(uid: fbUser.uid)
                                self.isLoading = false // AuthManager 的登入後續流程處理完畢。
                            case .failure(let profileError):
                                // Profile 操作失敗。
                                print("AuthManager | UserProfileService 操作失敗: \(profileError.localizedDescription)")
                                // 將 UserProfileServiceError 包裝進 AuthManagerErrorType。
                                self.errorMessage = .userProfileOperationFailed(profileError: profileError)
                                self.isLoading = false // AuthManager 的登入後續流程處理完畢（雖然失敗）。
                            }
                        }
                    } else {
                        // 情況：用戶已通過 Firebase Auth 登入，並且 UserProfileService 中可能已經有該用戶的 Profile。
                        // 這通常發生在 App 從後台返回前台，或者用戶之前已登入且 Profile 已被監聽。
                        print("AuthManager | 用戶 \(fbUser.uid) 已登入，且 Profile 可能已存在於 UserProfileService。確保監聽器運行並更新登入時間。")
                        // 重新確保 Profile 監聽器正在運行。
                        self.userProfileService.listenForUserProfileChanges(uid: fbUser.uid)
                        // 更新用戶的最後登入時間。
                        self.userProfileService.updateUserLastLoginDate(uid: fbUser.uid)
                        self.isLoading = false // AuthManager 的登入後續流程處理完畢。
                    }
                } else {
                    // --- 情況：用戶未登入或已登出 (firebaseUser 為 nil) ---
                    print("AuthManager | Firebase Auth 狀態：用戶未登入或已登出。")
                    // 清理 UserProfileService 中的本地用戶數據並停止監聽。
                    self.userProfileService.clearLocalUserProfile()
                    self.isLoading = false     // AuthManager 的狀態更新完畢。
                    self.errorMessage = nil    // 清除錯誤信息。
                }
            }
        }
    }

    /// `AuthManager` 的反初始化方法 (deinitializer)。
    /// 當 `AuthManager` 的實例即將被系統釋放時調用。
    /// 主要目的是移除之前註冊的 Firebase Auth 狀態監聽器，以防止潛在的記憶體洩漏
    /// 或在對象已被釋放後仍然嘗試執行閉包。
    deinit {
        print("AuthManager | 反初始化 (deinit) 開始。")
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
            print("AuthManager | Firebase AuthStateDidChangeListener 已成功移除。")
        } else {
            print("AuthManager | 沒有需要移除的 AuthStateDidChangeListener。")
        }
    }

    // MARK: - 輔助方法 (Helper Methods)

    /// 獲取當前應用程式中最頂層的 `UIViewController`。
    /// 此方法主要供 Google 登入 SDK (`GIDSignIn`) 使用，因為它需要一個 präsentierende (presenting)
    /// 視圖控制器來在其上顯示 Google 的登入界面 (通常是一個 WebView 或帳戶選擇器)。
    /// - Returns: 如果成功獲取，則返回最頂層的 `UIViewController`；否則返回 `nil`。
    private func getTopViewController() -> UIViewController? {
        print("AuthManager | getTopViewController - 嘗試獲取頂層視圖控制器。")
        // 嘗試獲取當前活躍的 UIWindowScene。
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              // 獲取該 Scene 中的主窗口 (key window) 的根視圖控制器。
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            print("AuthManager | getTopViewController - 錯誤：無法獲取到有效的 window scene 或 root view controller。")
            return nil
        }

        // 從根視圖控制器開始，遍歷其 presentedViewController 鏈，直到找到最頂層的那個。
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        print("AuthManager | getTopViewController - 成功獲取到頂層視圖控制器: \(topController.description)")
        return topController
    }

    /// 為 Apple 登入流程生成一個隨機的、加密安全的 Nonce (Number used once) 字串。
    /// Nonce 用於防止重放攻擊 (replay attacks)，確保 Apple 返回的身份令牌是針對當前這次登入請求的。
    /// 此方法應在 SwiftUI View 中的 `SignInWithAppleButton` 的 `onRequest` 閉包中被調用。
    /// - Parameter length: 生成的 Nonce 字串的長度，默認為 32 個字符。
    /// - Returns: 生成的隨機 Nonce 字串。
    /// - Important: 此方法目前在生成失敗時會調用 `fatalError`。在生產環境中，應考慮返回 `Result<String, Error>` 或 `String?` 以進行更優雅的錯誤處理。
    func generateNonce(length: Int = 32) -> String {
        print("AuthManager | generateNonce - 開始生成 Nonce。請求長度: \(length)")
        precondition(length > 0, "Nonce 長度必須大於 0。") // 確保請求的長度有效。

        var randomBytes = [UInt8](repeating: 0, count: length)
        // 使用系統的安全隨機數生成器 (SecRandomCopyBytes) 來填充字節數組。
        // kSecRandomDefault 指定使用預設的隨機數生成算法。
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        // 檢查隨機數生成是否成功。
        guard errorCode == errSecSuccess else {
            print("AuthManager | generateNonce - 嚴重錯誤：無法生成隨機字節。SecRandomCopyBytes 失敗，OSStatus: \(errorCode)")
            // 在生產應用中，不應直接 fatalError。應拋出或返回一個錯誤。
            // 例如: throw AuthManagerErrorType.nonceGenerationFailed(osStatus: errorCode)
            fatalError("AuthManager | 無法生成 Nonce。SecRandomCopyBytes 因 OSStatus \(errorCode) 而失敗。")
        }

        // 定義用於構建 Nonce 字串的字符集。
        // 包含大小寫字母、數字以及一些對 URL 和文件名安全的特殊字符。
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        // 將隨機字節數組映射到字符集中的字符，以構建最終的 Nonce 字串。
        // 每個字節通過取模運算 (%) 映射到字符集中的一個索引。
        let nonceString = String(randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        })
        print("AuthManager | generateNonce - Nonce 生成成功: \(nonceString.prefix(10))... (僅顯示前綴)") // 避免日誌過長
        return nonceString
    }


    // MARK: - 登入方法 (Sign-In Methods)

    // --- Google 登入 (Google Sign-In) ---
    /// 啟動通過 Google 帳戶進行身份驗證的流程。
    /// 此方法會：
    /// 1. 設置加載狀態 (`isLoading = true`)。
    /// 2. 獲取頂層視圖控制器以呈現 Google 登入 UI。
    /// 3. 調用 Google Sign-In SDK (`GIDSignIn`) 來處理實際的登入交互。
    /// 4. 在獲取到 Google 的 ID Token 後，用它創建一個 Firebase `GoogleAuthProvider.credential`。
    /// 5. 使用此 Firebase 憑證來登入 Firebase Auth 系統。
    /// 成功登入 Firebase 後，`authStateDidChangeListener` 會被觸發，進而更新 `self.user` 並處理用戶 Profile。
    func signInWithGoogle() {
        print("AuthManager | signInWithGoogle - 開始 Google 登入流程。")
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil // 清除之前的錯誤
        }

        // 獲取用於呈現 Google 登入界面的頂層 View Controller。
        guard let topVC = getTopViewController() else {
            print("AuthManager | signInWithGoogle - 錯誤：無法獲取頂層視圖控制器。")
            DispatchQueue.main.async {
                self.errorMessage = .topViewControllerNotFound
                self.isLoading = false
            }
            return
        }

        print("AuthManager | signInWithGoogle - 即將調用 GIDSignIn.sharedInstance.signIn。")
        // 使用 Google Sign-In SDK 啟動登入流程。
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { [weak self] result, error in
            // Google SDK 的登入回調。
            guard let self = self else {
                print("AuthManager | signInWithGoogle - GIDSignIn 回調中 self (AuthManager) 已被釋放。")
                return
            }

            // 檢查 Google SDK 是否返回了錯誤。
            if let gidError = error {
                print("AuthManager | signInWithGoogle - Google SDK 返回錯誤: \(gidError.localizedDescription)")
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

            // 從 Google 登入結果中獲取用戶信息和 ID Token。
            guard let googleUser = result?.user,
                  let idToken = googleUser.idToken?.tokenString else {
                print("AuthManager | signInWithGoogle - 錯誤：無法從 Google User 結果中獲取 idToken。")
                DispatchQueue.main.async {
                    self.errorMessage = .googleSignInMissingToken
                    self.isLoading = false
                }
                return
            }
            print("AuthManager | signInWithGoogle - 成功從 Google 獲取 ID Token。")

            // 使用 Google 返回的 ID Token 和 Access Token 創建 Firebase 的 GoogleAuthProvider 憑證。
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: googleUser.accessToken.tokenString)
            print("AuthManager | signInWithGoogle - Firebase Google 憑證已創建。")

            // 使用創建的 Firebase 憑證登入 Firebase Auth 系統。
            print("AuthManager | signInWithGoogle - 即將使用 Google 憑證登入 Firebase Auth。")
            Auth.auth().signIn(with: credential) { authResult, firebaseError in
                // Firebase Auth 登入回調。
                // 注意：此處的 self.isLoading 和 self.user 的最終狀態主要由 authStateDidChangeListener 管理。
                // 但如果 Firebase signIn 直接失敗，我們需要在這裡處理錯誤和 isLoading。
                if let fbError = firebaseError {
                    print("AuthManager | signInWithGoogle - Firebase Auth (使用 Google 憑證) 登入失敗: \(fbError.localizedDescription)")
                    DispatchQueue.main.async {
                        self.errorMessage = .firebaseSignInFailed(underlyingError: fbError)
                        self.isLoading = false // 確保在 Firebase 直接登入失敗時重置 isLoading
                    }
                    return
                }
                // 如果 Firebase 登入成功，authStateDidChangeListener 會被觸發，
                // 它會更新 self.user 和 self.isLoading，並處理 Profile。
                print("AuthManager | signInWithGoogle - Firebase Auth (使用 Google 憑證) 登入成功! User UID: \(authResult?.user.uid ?? "N/A")")
                // isLoading 將由 authStateDidChangeListener 設置為 false。
            }
        }
    }

    // --- Apple 登入 (Apple Sign-In) ---
    /// 處理通過 Apple ID 進行身份驗證的流程的後續步驟。
    /// 此方法通常在 SwiftUI View (`SignInWithAppleButton` 的 `onCompletion` 閉包) 成功獲取到
    /// `ASAuthorizationAppleIDCredential` 後被調用。
    /// 它會：
    /// 1. 設置加載狀態 (`isLoading = true`)。
    /// 2. 從傳入的 `credential` 中提取 Apple ID Token。
    /// 3. 使用 Apple ID Token 和之前生成的 `nonce` 創建一個 Firebase `OAuthProvider.credential` (針對 "apple.com")。
    /// 4. 使用此 Firebase 憑證來登入 Firebase Auth 系統。
    /// 成功登入 Firebase 後，`authStateDidChangeListener` 會被觸發，進而更新 `self.user` 並處理用戶 Profile。
    /// - Parameters:
    ///   - credential: 從 Apple 登入成功後獲取的 `ASAuthorizationAppleIDCredential` 對象。
    ///   - nonce: 在發起 Apple 登入請求時生成的、未經哈希的原始 Nonce 字串。
    func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential, nonce: String) {
        print("AuthManager | handleAppleSignIn - 開始處理 Apple 登入憑證。Nonce (部分): \(nonce.prefix(5))...") // 保護 Nonce
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil // 清除之前的錯誤
        }

        // 從 Apple 憑證中獲取 Identity Token (JWT 格式的 Data)。
        guard let appleIDTokenData = credential.identityToken,
              // 將 Token Data 轉換為 UTF-8 字符串。
              let idTokenString = String(data: appleIDTokenData, encoding: .utf8) else {
            print("AuthManager | handleAppleSignIn - 錯誤：無法從 Apple Credential 獲取 ID Token Data 或轉換為 String。")
            DispatchQueue.main.async {
                self.errorMessage = .appleSignInMissingCredentialOrToken
                self.isLoading = false
            }
            return
        }
        print("AuthManager | handleAppleSignIn - 成功從 Apple Credential 獲取 ID Token String。")

        // 使用 Apple ID Token 和原始 Nonce 創建 Firebase 的 OAuthProvider 憑證。
        // Provider ID "apple.com" 指定這是用於 Apple 登入的。
        // `rawNonce` 必須是發起請求時未經 SHA256 哈希的原始 Nonce。
        let firebaseCredential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce // Firebase SDK 需要原始 nonce 來驗證
        )
        print("AuthManager | handleAppleSignIn - Firebase Apple 憑證已創建。")
        
        // 使用創建的 Firebase 憑證登入 Firebase Auth 系統。
        print("AuthManager | handleAppleSignIn - 即將使用 Apple 憑證登入 Firebase Auth。")
        Auth.auth().signIn(with: firebaseCredential) { [weak self] (authResult, error) in
            // Firebase Auth 登入回調。
            guard let self = self else {
                print("AuthManager | handleAppleSignIn - Firebase signIn 回調中 self (AuthManager) 已被釋放。")
                return
            }
            // 同樣，isLoading 和 user 的最終狀態主要由 authStateDidChangeListener 管理。
            if let fbError = error {
                print("AuthManager | handleAppleSignIn - Firebase Auth (使用 Apple 憑證) 登入失敗: \(fbError.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = .firebaseSignInFailed(underlyingError: fbError)
                    self.isLoading = false // 確保在 Firebase 直接登入失敗時重置 isLoading
                }
                return
            }
            // 如果 Firebase 登入成功，authStateDidChangeListener 會處理後續。
            print("AuthManager | handleAppleSignIn - Firebase Auth (使用 Apple 憑證) 登入成功! User UID: \(authResult?.user.uid ?? "N/A")")
            // isLoading 將由 authStateDidChangeListener 設置為 false。
        }
    }

    // MARK: - 登出方法 (Sign-Out Method)

    /// 執行用戶登出操作。
    /// 此方法會：
    /// 1. 設置加載狀態 (`isLoading = true`)。
    /// 2. 調用 Google Sign-In SDK (`GIDSignIn`) 的登出方法，以清除 Google 的本地登入狀態。
    /// 3. 調用 Firebase Auth (`Auth.auth()`) 的登出方法。
    /// 成功從 Firebase Auth 登出後，`authStateDidChangeListener` 會被觸發，將 `self.user` 設為 `nil`，
    /// 並觸發 `UserProfileService` 清理本地用戶數據。
    func signOut() {
        print("AuthManager | signOut - 開始用戶登出流程。")
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil // 清除之前的錯誤
        }

        // 首先登出 Google (如果用戶是通過 Google 登入的)。
        // 即使不是，調用此方法也通常是安全的，它會清除任何 Google 相關的會話。
        print("AuthManager | signOut - 正在執行 Google 登出 (GIDSignIn.sharedInstance.signOut())。")
        GIDSignIn.sharedInstance.signOut()
        print("AuthManager | signOut - Google 已登出。")

        // 然後登出 Firebase。
        // 這會清除 Firebase SDK 中的當前用戶會話，並觸發 authStateDidChangeListener。
        do {
            print("AuthManager | signOut - 正在執行 Firebase 登出 (Auth.auth().signOut())。")
            try Auth.auth().signOut()
            // 登出成功後，authStateDidChangeListener 會被調用，
            // 它會將 self.user 設為 nil，self.isLoading 設為 false，並調用 userProfileService.clearLocalUserProfile()。
            print("AuthManager | signOut - Firebase 登出指令已成功發送。authStateDidChangeListener 將處理後續狀態更新。")
        } catch let signOutError {
            // 如果 Firebase 登出操作本身失敗（較少見）。
            print("AuthManager | signOut - Firebase 登出操作失敗: \(signOutError.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = .firebaseSignOutFailed(underlyingError: signOutError)
                self.isLoading = false // 確保在錯誤時重置 isLoading
            }
        }
    }
}
