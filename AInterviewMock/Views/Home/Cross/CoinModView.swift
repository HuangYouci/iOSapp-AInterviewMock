//
//  CoinModView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/19.
//

import SwiftUI

struct CoinModView: View {
    
    @EnvironmentObject var vm: ViewManager
    
    let amountChanged: Int
    let finalAmount: Int
    
    @State private var time: Int = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack{
            HStack(spacing: 15){
                Image(systemName: "hockey.puck.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color("AppGold"))
                ZStack{
                    Text("\(amountChanged)")
                        .bold()
                        .opacity(time < 18 ? 1 : 0)
                    VStack(spacing: 0){
                        Text(beautyAmount(amount: finalAmount))
                            .bold()
                        Text("餘額")
                            .font(.caption)
                    }
                    .opacity(time < 20 ? 0 : 1)
                }
            }
            .lineLimit(1)
            .frame(width: time < 5 ? 50 : 100)
            .padding()
            .background(Color(.systemBackground).opacity(0.5))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .offset(y: ((time < 2)||(time > 45)) ? -150 : 0)
            Spacer()
        }
        .onAppear {
            time = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)){
                    time += 1
                }
                if (time > 50) {
                    timer?.invalidate()
                    vm.coinModNot = false
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func beautyAmount(amount: Int) -> String {
        if(amount > 1000000){
            return "\(amount/1000000).\((amount-((amount/1000000)*1000000))/100000)M"
        } else if (amount > 1000) {
            return "\(amount/1000).\((amount-((amount/1000)*1000))/100)K"
        } else {
            return "\(amount)"
        }
    }
}
