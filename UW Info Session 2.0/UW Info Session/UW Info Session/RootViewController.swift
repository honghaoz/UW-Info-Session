//
//  RootViewController.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-10.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class RootViewController: UIViewController {
    @IBOutlet weak var infoSessionsListBarItem: UITabBarItem!
    @IBOutlet weak var favoritesBarItem: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    
    lazy var mySplitViewController: UISplitViewController = {
        var splitController = Locator.splitViewController
        splitController.viewControllers = [self.listNavigationController, self.detailViewController]
        splitController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        splitController.delegate = self
        
        splitController.hidesBottomBarWhenPushed = true
        return splitController
    }()
    
    var listNavigationController: UINavigationController { return Locator.listNavigationController }
    var listViewController: ListViewController { return Locator.listViewController }
    
    var detailViewController: DetailViewController { return Locator.detailViewController }
    
    var tabBarSelectedIndex: Int = 0 {
        didSet {
            switch tabBarSelectedIndex {
            case 0:
                tabBar.selectedItem = infoSessionsListBarItem
            case 1:
                tabBar.selectedItem = favoritesBarItem
            default:
                break
            }
        }
    }
    
    var currentSelectedViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayContentViewController(mySplitViewController)
        tabBarSelectedIndex = 0
    }
    
    func displayContentViewController(viewController: UIViewController) {
        addChildViewController(viewController)
        currentSelectedViewController = viewController
        
        viewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.insertSubview(viewController.view, belowSubview: tabBar)
        
        // Full Size
        NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: viewController.view, attribute: .Top, multiplier: 1.0, constant: 0.0).active = true
        NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: viewController.view, attribute: .Leading, multiplier: 1.0, constant: 0.0).active = true
        NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: viewController.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0).active = true
        NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: viewController.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0).active = true
        
        viewController.didMoveToParentViewController(self)
    }
}

extension RootViewController: UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return true
    }
}
