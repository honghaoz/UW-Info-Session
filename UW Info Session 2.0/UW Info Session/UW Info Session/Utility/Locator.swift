//
//  Locator.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-10.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class Locator {
	static let sharedInstance = Locator()
	
	private lazy var _rootViewController: RootViewController = {
		var controller = UIViewController.viewControllerInStoryboard("Root", viewControllerName: "RootViewController") as! RootViewController
		return controller
	}()
	class var rootViewController: RootViewController {
		return sharedInstance._rootViewController
	}
}
