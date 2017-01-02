//
//  BaseViewController.swift
//  Sexify
//
//  Created by Honghao Zhang on 2016-06-12.
//  Copyright © 2016 Sexify. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, PresentationStyleable {
    
    func preferredPresentationStyle() -> PresentationStyle? {
        return nil
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {}
}

// MARK: - NavigationControllerWrapped
extension BaseViewController {
    func wrappedInNavigationController() -> BaseNavigationController {
        return BaseNavigationController(rootViewController: self)
    }
}

// MARK: - PresentationStyleable
extension BaseViewController {
    // Override this to return false to enable super.showViewController call
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIViewController.show(_:sender:)) {
            return false
        }
        return true
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        if let navigationController = navigationController, let preferredPresentationStyle = (vc as? PresentationStyleable)?.preferredPresentationStyle() {
            switch preferredPresentationStyle {
            case .embedded:
                navigationController.pushViewController(vc, animated: true)
            case .standalone:
                navigationController.present(vc, animated: true, completion: nil)
            }
        } else {
            super.show(vc, sender: sender)
        }
    }
}
