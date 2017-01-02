//
//  AppViewController.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-22.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit
import ChouTi

class AppViewController: BaseViewController {
	
	lazy var mainViewController: ListViewController = ListViewController()
	
	weak var previousViewController: UIViewController?
	
	var currentViewController: UIViewController! {
		didSet {
			setNeedsStatusBarAppearanceUpdate()
		}
	}
	
	override var childViewControllerForStatusBarStyle: UIViewController? {
		return currentViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		start()
		
		#if DEBUG
			setupDebugEnvironment()
		#endif
	}
}

// MARK: - Coordinator
extension AppViewController {
	func start() {
		setupAppearance()
		setupViewController()
	}
	
	func setupAppearance() {
//		UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(hexString: "#A17CB7")!], for: .normal)
//		UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white], for: .selected)
	}
	
	func setupViewController() {
//		if Settings.Onboarding.hasShown == false {
//			setupFullScreen(onboardingViewController)
//			onboardingViewController.finishClosure = { [weak self] in
//				guard let strongSelf = self else { return }
//				strongSelf.transit(from: strongSelf.onboardingViewController, to: strongSelf.mainViewController)
//			}
//		} else {
			setupFullScreen(mainViewController.wrappedInNavigationController())
//		}
	}
}

// MARK: - Child View Controller Management
extension AppViewController {
	/**
	Add a child view controller and setup it's view to full screen size
	
	- parameter childViewController: a child view controller
	*/
	func setupFullScreen(_ childViewController: UIViewController) {
		self.addChildViewController(childViewController)
		childViewController.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(childViewController.view)
		childViewController.view.constrainToFullSizeInSuperview()
		
		childViewController.didMove(toParentViewController: self)
		currentViewController = childViewController
		previousViewController = currentViewController
	}
	
	/**
	Remove from view controller and add to view controller, transit them with cross dissolve animations
	
	- parameter fromViewController: fromViewController
	- parameter toViewController:   toViewController
	*/
	func transit(from fromViewController: UIViewController, to toViewController: UIViewController) {
		guard self.childViewControllers.contains(fromViewController) == true &&
			self.childViewControllers.contains(toViewController) == false else {
				return
		}
		
		fromViewController.willMove(toParentViewController: nil)
		self.addChildViewController(toViewController)
		
		self.transition(from: fromViewController,
		                to: toViewController,
		                duration: 0.333,
		                options: .transitionCrossDissolve,
		                animations: {
							toViewController.view.translatesAutoresizingMaskIntoConstraints = false
							self.view.addSubview(toViewController.view)
							toViewController.view.constrainToFullSizeInSuperview()
		}) { [unowned self] _ in
			fromViewController.view.removeFromSuperview()
			fromViewController.removeFromParentViewController()
			toViewController.didMove(toParentViewController: self)
			self.currentViewController = toViewController
			self.previousViewController = fromViewController
		}
	}
}

extension AppViewController {
	#if DEBUG
	func setupDebugEnvironment() {
//		ShakeMotion.sharedInstance.startShakeMotionDetection()
//		DebugSettingsViewController.sharedController.setupShakeToShow()
//		DebugSettingsViewController.sharedController.setupTapStatusBarToShow()
	}
	#endif
}
