//
//  AInterviewMockApp.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import GoogleSignIn

@main
struct AInterviewMockApp: App {
    
    @StateObject var userProfileService: UserProfileService
    @StateObject var authManager: AuthManager
    
    init() {
        // MARK: - Firebase Cofigure
        FirebaseApp.configure()
        Analytics.logEvent("debug_app_launched", parameters: [
                    "launch_source": "app_init"
                ])
        
        // MARK: - Init
        let ups = UserProfileService()
        _userProfileService = StateObject(wrappedValue: ups)
        _authManager = StateObject(wrappedValue: AuthManager(userProfileService: ups))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(userProfileService)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
