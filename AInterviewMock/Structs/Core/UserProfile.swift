//
//  UserProfile.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/8.
//

import Firebase
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    // MARK: - Firebase Auto Variable
    @DocumentID var id: String?
    
    // MARK: - Core User Informaion
    let userId: Int
    var userEmail: String?
    var userName: String?
    
    // MARK: - App Data
    var coins: Int
    
    // MARK: - Data Info
    var creationDate: Timestamp
    var updateDate: Timestamp
    var lastloginDate: Timestamp
    
    // MARK: - init
    init(
        id: String? = nil,
        userId: Int,
        userEmail: String? = nil,
        userName: String? = nil,
        coins: Int = 0,
        creationDate: Timestamp = Timestamp(date: Date()),
        updateDate: Timestamp = Timestamp(date: Date()),
        lastloginDate: Timestamp = Timestamp(date: Date())
    ) {
        self.id = id
        self.userId = userId
        self.userEmail = userEmail
        self.userName = userName
        self.coins = coins
        self.creationDate = creationDate
        self.updateDate = updateDate
        self.lastloginDate = lastloginDate
    }
    
}
