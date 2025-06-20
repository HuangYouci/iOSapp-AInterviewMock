//
//  LoadView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/17.
//

import SwiftUI

struct LoadView: View {
    
    @EnvironmentObject var vm: ViewManager
    
    @State private var loadedTimeSec: Int = 0
    @State private var timer: Timer?
    
    var loadingTitle: String = "載入中"
    var loadingDescription: String = "請保持網路連線。若等待許久未果，請嘗試重啟 app。"
    
    var body: some View {
        ZStack{
            VStack(spacing: 20){
                LoadViewElement()
                    .frame(width: 40, height: 40)
                VStack(spacing: 6){
                    Text(loadingTitle)
                        .font(.title3)
                        .bold()
                    Text(loadingDescription)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(Color(.white))
            .background(Color("AccentBackground"))
            
            VStack(spacing: 0){
                HStack{
                    Button{
                        vm.perviousPage()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .background(Color("AccentBackgroundP1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(width: loadedTimeSec > 10 ? 36 : 0) // 20 + padding(8)
                    .opacity(loadedTimeSec > 10 ? 1 : 0)
                    Text("inif")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.3), value: loadedTimeSec)
                .foregroundStyle(Color(.white))
                .padding(.horizontal)
                .padding(.vertical, 5)
                Spacer()
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            loadedTimeSec += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}

struct LoadViewElement: View {
    
    @State private var animationA: Bool = false
    @State private var animationB: Bool = false
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(Color("AccentColorR1"), lineWidth: 5)
            Circle()
                .trim(from: animationB ? 0.9 : 0.7, to: 1)
                .stroke(Color("AccentColorR3"), lineWidth: 5)
                .rotationEffect(Angle(degrees: animationA ? 360 : 0))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        animationA = true
                    }
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        animationB = true
                    }
                }
        }
    }
    
}

#Preview {
    LoadViewElement()
}

#Preview {
    LoadView()
        .environmentObject(ViewManager())
}
