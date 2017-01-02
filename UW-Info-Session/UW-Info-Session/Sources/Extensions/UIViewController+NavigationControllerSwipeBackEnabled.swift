//
//  UIViewController+NavigationControllerSwipeBackEnabled.swift
//  Sexify
//
//  Created by Honghao Zhang on 2016-06-19.
//  Copyright © 2016 Sexify. All rights reserved.
//

import UIKit

protocol NavigationControllerSwipeBackEnabled {
    /**
     Enable swipe back gesture for view controller in navigation controller
     */
    func enableSwipBackGesture()
}

extension UIViewController : NavigationControllerSwipeBackEnabled, UIGestureRecognizerDelegate {
    /**
     Enable swipe back gesture for view controller in navigation controller, this will enable edge swipe back gesture when `navigationController.setNavigationBarHidden` is called.
     */
    func enableSwipBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}
