//
//  InfoSessionDataEntry.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2017-01-02.
//  Copyright © 2017 Honghaoz. All rights reserved.
//

import UIKit
import ChouTi
import Then

class InfoSessionDataEntry: TitleContentTableViewCellViewModel, TableViewCellSelectable {
	var cellSelectAction: ((IndexPath, UITableViewCell?, UITableView) -> Void)?
	var cellDeselectAction: ((IndexPath, UITableViewCell?, UITableView) -> Void)?
}

extension InfoSessionDataEntry: Then {}
