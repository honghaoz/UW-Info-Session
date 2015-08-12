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
    
    // MARK: - Split View Controller
    private lazy var _splitViewController: UISplitViewController = {
        var splitController = UISplitViewController()
        return splitController
    }()
    class var splitViewController: UISplitViewController {
        return sharedInstance._splitViewController
    }
    
    // MARK: - List View Controller
    private lazy var _listNavigationController: UINavigationController = {
        var controller = UIViewController.viewControllerInStoryboard("Root", viewControllerName: "ListNavigationController") as! UINavigationController
        return controller
    }()
    
    class var listNavigationController: UINavigationController {
        return sharedInstance._listNavigationController
    }
    
    private lazy var _listViewController: ListViewController = {
        var controller = UIViewController.viewControllerInStoryboard("Root", viewControllerName: "ListViewController") as! ListViewController
        return controller
    }()
    
    class var listViewController: ListViewController {
        return sharedInstance._listViewController
    }
    
    // MARK: - Detail View Controller
    private lazy var _detailViewController: DetailViewController = {
        var controller = UIViewController.viewControllerInStoryboard("Root", viewControllerName: "DetailViewController") as! DetailViewController
        return controller
    }()
    
    class var detailViewController: DetailViewController {
        return sharedInstance._detailViewController
    }
}
