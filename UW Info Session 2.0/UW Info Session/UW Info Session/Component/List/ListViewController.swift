//
//  ListViewController.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-10.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
	@IBOutlet weak var listTableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupTableView()
    }
	
	private func setupTableView() {
		ListCell.registerInTableView(listTableView)
		
		listTableView.dataSource = self
		listTableView.delegate = self
		
		listTableView.rowHeight = UITableViewAutomaticDimension
	}
}

extension ListViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(ListCell.identifier()) as! ListCell
		return cell
	}
}

extension ListViewController: UITableViewDelegate {
    // MARK: - Rows
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ListCell.estimatedRowHeight()
    }
    
    // MARK: - Selections
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        Locator.detailViewController.shouldHide = false
        
        // https://www.shinobicontrols.com/blog/ios8-day-by-day-day-18-uisplitviewcontroller
        
        Locator.splitViewController.showDetailViewController(Locator.detailNavigationController, sender: self)
    }
}
