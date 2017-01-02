//
//  InfoSession+InfoSessionViewModelType.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-29.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit

extension InfoSession: InfoSessionViewModelType {
	var title: String? {
		return employer
	}
	
	var subtitle: String? {
		return location
	}
	
	var accessoryTitle: String? {
		if isNotice {
			return nil
		}
		
		return startDate?.string(format: .custom("h:mm a"))
	}
	
	var isFavorited: Bool {
		return Bool.random()
	}
	
	var titleColor: UIColor? {
		return isNotice ? UIColor.unimportantText : UIColor.primaryText
	}
	
	var subtitleColor: UIColor? {
		return isNotice ? UIColor.unimportantText : UIColor.secondaryText
	}
	
	var accessoryTitleColor: UIColor {
		return isNotice ? UIColor.unimportantText : UIColor.primaryText
	}
	
	var titleFont: UIFont? {
		return isNotice ? UIFont.unimportantTitleFont : UIFont.titleFont
	}
	
	var subtitleFont: UIFont? {
		return UIFont.subtitleFont
	}
	
	var accessoryTitleFont: UIFont {
		return UIFont.subtitleFont
	}
}
