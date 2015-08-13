//
//  DetailViewController.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-11.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController {
    
    var shouldHide: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

extension DetailViewController: Analytics {
    override func screenName() -> String? {
        return "Detail View"
    }
}
