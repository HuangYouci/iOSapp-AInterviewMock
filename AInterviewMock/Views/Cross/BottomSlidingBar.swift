//
//  BottomSlidingBar.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/5/16.
//


import SwiftUI

struct BottomSlidingBar: View {
    @Binding var isVisible: Bool
    @Binding var currentSession: Int
    let maxHeight: CGFloat
    let content: any View
    let onNext: () -> Void
    let onPrevious: () -> Void
    let isNextEnabled: Bool
    let isPreviousEnabled: Bool
    let nextText: String
    let previousText: String

    @State private var barHeight: CGFloat = 0
    @State private var isBarDraging = false

    init(
        isVisible: Binding<Bool>,
        currentSession: Binding<Int>,
        maxHeight: CGFloat = 150,
        @ViewBuilder content: () -> any View,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        isNextEnabled: Bool,
        isPreviousEnabled: Bool,
        nextText: String,
        previousText: String
    ) {
        self._isVisible = isVisible
        self._currentSession = currentSession
        self.maxHeight = maxHeight
        self.content = content()
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.isNextEnabled = isNextEnabled
        self.isPreviousEnabled = isPreviousEnabled
        self.nextText = nextText
        self.previousText = previousText
        
        self.barHeight = maxHeight
    }

    var body: some View {
        if isVisible {
            VStack(spacing: 0) {
                VStack {
                    Capsule()
                        .fill(Color(.systemGray))
                        .frame(width: 40, height: 6)
                        .padding(8)
                        .opacity(isBarDraging ? 1 : 0.3)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    barHeight -= value.translation.height
                                    barHeight = max(barHeight, 0)
                                    barHeight = min(barHeight, maxHeight)
                                    isBarDraging = true
                                }
                                .onEnded { value in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if value.translation.height > 0 {
                                            barHeight = 0
                                        } else {
                                            barHeight = maxHeight
                                        }
                                        isBarDraging = false
                                    }
                                }
                        )

                    VStack {
                        AnyView(content)
                    }
                    .frame(height: barHeight)

                    HStack(spacing: 20) {
                        if isPreviousEnabled {
                            Button(action: onPrevious) {
                                Text(previousText)
                                    .font(.title3)
                            }
                            .foregroundStyle(Color(.systemGray))
                            .padding()
                        }

                        Button(action: onNext) {
                            HStack {
                                Text(nextText)
                                    .font(.title3)
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundStyle(isNextEnabled ? Color(.white) : Color(.systemGray))
                        .padding()
                        .background(isNextEnabled ? Color.accentColor : Color(.systemGray2))
                        .clipShape(Capsule())
                        .disabled(!isNextEnabled)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(maxHeight: .infinity, alignment: .bottom)

                Color.clear
                    .frame(height: 0)
                    .background(.ultraThinMaterial)
            }
            .transition(.move(edge: .bottom))
        }
    }
}
