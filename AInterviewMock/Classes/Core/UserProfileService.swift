//
//  UserProfileService.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/8.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

// MARK: - UserProfileServiceError (錯誤枚舉)
/// `UserProfileServiceError` 定義了在處理用戶 Profile 數據過程中可能發生的各種特定錯誤。
/// 它符合 `Error`, `Identifiable` (便於 SwiftUI Alert 使用) 和 `LocalizedError` (提供用戶友好的錯誤描述)。
enum UserProfileServiceError: Error, Identifiable, LocalizedError {
    /// Firestore 資料庫操作失敗時拋出，例如讀取、寫入或更新文檔失敗。
    /// - Parameter underlyingError: 導致此錯誤的原始 `Error` 對象。
    case firestoreError(underlyingError: Error)
    
    /// 從 Firestore 文檔數據解碼為 `UserProfile` 結構時失敗。
    /// - Parameter underlyingError: 導致解碼失敗的原始 `Error` 對象。
    case decodingError(underlyingError: Error)
    
    /// 當嘗試在用戶未通過 Firebase Authentication 驗證的情況下執行需要驗證的操作時拋出。
    case userNotAuthenticated
    
    /// 當嘗試獲取一個不存在的用戶 Profile 文檔時拋出。
    case profileNotFound
    
    /// （可選）當嘗試創建一個已存在的用戶 Profile 時，如果業務邏輯不允許覆蓋，則可能拋出此錯誤。
    /// - Parameter uid: 已存在的用戶的 Firebase Auth UID。
    case profileAlreadyExists(uid: String)
    
    /// 在 Firestore 事務中更新計數器文檔 (`counters/userCounter`) 失敗時拋出。
    /// - Parameter underlyingError: 導致事務失敗的原始 `Error` 對象。
    case counterTransactionFailed(underlyingError: Error)
    
    /// 在 Firestore 事務中創建新的用戶 Profile 文檔失敗時拋出。
    /// - Parameter underlyingError: 導致事務失敗的原始 `Error` 對象。
    case profileCreationTransactionFailed(underlyingError: Error)
    
    /// 當 Firestore 事務成功完成，但返回的結果不是預期的類型或為 `nil` 時拋出。
    case unexpectedTransactionResult
    
    /// 用於表示一些未被上述 case 覆蓋的通用錯誤。
    /// - Parameter message: 描述錯誤的字符串。
    case generalError(message: String)
    
    /// 刪除帳號失敗
    /// - Parameter underlyingError: 導致事務失敗的原始 `Error` 對象。
    case accountDeletionFailed(underlyingError: Error)

    // MARK: Identifiable Conformance
    /// 為 SwiftUI 的 `Alert(item: ...)` 提供一個穩定的 ID。
    /// 使用錯誤的本地化描述作為 ID。注意：如果本地化描述可能不唯一或頻繁變化，
    /// 可能需要為每個 case 提供一個固定的字符串 ID。
    var id: String { self.localizedDescription }

    // MARK: LocalizedError Conformance
    /// 提供一個用戶友好的錯誤描述，用於向用戶顯示錯誤信息。
    var errorDescription: String {
        switch self {
        case .firestoreError(let error):
            return "資料庫操作時發生錯誤: \(error.localizedDescription)"
        case .decodingError(let error):
            return "讀取您的資料時發生錯誤: \(error.localizedDescription)"
        case .userNotAuthenticated:
            return "您需要先登入才能執行此操作。"
        case .profileNotFound:
            return "找不到您的用戶資料記錄。"
        case .profileAlreadyExists(let uid):
            return "用戶資料 (ID: \(uid)) 已經存在。" // 根據實際情況調整措辭
        case .counterTransactionFailed(let error):
            // 對於用戶來說，底層計數器錯誤可能不需要太詳細
            return "系統處理您的請求時發生問題，請稍後再試 (錯誤代碼: CF-\(String(describing: (error as NSError).code))。"
        case .profileCreationTransactionFailed(let error):
            return "無法完成您的用戶資料創建: \(error.localizedDescription)"
        case .unexpectedTransactionResult:
            return "處理您的請求時發生了未預期的情況。"
        case .accountDeletionFailed(let error):
            return "刪除帳號時發生錯誤：\(error.localizedDescription)"
        case .generalError(let message):
            return message
        }
    }
}


// MARK: - UserProfileService
/// `UserProfileService` 類別負責管理應用程式中與用戶 Profile 數據（存儲在 Firestore 中）相關的所有操作。
/// 它是一個 `ObservableObject`，以便其 `@Published` 屬性（如 `currentUserProfile`, `isLoading`, `serviceError`）
/// 的變化可以被 SwiftUI 視圖觀察並觸發 UI 更新。
///
/// 主要職責包括：
/// - 檢查用戶的 Firestore Profile 是否存在，如果不存在則創建一個新的 Profile（包含自增的應用內 `userId`）。
/// - 從 Firestore 獲取和更新用戶 Profile 數據（例如，最後登入時間、金幣數量）。
/// - 實時監聽用戶 Profile 在 Firestore 中的變化，並更新本地緩存 (`currentUserProfile`)。
/// - 管理與 Profile 操作相關的加載狀態和錯誤狀態。
class UserProfileService: ObservableObject {

    // MARK: - 共用項目
    /// Firestore 數據庫的實例，用於所有 Firestore 操作。
    private let db = Firestore.firestore()
    /// 用於實時監聽當前用戶 Profile 文檔變化的 Firestore 監聽器註冊對象。
    private var userProfileListener: ListenerRegistration?
    private let functions = Functions.functions(region: "asia-east1")

    /// 當前已登入用戶的 `UserProfile` 數據的本地緩存。
    /// 當用戶登入並成功加載 Profile 後，此屬性會被填充。當 Profile 數據通過實時監聽器更新，或通過本地操作更新後，此屬性也會更新。SwiftUI 視圖可以觀察此屬性以顯示用戶相關信息。如果沒有用戶登入或 Profile 未加載，則為 `nil`。
    @Published var currentUserProfile: UserProfile?

    /// 一個布林值，指示當前是否有與用戶 Profile 相關的異步操作正在進行中。
    ///  `true` 表示正在加載，`false` 表示操作完成或空閒。
    @Published var isLoading: Bool = false

    /// 保存最近一次用戶 Profile 操作中發生的錯誤。
    /// 使用在文件頂部定義的 `UserProfileServiceError` 枚舉類型。如果操作成功或沒有錯誤，此值為 `nil`。
    @Published var serviceError: UserProfileServiceError?
    
    /// `UserProfileService` 的初始化方法。
    init() {
        loadPendingCoins()
        print("UPS | 初始化完成。")
    }
    
    /// 檢查指定 Firebase Auth 用戶的應用程式 Profile 是否已存在於 Firestore 中。
    /// 如果 Profile 不存在，則調用 `createNewUserProfile` 方法來創建一個新的 Profile。
    /// 如果 Profile 已存在，則獲取該 Profile 並更新本地緩存 (`currentUserProfile`) 和最後登入時間。
    /// 此方法通常在用戶通過 Firebase Auth 成功登入或註冊後，由 `AuthManager` 調用。
    ///
    /// - Parameters:
    ///   - authUser: 剛剛通過 Firebase Authentication 驗證的 `User` 對象 (來自 FirebaseAuth)。
    ///   - completion: 操作完成後的回調閉包。
    ///                 - `Result.success(UserProfile)`: 如果 Profile 成功獲取或創建，返回 `UserProfile` 對象。
    ///                 - `Result.failure(UserProfileServiceError)`: 如果操作過程中發生錯誤，返回相應的錯誤。
    func checkAndCreateUserProfile(for authUser: User, initialDisplayName: String?, completion: @escaping (Result<UserProfile, UserProfileServiceError>) -> Void) {
        print("UPS | 開始檢查或創建 Profile，針對 Auth UID: \(authUser.uid)")
        DispatchQueue.main.async {
            self.isLoading = true
            self.serviceError = nil // 清除之前的錯誤
        }

        let userProfileRef = db.collection("users").document(authUser.uid)

        // 嘗試從 Firestore 獲取用戶 Profile 文檔。
        userProfileRef.getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self else {
                print("UPS | checkAndCreateUserProfile - self (UserProfileService) 已被釋放，提前返回。")
                // 如果 self 為 nil，通常無法調用 completion，因為它可能也捕獲了 self。
                // 這裡可以考慮是否需要一個 default 的 completion 調用，但通常意味著流程已中斷。
                return
            }

            // 處理 Firestore getDocument 操作返回的錯誤。
            if let firestoreError = error {
                print("UPS | 獲取 Profile 文檔時發生 Firestore 錯誤，UID: \(authUser.uid)。錯誤: \(firestoreError.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.serviceError = .firestoreError(underlyingError: firestoreError)
                }
                completion(.failure(.firestoreError(underlyingError: firestoreError)))
                return
            }

            // 檢查文檔是否存在且包含數據。
            if let document = documentSnapshot, document.exists {
                // Profile 文檔已存在，嘗試將其數據解碼為 UserProfile 對象。
                print("UPS | Profile 文檔已存在，UID: \(authUser.uid)。正在嘗試解碼...")
                do {
                    let profile = try document.data(as: UserProfile.self)
                    print("UPS | Profile 解碼成功。App UserID: \(profile.userId)，Auth UID: \(authUser.uid)")
                    DispatchQueue.main.async {
                        self.currentUserProfile = profile
                        self.isLoading = false
                        // Profile 獲取成功後，更新該用戶的最後登入時間。
                        self.callCloudFunctionToUpdateUserLastLoginDate(uid: authUser.uid) { updateError in
                            if let error = updateError {
                                // 更新最後登入時間失敗是一個非關鍵錯誤，通常只記錄日誌，不阻塞主流程。
                                print("UPS | 更新用戶最後登入時間失敗 (在獲取 Profile 後)，UID: \(authUser.uid)。錯誤: \(error.localizedDescription)")
                            }
                        }
                    }
                    completion(.success(profile))
                } catch let decodingError {
                    // 解碼失敗。
                    print("UPS | 解碼現有 Profile 時發生錯誤，UID: \(authUser.uid)。錯誤: \(decodingError.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.serviceError = .decodingError(underlyingError: decodingError)
                    }
                    completion(.failure(.decodingError(underlyingError: decodingError)))
                }
            } else {
                // Profile 文檔不存在，需要創建新的 Profile。
                print("UPS | Profile 文檔不存在，UID: \(authUser.uid)。將調用 createNewUserProfile。")
                self.callCloudFunctionToCreateUserProfile(for: authUser, initialDisplayName: initialDisplayName, completion: completion)
            }
        }
    }

    private func callCloudFunctionToCreateUserProfile(for authUser: User, initialDisplayName: String?, completion: @escaping (Result<UserProfile, UserProfileServiceError>) -> Void) {
        print("UPS | 呼叫 Cloud Function createInitialUserProfile 創建新 Profile，UID: \(authUser.uid)")

        // 準備傳遞給 Cloud Function 的數據
        var data: [String: Any] = [:]
        if let email = authUser.email {
            data["userEmail"] = email // <-- 注意這裡的 Key 名稱與 TypeScript 和 UserProfile 結構體保持一致
        }
        if let displayName = initialDisplayName { // 優先使用從 Apple 登入傳遞的 displayName
            data["userName"] = displayName // <-- 注意這裡的 Key 名稱與 TypeScript 和 UserProfile 結構體保持一致
        } else if let authDisplayName = authUser.displayName { // 其次使用 Firebase Auth 提供的 displayName
            data["userName"] = authDisplayName // <-- 注意這裡的 Key 名稱與 TypeScript 和 UserProfile 結構體保持一致
        }

        functions.httpsCallable("createInitialUserProfile").call(data) { [weak self] result, error in
            guard let self = self else { return }

            if let callableError = error as NSError? {
                print("UPS | Cloud Function createInitialUserProfile 呼叫失敗: \(callableError.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // 嘗試將 Cloud Function 返回的錯誤轉換為 UserProfileServiceError
                    if let code = FunctionsErrorCode(rawValue: callableError.code) {
                        switch code {
                        case .alreadyExists:
                            self.serviceError = .profileAlreadyExists(uid: authUser.uid)
                        case .internal:
                            self.serviceError = .profileCreationTransactionFailed(underlyingError: callableError)
                        default:
                            self.serviceError = .generalError(message: callableError.localizedDescription)
                        }
                    } else {
                        self.serviceError = .generalError(message: callableError.localizedDescription)
                    }
                }
                completion(.failure(self.serviceError!))
                return
            }

            // Cloud Function 成功返回，嘗試解析結果
            if let resultData = result?.data as? [String: Any],
               let userProfileDict = resultData["userProfile"] as? [String: Any] {
                do {
                    // 將字典轉換為 Data，然後解碼為 UserProfile
                    let jsonData = try JSONSerialization.data(withJSONObject: userProfileDict, options: [])
                    let decoder = JSONDecoder()
                    let newProfile = try decoder.decode(UserProfile.self, from: jsonData)

                    // 因為 `@DocumentID` 只有在 Firestore SDK 讀取時才會自動填充
                    // 我們需要手動設置 id 為 authUser.uid
                    var profileWithId = newProfile
                    profileWithId.id = authUser.uid

                    print("UPS | Cloud Function createInitialUserProfile 成功，App UserID: \(profileWithId.userId)。")
                    DispatchQueue.main.async {
                        self.currentUserProfile = profileWithId
                        self.isLoading = false
                        // 開始監聽此用戶 Profile 在 Firestore 中的後續變化。
                        self.listenForUserProfileChanges(uid: authUser.uid)
                    }
                    completion(.success(profileWithId))
                } catch {
                    print("UPS | 從 Cloud Function 返回的 Profile 數據解碼失敗: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.serviceError = .decodingError(underlyingError: error)
                    }
                    completion(.failure(.decodingError(underlyingError: error)))
                }
            } else {
                print("UPS | Cloud Function createInitialUserProfile 返回數據格式不正確或為 nil。")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.serviceError = .unexpectedTransactionResult
                }
                completion(.failure(.unexpectedTransactionResult))
            }
        }
    }
    
    /// 修改上次登入日期
    func callCloudFunctionToUpdateUserLastLoginDate(uid: String, completion: ((UserProfileServiceError?) -> Void)? = nil) {
            guard !uid.isEmpty else {
                print("UPS | 更新最後登入時間錯誤：UID 為空。")
                completion?(.generalError(message: "用戶 UID 無效，無法更新登入時間。"))
                return
            }
            print("UPS | 呼叫 Cloud Function updateUserLastLoginDate 更新最後登入時間，UID: \(uid)。")

            // Callable Function 不需要傳遞 UID，因為 context.auth.uid 會提供
            // 但為了呼叫範例的清晰性，你可以傳遞一個空字典或僅傳遞與用戶無關的數據
            // functions.httpsCallable("updateUserLastLoginDate").call([:]) 也可以
        functions.httpsCallable("updateUserLastLoginDate").call([:]) { result, error in // <-- 傳遞一個空字典或無關緊要的數據
                if let callableError = error as NSError? {
                    print("UPS | Cloud Function updateUserLastLoginDate 呼叫失敗: \(callableError.localizedDescription)")
                    completion?(.generalError(message: callableError.localizedDescription))
                    return
                }
                print("UPS | Cloud Function updateUserLastLoginDate 成功。")
                // Cloud Function 會在 Firestore 中更新時間戳，監聽器會自動同步到本地 currentUserProfile
                completion?(nil)
            }
        }
    
    /// 刪除帳號
    /// 此方法只負責呼叫後端，成功後，登出等清理操作應由 AuthManager 觸發。
    /// - Parameter completion: 操作完成後的回調。成功時返回 true，失敗時返回 false 和錯誤。
    func deleteUserAccount(completion: @escaping (Bool, UserProfileServiceError?) -> Void) {
        print("UPS | 呼叫 Cloud Function 'deleteUserAccount'...")
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.serviceError = nil
        }
        
        functions.httpsCallable("deleteUserAccount").call { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let callableError = error {
                // 後端返回錯誤
                print("UPS | Cloud Function 'deleteUserAccount' 呼叫失敗: \(callableError.localizedDescription)")
                
                // 將後端錯誤包裝成我們自己的錯誤類型
                let deletionError = UserProfileServiceError.accountDeletionFailed(underlyingError: callableError)
                
                DispatchQueue.main.async {
                    self.serviceError = deletionError
                }
                
                // 回傳失敗
                completion(false, deletionError)
                return
            }
            
            // 後端成功執行
            print("UPS | Cloud Function 'deleteUserAccount' 成功返回。")
            // 回傳成功
            completion(true, nil)
        }
    }
    
    /// 直接從 Firestore 獲取指定用戶的 Profile 數據，並更新本地緩存。
    /// 此方法通常用於需要一次性獲取 Profile數據，而不涉及創建或持續監聽的場景。
    ///
    /// - Parameters:
    ///   - uid: 要獲取 Profile 的用戶的 Firebase Auth UID。
    ///   - completion: 操作完成後的回調。
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, UserProfileServiceError>) -> Void) {
        guard !uid.isEmpty else {
            print("UPS | 獲取 Profile 錯誤：UID 為空。")
            completion(.failure(.generalError(message: "用戶 UID 無效，無法獲取 Profile。")))
            return
        }
        print("UPS | 開始一次性獲取 Profile，UID: \(uid)。")
        DispatchQueue.main.async {
            self.isLoading = true
            self.serviceError = nil
        }
        let userProfileRef = db.collection("users").document(uid)

        userProfileRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false // 無論成功或失敗，加載狀態都結束
            }

            if let firestoreError = error {
                print("UPS | 一次性獲取 Profile 失敗，UID: \(uid)。錯誤: \(firestoreError.localizedDescription)")
                DispatchQueue.main.async { self.serviceError = .firestoreError(underlyingError: firestoreError) }
                completion(.failure(.firestoreError(underlyingError: firestoreError)))
                return
            }

            guard let document = document, document.exists else {
                // 如果文檔不存在
                print("UPS | 一次性獲取 Profile 時未找到文檔，UID: \(uid)。")
                DispatchQueue.main.async { self.serviceError = .profileNotFound }
                completion(.failure(.profileNotFound))
                return
            }

            // 文檔存在，嘗試解碼
            do {
                let profile = try document.data(as: UserProfile.self)
                print("UPS | 一次性獲取 Profile 成功並解碼，UID: \(uid)。App UserID: \(profile.userId)")
                DispatchQueue.main.async {
                    self.currentUserProfile = profile // 更新本地緩存
                }
                completion(.success(profile))
            } catch let decodingError {
                print("UPS | 一次性獲取 Profile 時解碼失敗，UID: \(uid)。錯誤: \(decodingError.localizedDescription)")
                DispatchQueue.main.async { self.serviceError = .decodingError(underlyingError: decodingError) }
                completion(.failure(.decodingError(underlyingError: decodingError)))
            }
        }
    }
    
    /// 開始實時監聽指定用戶 Profile 文檔在 Firestore 中的變化。
    /// 當 Firestore 中的數據發生更改時，此監聽器會被觸發，並用最新的數據更新本地的 `currentUserProfile`。
    /// 此方法應在用戶成功登入並確定其 UID 後調用。
    /// 如果之前已有監聽器，會先移除舊的再創建新的。
    ///
    /// - Parameter uid: 要監聽的用戶的 Firebase Auth UID。
    func listenForUserProfileChanges(uid: String) {
        guard !uid.isEmpty else {
            print("UPS | 啟動 Profile 監聽器錯誤：UID 為空。")
            return
        }
        // 如果已有針對其他用戶或同一用戶的監聽器，先移除它。
        if userProfileListener != nil {
            print("UPS | 檢測到已存在的 Profile 監聽器，將先移除。")
            stopListeningForUserProfileChanges()
        }
        
        let userProfileRef = db.collection("users").document(uid)
        print("UPS | 開始為 UID: \(uid) 註冊 Profile 實時監聽器。")
        
        // 添加快照監聽器。
        // 每當文檔數據發生變化（包括初始獲取）時，閉包都會被調用。
        userProfileListener = userProfileRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            // 確保 UI 更新和 @Published 屬性修改在主線程。
            DispatchQueue.main.async {
                // 處理監聽器本身可能返回的錯誤。
                if let listenerError = error {
                    print("UPS | Profile 監聽器返回錯誤，UID: \(uid)。錯誤: \(listenerError.localizedDescription)")
                    self.serviceError = .firestoreError(underlyingError: listenerError)
                    // 根據業務需求，監聽失敗時可能需要清除本地 Profile 或設置特定的加載/錯誤狀態。
                    // 例如，如果無法持續監聽，可能表示用戶的數據已不可靠。
                    self.currentUserProfile = nil // 清除可能過時的數據
                    self.isLoading = false        // 標記加載/監聽流程結束（雖然是錯誤的結束）
                    return
                }
                
                guard let document = documentSnapshot else {
                    // 極少數情況下，documentSnapshot 可能為 nil 而沒有錯誤，這通常不應發生。
                    print("UPS | Profile 監聽器返回空的 documentSnapshot 且無錯誤，UID: \(uid)。")
                    self.serviceError = .profileNotFound // 或一個更特定的 "監聽器返回無效數據" 錯誤
                    self.currentUserProfile = nil
                    return
                }
                
                // 檢查文檔是否存在。
                if document.exists {
                    // 文檔存在，嘗試解碼。
                    do {
                        let updatedProfile = try document.data(as: UserProfile.self)
                        self.currentUserProfile = updatedProfile
                        self.serviceError = nil // 成功獲取/更新數據，清除之前的錯誤。
                        print("UPS | Profile 監聽器更新數據，UID: \(uid)。App UserID: \(updatedProfile.userId)，金幣: \(updatedProfile.coins)")
                    } catch let decodingError {
                        print("UPS | Profile 監聽器解碼更新數據失敗，UID: \(uid)。錯誤: \(decodingError.localizedDescription)")
                        self.serviceError = .decodingError(underlyingError: decodingError)
                        // 解碼失敗時，也可以考慮是否清除 currentUserProfile，防止顯示損壞數據。
                        // self.currentUserProfile = nil
                    }
                } else {
                    // 文檔不存在 (可能已被刪除)。
                    print("UPS | Profile 監聽器檢測到文檔不存在或已被刪除，UID: \(uid)。")
                    self.currentUserProfile = nil // 清除本地 Profile 數據
                    self.serviceError = .profileNotFound // 標記 Profile 不存在
                }
            }
        }
    }
    
    /// 停止當前正在活動的用戶 Profile 實時監聽器。
    /// 此方法應在不再需要監聽時調用，例如用戶登出時，或 `UserProfileService` 實例被銷毀前。
    func stopListeningForUserProfileChanges() {
        if let listener = userProfileListener {
            print("UPS | 正在移除 Profile 實時監聽器。")
            listener.remove()
            self.userProfileListener = nil // 清除句柄
        } else {
            print("UPS | 沒有活動的 Profile 監聽器需要移除。")
        }
    }
    
    /// 清理本地存儲的用戶 Profile 相關數據，並停止任何活動的監聽器。
    /// 此方法通常在用戶登出時由 `AuthManager` 調用。
    func clearLocalUserProfile() {
        print("UPS | 開始清理本地用戶 Profile 數據並停止監聽器。")
        stopListeningForUserProfileChanges() // 確保監聽器被正確移除。
        DispatchQueue.main.async {
            self.currentUserProfile = nil // 清除本地緩存的 Profile。
            self.serviceError = nil       // 清除任何相關的錯誤信息。
            self.isLoading = false        // 重置加載狀態。
            print("UPS | 本地用戶 Profile 數據已清理。")
        }
    }
    
    /// `UserProfileService` 的反初始化方法。
    /// 確保在服務實例被銷毀時，移除任何活動的 Firestore 監聽器，以防止記憶體洩漏。
    deinit {
        print("UPS | 反初始化 (deinit) 開始，將移除監聽器 (如果存在)。")
        stopListeningForUserProfileChanges()
    }
    
    // MARK: - 硬幣相關
    /// 修改硬幣相關（要修改的額）
    /// 用於確認硬幣修改，若為 0 表示不用修改
    @Published var pendingModifyCoinNumber: Int = 0
    @Published var pendingModifyCoinType: CoinModView.CoinModViewType = .restore
    
    /// 修改硬幣（安全，外部）
    func setPendingCoins(amount: Int) {
        print("UPS | 準備將待處理金幣數量 \(amount) 存入 Keychain...")
                
        // 1. 將整數轉換為 Data
        guard let data = String(amount).data(using: .utf8) else {
            print("UPS | 錯誤：無法將數字 \(amount) 轉換為 Data。")
            return
        }
        
        // 2. 使用 KeychainHelper 儲存
        let saveSuccess = KeychainHelper.save(data: data, forKey: "keychain.pendingModifyCoinNumber")
        
        if saveSuccess {
            print("UPS | 成功將 \(amount) 存入 Keychain。")
            loadPendingCoins()
        } else {
            print("UPS | 嚴重錯誤：無法將待處理金幣存入 Keychain！")
        }
    }
    
    private func loadPendingCoins() {
        print("UPS | 正在從 Keychain 加載待處理金幣...")
        
        // 1. 使用 KeychainHelper 讀取
        guard let data = KeychainHelper.load(forKey: "keychain.pendingModifyCoinNumber") else {
            print("UPS | Keychain 中沒有找到待處理金幣的記錄。")
            // 確保本地狀態也是乾淨的
            DispatchQueue.main.async {
                self.pendingModifyCoinNumber = 0
            }
            return
        }
        
        // 2. 將 Data 轉換回整數
        if let amountString = String(data: data, encoding: .utf8),
           let amount = Int(amountString) {
            print("UPS | 從 Keychain 加載到 \(amount) 枚待處理金幣。")
            // 3. 更新到 @Published 變數，觸發 UI 更新
            DispatchQueue.main.async {
                self.pendingModifyCoinNumber = amount
            }
        } else {
            print("UPS | 錯誤：從 Keychain 讀取的數據格式不正確。")
            DispatchQueue.main.async {
                self.pendingModifyCoinNumber = 0
            }
        }
    }
    
    /// 領取待處理的金幣。
    /// - Parameters:
    ///   - uid: 當前用戶的 Firebase Auth UID。
    ///   - completion: 操作完成後的回調。成功時 error 為 nil，失敗時為相應的 UserProfileServiceError。
    func claimPendingCoins(for uid: String, completion: @escaping (UserProfileServiceError?) -> Void) {
        
        guard !isLoading else {
            print("UPS | 警告: 上一次領取操作仍在進行中，已忽略重複的請求。")
            completion(.generalError(message: "操作繁忙"))
            return
        }
        
        // 確保 isLoading 狀態被正確管理，UI 可以顯示進度指示器
        DispatchQueue.main.async {
            self.isLoading = true
            self.serviceError = nil
        }
        
        // 先從 Keychain 讀取最新的待處理數量
        loadPendingCoins()
        let amountToClaim = pendingModifyCoinNumber
        
        guard amountToClaim > 0 else {
            print("UPS | 沒有待處理的金幣可以領取。")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            // 雖然不是錯誤，但可以回調 nil 表示操作結束且無錯誤
            completion(nil)
            return
        }
        
        // 呼叫後端發放金幣
        callCloudFunctionToUpdateUserCoins(uid: uid, amount: amountToClaim) { [weak self] error in
            guard let self = self else {
                completion(.generalError(message: "Service instance was deallocated."))
                return
            }

            // 無論成功或失敗，都結束加載狀態
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                // 1. 發放失敗，pendingCoins 保持不變，等待下次重試
                print("UPS | 領取金幣失敗：\(error.localizedDescription)。待處理金幣將保留。")
                
                // 將錯誤設定到 serviceError 以便全域觀察
                DispatchQueue.main.async {
                    self.serviceError = error
                }
                
                // 透過 completion 回調將錯誤傳遞出去
                completion(error)
                return
            }

            // 2. 發放成功！立即清除 Keychain 中的記錄
            print("UPS | 後端成功發放 \(amountToClaim) 枚金幣。正在清除本地待處理記錄...")
            
            // 使用 setPendingCoins(amount: 0) 來清除記錄（留給ＶＩＥＷ處理）
            
            print("UPS | 領取流程成功完成。")
            // 透過 completion 回調 nil 表示成功
            completion(nil)
        }
    }
    
    /// 修改硬幣（內部）
    private func callCloudFunctionToUpdateUserCoins(uid: String, amount: Int, completion: @escaping (UserProfileServiceError?) -> Void) {
        guard !uid.isEmpty else {
            print("UPS | 更新金幣錯誤：UID 為空。")
            completion(.generalError(message: "用戶 UID 無效，無法更新金幣。"))
            return
        }
        // 客戶端做初步驗證，例如不允許零變動，最終業務邏輯在 Cloud Function 中
        if amount == 0 {
            print("UPS | 金幣變動量為零，無需更新。")
            completion(nil)
            return
        }

        print("UPS | 呼叫 Cloud Function updateUserCoins 更新金幣，UID: \(uid)，變動量: \(amount)。")
        let data = ["amount": amount] // 傳遞變動量

        functions.httpsCallable("updateUserCoins").call(data) { [weak self] result, error in
            guard let self = self else { return }

            if let callableError = error as NSError? {
                print("UPS | Cloud Function updateUserCoins 呼叫失敗: \(callableError.localizedDescription)")
                DispatchQueue.main.async {
                    self.serviceError = .generalError(message: callableError.localizedDescription)
                }
                completion(.generalError(message: callableError.localizedDescription))
                return
            }

            // Cloud Function 成功返回
            if let resultData = result?.data as? [String: Any], let finalCoins = resultData["newCoins"] as? Int {
                print("UPS | Cloud Function updateUserCoins 成功，新金幣總數: \(finalCoins)。")
                // 監聽器會自動同步更新 currentUserProfile，這裡確保回調成功
                DispatchQueue.main.async {
                    if self.currentUserProfile?.id == uid {
                        self.currentUserProfile?.coins = finalCoins
                        print("UPS | 本地 currentUserProfile 的金幣已同步。")
                    }
                }
                completion(nil)
            } else {
                print("UPS | Cloud Function updateUserCoins 返回數據格式不正確或為 nil。")
                completion(.unexpectedTransactionResult)
            }
        }
    }
    
    
}
