//
//  UINavigationController+.swift
//  AInterviewMock
//
//  Created by 黃宥琦 on 2025/6/16.
//

import UIKit

// 自訂 NavigationStack 保留返回手勢

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
