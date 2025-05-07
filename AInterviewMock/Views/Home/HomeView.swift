//
//  HomeView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/7.
//

import SwiftUI

struct HomeView: View {
    
    @State private var currentPage = 0
    
    var body: some View {
        ZStack{
            VStack{
                switch(currentPage){
                case 0:
                    HomeEntryView()
                default:
                    Color.clear
                }
            }
            VStack{
                Spacer()
                HStack(spacing: 30){
                    barBuilder(page: 0, icon: "house")
                    barBuilder(page: 1, icon: "list.bullet")
                }
                .padding()
                .padding(.horizontal)
                .background(Color(.black).opacity(0.3))
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(radius: 5)
                .padding()
            }
        }
    }
    
    private func barBuilder(page: Int, icon: String) -> some View {
        VStack{
            Image(systemName: "\(icon)")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color(.white))
                .shadow(radius: 1)
            if (currentPage == page){
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(Color(.white))
                    .shadow(radius: 1)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)){
                currentPage = page
            }
        }
    }
}

#Preview {
    HomeView()
}
