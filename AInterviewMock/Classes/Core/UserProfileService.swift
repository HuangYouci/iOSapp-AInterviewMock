//
//  UserProfileService.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/8.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - UserProfileServiceError (頂層錯誤枚舉)
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

    // MARK: Identifiable Conformance
    /// 為 SwiftUI 的 `Alert(item: ...)` 提供一個穩定的 ID。
    /// 使用錯誤的本地化描述作為 ID。注意：如果本地化描述可能不唯一或頻繁變化，
    /// 可能需要為每個 case 提供一個固定的字符串 ID。
    var id: String { self.localizedDescription }

    // MARK: LocalizedError Conformance
    /// 提供一個用戶友好的錯誤描述，用於向用戶顯示錯誤信息。
    var errorDescription: String? {
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

    /// Firestore 數據庫的實例，用於所有 Firestore 操作。
    private let db = Firestore.firestore()
    /// 用於實時監聽當前用戶 Profile 文檔變化的 Firestore 監聽器註冊對象。
    /// 當不再需要監聽時（例如用戶登出或服務被銷毀），需要調用其 `remove()` 方法來移除監聽器。
    private var userProfileListener: ListenerRegistration?

    // MARK: - @Published 公開屬性 (Published Properties for SwiftUI)

    /// 當前已登入用戶的 `UserProfile` 數據的本地緩存。
    /// 當用戶登入並成功加載 Profile 後，此屬性會被填充。
    /// 當 Profile 數據通過實時監聽器更新，或通過本地操作更新後，此屬性也會更新。
    /// SwiftUI 視圖可以觀察此屬性以顯示用戶相關信息。如果沒有用戶登入或 Profile 未加載，則為 `nil`。
    @Published var currentUserProfile: UserProfile?

    /// 一個布爾值，指示當前是否有與用戶 Profile 相關的異步操作正在進行中
    /// (例如，從 Firestore 獲取數據、創建 Profile 的事務操作)。
    /// `true` 表示正在加載，`false` 表示操作完成或空閒。
    @Published var isLoading: Bool = false

    /// 保存最近一次用戶 Profile 操作中發生的錯誤。
    /// 使用在文件頂部定義的 `UserProfileServiceError` 枚舉類型。
    /// 如果操作成功或沒有錯誤，此值為 `nil`。
    @Published var serviceError: UserProfileServiceError?

    // MARK: - 初始化 (Initialization)
    /// `UserProfileService` 的初始化方法。
    init() {
        print("UserProfileService | 初始化完成。")
    }

    // MARK: - 核心 Profile 管理 (Core Profile Management)

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
    func checkAndCreateUserProfile(for authUser: User, completion: @escaping (Result<UserProfile, UserProfileServiceError>) -> Void) {
        print("UserProfileService | 開始檢查或創建 Profile，針對 Auth UID: \(authUser.uid)")
        DispatchQueue.main.async {
            self.isLoading = true
            self.serviceError = nil // 清除之前的錯誤
        }

        let userProfileRef = db.collection("users").document(authUser.uid)

        // 嘗試從 Firestore 獲取用戶 Profile 文檔。
        userProfileRef.getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self else {
                print("UserProfileService | checkAndCreateUserProfile - self (UserProfileService) 已被釋放，提前返回。")
                // 如果 self 為 nil，通常無法調用 completion，因為它可能也捕獲了 self。
                // 這裡可以考慮是否需要一個 default 的 completion 調用，但通常意味著流程已中斷。
                return
            }

            // 處理 Firestore getDocument 操作返回的錯誤。
            if let firestoreError = error {
                print("UserProfileService | 獲取 Profile 文檔時發生 Firestore 錯誤，UID: \(authUser.uid)。錯誤: \(firestoreError.localizedDescription)")
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
                print("UserProfileService | Profile 文檔已存在，UID: \(authUser.uid)。正在嘗試解碼...")
                do {
                    let profile = try document.data(as: UserProfile.self)
                    print("UserProfileService | Profile 解碼成功。App UserID: \(profile.userId)，Auth UID: \(authUser.uid)")
                    DispatchQueue.main.async {
                        self.currentUserProfile = profile
                        self.isLoading = false
                        // Profile 獲取成功後，更新該用戶的最後登入時間。
                        self.updateUserLastLoginDate(uid: authUser.uid) { updateError in
                            if let error = updateError {
                                // 更新最後登入時間失敗是一個非關鍵錯誤，通常只記錄日誌，不阻塞主流程。
                                print("UserProfileService | 更新用戶最後登入時間失敗 (在獲取 Profile 後)，UID: \(authUser.uid)。錯誤: \(error.localizedDescription)")
                            }
                        }
                    }
                    completion(.success(profile))
                } catch let decodingError {
                    // 解碼失敗。
                    print("UserProfileService | 解碼現有 Profile 時發生錯誤，UID: \(authUser.uid)。錯誤: \(decodingError.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.serviceError = .decodingError(underlyingError: decodingError)
                    }
                    completion(.failure(.decodingError(underlyingError: decodingError)))
                }
            } else {
                // Profile 文檔不存在，需要創建新的 Profile。
                print("UserProfileService | Profile 文檔不存在，UID: \(authUser.uid)。將調用 createNewUserProfile。")
                self.createNewUserProfile(for: authUser, completion: completion)
            }
        }
    }

    /// 創建一個新的用戶 Profile 文檔到 Firestore 中。
    /// 此方法使用 Firestore 事務 (transaction) 來確保原子性操作：
    /// 1. 從 `counters/userCounter` 文檔讀取下一個可用的應用程式級別 `userId`。
    /// 2. 更新 `counters/userCounter` 文檔中的 `nextUserId` 為下一個值。
    /// 3. 使用獲取到的 `userId` 和其他初始值創建新的 `UserProfile` 文檔，文檔 ID 為 `authUser.uid`。
    /// 這些操作要么全部成功，要么全部失敗回滾。
    ///
    /// - Parameters:
    ///   - authUser: 新註冊或首次需要 Profile 的 Firebase `User` 對象。
    ///   - completion: 操作完成後的回調。
    private func createNewUserProfile(for authUser: User, completion: @escaping (Result<UserProfile, UserProfileServiceError>) -> Void) {
        print("UserProfileService | 開始創建新 Profile，針對 Auth UID: \(authUser.uid)")
        // 計數器文檔和新用戶 Profile 文檔的引用。
        let counterRef = db.collection("counters").document("userCounter")
        let userProfileRef = db.collection("users").document(authUser.uid)

        // 執行 Firestore 事務。
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 步驟 1: 在事務中讀取計數器文檔。
            let counterDocument: DocumentSnapshot
            do {
                print("UserProfileService | 事務內部：嘗試獲取計數器文檔 (\(counterRef.path))。")
                try counterDocument = transaction.getDocument(counterRef)
            } catch let fetchError as NSError {
                // 如果讀取計數器失敗，則設置錯誤指針並返回 nil，事務將失敗。
                print("UserProfileService | 事務內部：獲取計數器文檔失敗。錯誤: \(fetchError.localizedDescription)")
                errorPointer?.pointee = fetchError // 將錯誤傳遞給事務處理器
                // 返回 nil 表示此事務塊內的原子操作失敗。
                // 最終的 completion 將收到 .counterTransactionFailed 或 .profileCreationTransactionFailed
                return nil
            }

            // 步驟 2: 確定新的應用程式級別 userId。
            // 如果計數器文檔或 "nextUserId" 字段不存在，則將當前用戶的 userId 設為 1 (作為第一個用戶)。
            let currentCount = counterDocument.data()?["nextUserId"] as? Int ?? 1
            let newAppUserId = currentCount
            print("UserProfileService | 事務內部：確定新的 App UserID 為 \(newAppUserId)。")

            // 步驟 3: 準備新的 UserProfile 對象數據。
            // @DocumentID (`id` 字段) 會在從 Firestore 讀取時被自動填充為文檔 ID (即 authUser.uid)。
            // 在這裡創建 UserProfile 實例時，我們不需要手動設置 `id`。
            let newUserProfile = UserProfile(
                userId: newAppUserId, // 應用程式級別的自增 ID
                coins: 0,             // 初始金幣數量
                creationDate: Timestamp(date: Date()), // 創建時間戳
                updateDate: Timestamp(date: Date()),   // 初始更新時間戳
                lastloginDate: Timestamp(date: Date()) // 初始最後登入時間戳
            )

            // 步驟 4: 在事務中更新計數器文檔。
            // 將 "nextUserId" 字段的值設置為 newAppUserId + 1。
            // `merge: true` 選項確保如果 `userCounter` 文檔中還有其他字段，它們不會被覆蓋。
            // 如果 `userCounter` 文檔不存在，`setData` 會創建它。
            print("UserProfileService | 事務內部：更新計數器文檔 (\(counterRef.path)) 的 nextUserId 為 \(newAppUserId + 1)。")
            transaction.setData(["nextUserId": newAppUserId + 1], forDocument: counterRef, merge: true)

            // 步驟 5: 在事務中創建新的用戶 Profile 文檔。
            // 使用 `setData(from: ...)` 可以直接將 `Codable` 的 `UserProfile` 對象寫入 Firestore。
            do {
                print("UserProfileService | 事務內部：創建新的用戶 Profile 文檔 (\(userProfileRef.path))。")
                try transaction.setData(from: newUserProfile, forDocument: userProfileRef)
            } catch let encodeError {
                // 如果將 UserProfile 對象編碼到 Firestore 數據時失敗。
                print("UserProfileService | 事務內部：設置 UserProfile 數據失敗。錯誤: \(encodeError.localizedDescription)")
                errorPointer?.pointee = encodeError as NSError // 轉換為 NSError
                return nil
            }
            
            // 如果事務內的所有操作都準備成功，返回創建的 UserProfile 對象。
            // Firestore 會嘗試提交這些更改。
            // 我們手動為返回的 UserProfile 實例的 id 賦值，使其包含文檔 ID (Auth UID)，
            // 這樣在事務成功的回調中，可以直接使用這個帶有 ID 的 Profile 對象。
            var profileWithId = newUserProfile
            profileWithId.id = authUser.uid // 確保返回的 Profile 實例包含 Firestore Document ID
            print("UserProfileService | 事務內部：所有操作準備就緒，將返回 Profile。")
            return profileWithId

        }) { [weak self] (object, error) in
            // Firestore 事務的完成回調。
            // `object` 是事務閉包返回的值 (如果成功)。
            // `error` 是事務提交過程中發生的錯誤 (如果失敗)。
            guard let self = self else {
                print("UserProfileService | createNewUserProfile 事務回調 - self (UserProfileService) 已被釋放。")
                return
            }

            if let transactionError = error {
                // 事務失敗。
                print("UserProfileService | 創建新 Profile 的事務提交失敗，Auth UID: \(authUser.uid)。錯誤: \(transactionError.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // 這裡的錯誤可能是因為內部讀取計數器失敗 (被 errorPointer 捕獲)
                    // 或因為提交時的併發衝突等。
                    // 根據 errorPointer?.pointee 的原始錯誤類型，可以更細化是 counterTransactionFailed 還是 profileCreation本身。
                    // 為簡化，如果事務失敗，我們認為是 Profile 創建流程的一部分失敗。
                    self.serviceError = .profileCreationTransactionFailed(underlyingError: transactionError)
                }
                completion(.failure(.profileCreationTransactionFailed(underlyingError: transactionError)))
                return
            }

            // 事務成功，並且返回了預期的 UserProfile 對象。
            if let createdProfile = object as? UserProfile {
                print("UserProfileService | 新 Profile 事務成功提交並創建，Auth UID: \(authUser.uid)，App UserID: \(createdProfile.userId)。")
                DispatchQueue.main.async {
                    self.currentUserProfile = createdProfile
                    self.isLoading = false
                }
                completion(.success(createdProfile))
            } else {
                // 事務成功，但返回的對象不是 UserProfile 或為 nil，這是一個意外情況。
                print("UserProfileService | 新 Profile 事務成功，但返回的對象類型不正確或為 nil，Auth UID: \(authUser.uid)。")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.serviceError = .unexpectedTransactionResult
                }
                completion(.failure(.unexpectedTransactionResult))
            }
        }
    }
    
    // MARK: - Profile 更新 (Profile Updates)

    /// 更新指定用戶的最後登入時間 (`lastloginDate`) 和總體更新時間 (`updateDate`) 到 Firestore。
    /// 這通常在用戶成功登入並加載 Profile 後調用。
    ///
    /// - Parameters:
    ///   - uid: 要更新的用戶的 Firebase Auth UID。
    ///   - completion: (可選) 操作完成後的回調，如果發生錯誤則包含錯誤。
    func updateUserLastLoginDate(uid: String, completion: ((UserProfileServiceError?) -> Void)? = nil) {
        guard !uid.isEmpty else {
            print("UserProfileService | 更新最後登入時間錯誤：UID 為空。")
            completion?(.generalError(message: "用戶 UID 無效，無法更新登入時間。"))
            return
        }
        print("UserProfileService | 準備更新最後登入時間，UID: \(uid)。")
        let userProfileRef = db.collection("users").document(uid)
        let now = Timestamp(date: Date()) // 使用當前伺服器時間戳（由客戶端生成，但 Firestore 會處理）
        let updateData: [String: Any] = [
            "lastloginDate": now,
            "updateDate": now // 通常，更新最後登入時間也視為一次 Profile 的更新
        ]
        
        userProfileRef.updateData(updateData) { [weak self] error in
            guard let self = self else { return }
            if let firestoreError = error {
                print("UserProfileService | 更新最後登入時間失敗，UID: \(uid)。錯誤: \(firestoreError.localizedDescription)")
                completion?(.firestoreError(underlyingError: firestoreError))
            } else {
                print("UserProfileService | 成功更新最後登入時間，UID: \(uid)。")
                // 如果本地有該用戶的 Profile 緩存，也同步更新它。
                DispatchQueue.main.async {
                    if self.currentUserProfile?.id == uid {
                        self.currentUserProfile?.lastloginDate = now
                        self.currentUserProfile?.updateDate = now
                        print("UserProfileService | 本地 currentUserProfile 的登入/更新時間已同步。")
                    }
                }
                completion?(nil) // 成功時，錯誤為 nil
            }
        }
    }

    /// 更新指定用戶的金幣數量到 Firestore。
    /// **警告：直接從客戶端修改金幣等關鍵數據通常是不安全的。**
    /// 為了真正的安全性，應考慮使用 Firebase Cloud Functions 來處理此類操作。
    /// 此方法僅作為一個示例。
    ///
    /// - Parameters:
    ///   - uid: 要更新的用戶的 Firebase Auth UID。
    ///   - newCoinAmount: 新的金幣總數。
    ///   - completion: 操作完成後的回調，如果發生錯誤則包含錯誤。
    func updateUserCoins(uid: String, newCoinAmount: Int, completion: @escaping (UserProfileServiceError?) -> Void) {
        guard !uid.isEmpty else {
            print("UserProfileService | 更新金幣錯誤：UID 為空。")
            completion(.generalError(message: "用戶 UID 無效，無法更新金幣。"))
            return
        }
        // 應添加對 newCoinAmount 的基本驗證，例如 >= 0
        guard newCoinAmount >= 0 else {
            print("UserProfileService | 更新金幣錯誤：金幣數量不能為負。請求值: \(newCoinAmount)")
            completion(.generalError(message: "金幣數量不能設置為負數。"))
            return
        }

        print("UserProfileService | 準備更新金幣，UID: \(uid)，新金幣數量: \(newCoinAmount)。")
        let userProfileRef = db.collection("users").document(uid)
        let now = Timestamp(date: Date())
        let updateData: [String: Any] = [
            "coins": newCoinAmount,
            "updateDate": now // 每次重要數據更新時，都應更新 updateDate
        ]
        
        userProfileRef.updateData(updateData) { [weak self] error in
            guard let self = self else { return }
            if let firestoreError = error {
                print("UserProfileService | 更新金幣失敗，UID: \(uid)。錯誤: \(firestoreError.localizedDescription)")
                DispatchQueue.main.async {
                    self.serviceError = .firestoreError(underlyingError: firestoreError) // 更新全局錯誤狀態
                }
                completion(.firestoreError(underlyingError: firestoreError))
            } else {
                print("UserProfileService | 成功更新金幣，UID: \(uid)。")
                // 更新本地緩存
                DispatchQueue.main.async {
                    if self.currentUserProfile?.id == uid {
                        self.currentUserProfile?.coins = newCoinAmount
                        self.currentUserProfile?.updateDate = now
                        print("UserProfileService | 本地 currentUserProfile 的金幣/更新時間已同步。")
                    }
                }
                completion(nil) // 成功
            }
        }
    }

    // MARK: - Profile 獲取與監聽 (Profile Fetching and Listening)

    /// 直接從 Firestore 獲取指定用戶的 Profile 數據，並更新本地緩存。
    /// 此方法通常用於需要一次性獲取 Profile數據，而不涉及創建或持續監聽的場景。
    ///
    /// - Parameters:
    ///   - uid: 要獲取 Profile 的用戶的 Firebase Auth UID。
    ///   - completion: 操作完成後的回調。
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, UserProfileServiceError>) -> Void) {
        guard !uid.isEmpty else {
            print("UserProfileService | 獲取 Profile 錯誤：UID 為空。")
            completion(.failure(.generalError(message: "用戶 UID 無效，無法獲取 Profile。")))
            return
        }
        print("UserProfileService | 開始一次性獲取 Profile，UID: \(uid)。")
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
                print("UserProfileService | 一次性獲取 Profile 失敗，UID: \(uid)。錯誤: \(firestoreError.localizedDescription)")
                DispatchQueue.main.async { self.serviceError = .firestoreError(underlyingError: firestoreError) }
                completion(.failure(.firestoreError(underlyingError: firestoreError)))
                return
            }

            guard let document = document, document.exists else {
                // 如果文檔不存在
                print("UserProfileService | 一次性獲取 Profile 時未找到文檔，UID: \(uid)。")
                DispatchQueue.main.async { self.serviceError = .profileNotFound }
                completion(.failure(.profileNotFound))
                return
            }

            // 文檔存在，嘗試解碼
            do {
                let profile = try document.data(as: UserProfile.self)
                print("UserProfileService | 一次性獲取 Profile 成功並解碼，UID: \(uid)。App UserID: \(profile.userId)")
                DispatchQueue.main.async {
                    self.currentUserProfile = profile // 更新本地緩存
                }
                completion(.success(profile))
            } catch let decodingError {
                print("UserProfileService | 一次性獲取 Profile 時解碼失敗，UID: \(uid)。錯誤: \(decodingError.localizedDescription)")
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
            print("UserProfileService | 啟動 Profile 監聽器錯誤：UID 為空。")
            return
        }
        // 如果已有針對其他用戶或同一用戶的監聽器，先移除它。
        if userProfileListener != nil {
            print("UserProfileService | 檢測到已存在的 Profile 監聽器，將先移除。")
            stopListeningForUserProfileChanges()
        }
        
        let userProfileRef = db.collection("users").document(uid)
        print("UserProfileService | 開始為 UID: \(uid) 註冊 Profile 實時監聽器。")
        
        // 添加快照監聽器。
        // 每當文檔數據發生變化（包括初始獲取）時，閉包都會被調用。
        userProfileListener = userProfileRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            // 確保 UI 更新和 @Published 屬性修改在主線程。
            DispatchQueue.main.async {
                // 處理監聽器本身可能返回的錯誤。
                if let listenerError = error {
                    print("UserProfileService | Profile 監聽器返回錯誤，UID: \(uid)。錯誤: \(listenerError.localizedDescription)")
                    self.serviceError = .firestoreError(underlyingError: listenerError)
                    // 根據業務需求，監聽失敗時可能需要清除本地 Profile 或設置特定的加載/錯誤狀態。
                    // 例如，如果無法持續監聽，可能表示用戶的數據已不可靠。
                    self.currentUserProfile = nil // 清除可能過時的數據
                    self.isLoading = false        // 標記加載/監聽流程結束（雖然是錯誤的結束）
                    return
                }
                
                guard let document = documentSnapshot else {
                    // 極少數情況下，documentSnapshot 可能為 nil 而沒有錯誤，這通常不應發生。
                    print("UserProfileService | Profile 監聽器返回空的 documentSnapshot 且無錯誤，UID: \(uid)。")
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
                        print("UserProfileService | Profile 監聽器更新數據，UID: \(uid)。App UserID: \(updatedProfile.userId)，金幣: \(updatedProfile.coins)")
                    } catch let decodingError {
                        print("UserProfileService | Profile 監聽器解碼更新數據失敗，UID: \(uid)。錯誤: \(decodingError.localizedDescription)")
                        self.serviceError = .decodingError(underlyingError: decodingError)
                        // 解碼失敗時，也可以考慮是否清除 currentUserProfile，防止顯示損壞數據。
                        // self.currentUserProfile = nil
                    }
                } else {
                    // 文檔不存在 (可能已被刪除)。
                    print("UserProfileService | Profile 監聽器檢測到文檔不存在或已被刪除，UID: \(uid)。")
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
            print("UserProfileService | 正在移除 Profile 實時監聽器。")
            listener.remove()
            self.userProfileListener = nil // 清除句柄
        } else {
            print("UserProfileService | 沒有活動的 Profile 監聽器需要移除。")
        }
    }

    // MARK: - 本地數據清理 (Local Data Cleanup)

    /// 清理本地存儲的用戶 Profile 相關數據，並停止任何活動的監聽器。
    /// 此方法通常在用戶登出時由 `AuthManager` 調用。
    func clearLocalUserProfile() {
        print("UserProfileService | 開始清理本地用戶 Profile 數據並停止監聽器。")
        stopListeningForUserProfileChanges() // 確保監聽器被正確移除。
        DispatchQueue.main.async {
            self.currentUserProfile = nil // 清除本地緩存的 Profile。
            self.serviceError = nil       // 清除任何相關的錯誤信息。
            self.isLoading = false        // 重置加載狀態。
            print("UserProfileService | 本地用戶 Profile 數據已清理。")
        }
    }
    
    // MARK: - 反初始化 (Deinitialization)
    /// `UserProfileService` 的反初始化方法。
    /// 確保在服務實例被銷毀時，移除任何活動的 Firestore 監聽器，以防止記憶體洩漏。
    deinit {
        print("UserProfileService | 反初始化 (deinit) 開始，將移除監聽器 (如果存在)。")
        stopListeningForUserProfileChanges()
    }
}
