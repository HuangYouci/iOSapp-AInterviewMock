//
//  View+.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/23.
//

import SwiftUI

extension View {
    /// 通用方塊元件
    @ViewBuilder
    func inifBlock<S1: ShapeStyle, S2: ShapeStyle>(fgColor: S1 = .primary, bgColor: S2 = Color("AccentBackground")) -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .background(bgColor)
            .foregroundStyle(fgColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
