//
//  ContentView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/4.
//

import SwiftUI
import FirebaseAnalytics

struct ContentView: View {
    
    @ObservedObject var vm = ViewManager.shared
    
    var body: some View {
        ZStack{
            vm.viewStack.last!
                .id(vm.viewStack.count)
                .transition(
                    vm.leaving ?
                        .asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ) :
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .scale(scale: 0.85, anchor: .center).combined(with: .opacity)
                        )
                 )
        }
    }
}

#Preview {
    ContentView()
}
