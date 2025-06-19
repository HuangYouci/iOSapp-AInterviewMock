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
    
    @StateObject var ups: UserProfileService
    @StateObject var am: AuthManager
    @StateObject var vm = ViewManager.shared
    @StateObject var co = CoinManager.shared
    @StateObject var uc = UpdateChecker.shared
    @StateObject var iap: IAPManager
    
    init() {
        // MARK: - Firebase Cofigure
        FirebaseApp.configure()
        Analytics.logEvent("debug_app_launched", parameters: [
                    "launch_source": "app_init"
                ])
        
        // MARK: - Init
        let ups = UserProfileService()
        _ups = StateObject(wrappedValue: ups)
        _am = StateObject(wrappedValue: AuthManager(userProfileService: ups))
        _iap = StateObject(wrappedValue: IAPManager(userProfileService: ups))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(am)
                .environmentObject(ups)
                .environmentObject(vm)
                .environmentObject(co)
                .environmentObject(uc)
                .environmentObject(iap)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
