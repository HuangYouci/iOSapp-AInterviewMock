//
//  FlowLayout.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/8.
//


import SwiftUI

struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat // 橫向間距
    var verticalSpacing: CGFloat   // 縱向間距
    
    // 初始化方法，預設間距為 10
    init(horizontalSpacing: CGFloat = 10, verticalSpacing: CGFloat = 10) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let layoutResult = computeLayout(sizes: sizes, containerWidth: proposal.width ?? 0)
        return CGSize(width: proposal.width ?? 0, height: layoutResult.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let layoutResult = computeLayout(sizes: sizes, containerWidth: bounds.width)
        let offsets = layoutResult.offsets
        
        for (index, subview) in subviews.enumerated() {
            let offset = offsets[index]
            subview.place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y),
                          proposal: .unspecified)
        }
    }
    
    private func computeLayout(sizes: [CGSize], containerWidth: CGFloat) -> (offsets: [CGPoint], height: CGFloat) {
        var offsets: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for size in sizes {
            // 如果當前行放不下，換行
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += currentRowHeight + verticalSpacing // 使用縱向間距
                currentRowHeight = 0
            }
            
            // 記錄當前子視圖的位置
            offsets.append(CGPoint(x: currentX, y: currentY))
            
            // 更新 X 座標和行高
            currentX += size.width + horizontalSpacing // 使用橫向間距
            currentRowHeight = max(currentRowHeight, size.height)
        }
        
        // 返回所有子視圖的偏移量和總高度
        return (offsets: offsets, height: currentY + currentRowHeight)
    }
}
