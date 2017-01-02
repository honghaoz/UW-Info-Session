//
//  NavigationControllerWrapped.swift
//  Sexify
//
//  Created by Honghao Zhang on 2016-06-18.
//  Copyright © 2016 Sexify. All rights reserved.
//

import UIKit

protocol NavigationControllerWrapped {
    func wrappedInNavigationController() -> UINavigationController
}

extension UIViewController : NavigationControllerWrapped {}
extension NavigationControllerWrapped where Self: UIViewController {
    func wrappedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
