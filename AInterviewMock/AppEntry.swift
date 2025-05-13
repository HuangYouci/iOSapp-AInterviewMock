//
//  AInterviewMockApp.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics

@main
struct AInterviewMockApp: App {
    
    init() {
        #if DEBUG
        UserDefaults.standard.set(true, forKey: "FIRDebugEnabled")
        #endif
        FirebaseApp.configure()
        
        Analytics.logEvent("debug_app_launched", parameters: [
                    "launch_source": "app_init"
                ])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
