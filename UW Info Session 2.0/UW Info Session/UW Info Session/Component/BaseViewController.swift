//
//  BaseViewController.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-13.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        trackScreen()
    }
    
    private func trackScreen() {
        let tracker = GAI.sharedInstance().defaultTracker
        
        if let screenName = self.screenName() {
            log.info("Screen Name: \(screenName)")
            tracker.set(kGAIScreenName, value: screenName)
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
    }
}

extension BaseViewController: Analytics {
    func screenName() -> String? {
        return nil
    }
}
