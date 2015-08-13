//
//  RootViewController.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-10.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class RootViewController: BaseViewController {
    
    @IBOutlet weak var infoSessionsListBarItem: UITabBarItem!
    @IBOutlet weak var favoritesBarItem: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    
    lazy var mySplitViewController: UISplitViewController = {
        var splitController = Locator.splitViewController
        
        // Setup childViewControllers
        switch self.traitCollection.horizontalSizeClass {
        case .Compact:
            splitController.viewControllers = [self.listNavigationController]
        default:
            splitController.viewControllers = [self.listNavigationController, self.detailNavigationController]
        }

        splitController.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        splitController.delegate = self
        splitController.hidesBottomBarWhenPushed = true
        
        return splitController
    }()
    
    var listNavigationController: UINavigationController { return Locator.listNavigationController }
    var listViewController: ListViewController { return Locator.listViewController }
    var detailNavigationController: UINavigationController { return Locator.detailNavigationController }
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
        
        Locator.clinet.updateFromSourceURLForYear(2015, month: .Jul)
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
        
        if let navigationController = secondaryViewController as? UINavigationController {
            if let detailViewController = navigationController.topViewController as? DetailViewController {
                return detailViewController.shouldHide
            }
        }
        
        return true
    }
    
    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController!) -> UIViewController? {
        return Locator.detailNavigationController
    }
}

extension RootViewController: Analytics {
    override func screenName() -> String? {
        return "Root View"
    }
}
