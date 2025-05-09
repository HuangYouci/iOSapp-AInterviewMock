//
//  HomeListView.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/9.
//

import SwiftUI

struct HomeListView: View {
    
    @State private var profiles: [InterviewProfile] = []
    @State private var displayItem: InterviewProfile?
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                ForEach(profiles){ item in
                    VStack(alignment: .leading, spacing: 10){
                        HStack{
                            Text(item.templateName)
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        Text({
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd HH:mm"
                            return formatter.string(from: item.date)
                        }())
                        .padding(.top, 20)
                    }
                    .foregroundStyle(Color(.white))
                    .padding()
                    .background(
                        Image(systemName: "\(item.templateImage)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .offset(x: 160, y: 30)
                            .foregroundStyle(Color(.white))
                    )
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 52 / 255, green: 41 / 255, blue: 157 / 255),
                                Color(red: 108 / 255, green: 106 / 255, blue: 237 / 255)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .onTapGesture {
                        displayItem = item
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .onAppear {
            profiles = DataManager.shared.loadAllInterviewTypes()
        }
        .fullScreenCover(item: $displayItem) { item in
            
            HStack{
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text(NSLocalizedString("HomeListView_coinViewTitle", comment: "Title displayed at the top of the coin list screen"))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(.accent))
                Spacer()
                Button {
                    displayItem = nil
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            .background(Color(.systemBackground).opacity(0.3))
            .background(.ultraThinMaterial)
            
            InterviewAnalysisView(selected: .constant(item))
        }
        
    }
}

#Preview {
    HomeView()
}

#Preview{
    HomeListView()
}
