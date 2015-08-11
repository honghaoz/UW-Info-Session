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
	
	// MARK: - Root View Controller
	private lazy var _rootViewController: RootViewController = {
		var controller = UIViewController.viewControllerInStoryboard("Root", viewControllerName: "RootViewController") as! RootViewController
		return controller
	}()
	class var rootViewController: RootViewController {
		return sharedInstance._rootViewController
	}
	
	// MARK: - List View Controller
	private lazy var _listViewController: ListViewController = {
		var controller = UIViewController.viewControllerInStoryboard("Root", viewControllerName: "ListViewController") as! ListViewController
		return controller
	}()
	
	class var listViewController: ListViewController {
		return sharedInstance._listViewController
	}
}
