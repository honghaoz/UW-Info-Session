//
//  BaseNavigationController.swift
//  Sexify
//
//  Created by Honghao Zhang on 2016-06-18.
//  Copyright © 2016 Sexify. All rights reserved.
//

import UIKit
import ChouTi

class BaseNavigationController: UINavigationController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
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
