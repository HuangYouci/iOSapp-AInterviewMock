//
//  InterviewLiveActivity.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/7/5.
//

import ActivityKit
import WidgetKit
import SwiftUI

@main
struct InterviewLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: InterviewActivityAttributes.self) { context in
            InterviewLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack{
                        Image(systemName: "questionmark.bubble.fill")
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        Text("問題 \(context.state.currentQuestion + 1)")
                            .bold()
                    }
                    .padding(6)
                    .padding(.horizontal, 3)
                    .background(Color(.accentBackground))
                    .clipShape(Capsule())
                }
                DynamicIslandExpandedRegion(.trailing){
                    Text(String(format: "%02d:%02d", context.state.timer/60, context.state.timer%60))
                        .font(.title2)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .bold()
                }
                DynamicIslandExpandedRegion(.bottom){
                    Text("\(context.state.question)")
                        .padding(.horizontal, 10)
                }
                
            } compactLeading: {
                HStack{
                    Image(systemName: "questionmark.bubble.fill")
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("\(context.state.currentQuestion + 1)")
                        .bold()
                }
                .padding(6)
                .background(Color(.accentBackground))
                .clipShape(Capsule())
            } compactTrailing: {
                Text(String(format: "%02d:%02d", context.state.timer/60, context.state.timer%60))
                    .font(.title2)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .bold()
            } minimal: {
                Text("inif")
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(.accent))
                    .font(.footnote)
            }
//            .widgetURL(URL(string: "yourapp://interview")) // 點動態島打開App的URL Scheme
            .keylineTint(Color(.accent))
        }
    }
}

// MARK: - 鎖屏與通知中心畫面

struct InterviewLockScreenView: View {
    
    let context: ActivityViewContext<InterviewActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                Text("inif")
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(.white))
                    .font(.title3)
                Text("模擬面試")
                    .bold()
                Spacer()
                Text("第 \(context.state.currentQuestion + 1) 題 / 共 \(context.state.totalQuestions) 題")
                    .font(.footnote)
            }
            HStack(alignment: .center){
                Text("\(context.state.question)")
                Spacer()
                Text(String(format: "%02d:%02d", context.state.timer/60, context.state.timer%60))
                    .font(.title2)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .bold()
            }
        }
        .padding()
        .background(Color(.accentBackground))
    }
    
}
