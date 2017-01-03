//
//  TableViewCellSelectable.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2017-01-02.
//  Copyright © 2017 Honghaoz. All rights reserved.
//

import UIKit

public protocol TableViewCellSelectable {
	typealias TableViewCellSelection = (IndexPath, UITableViewCell?, UITableView) -> Void
	var cellSelectAction: TableViewCellSelection? { get }
	var cellDeselectAction: TableViewCellSelection? { get }
}
