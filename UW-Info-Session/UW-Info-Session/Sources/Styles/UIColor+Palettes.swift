//
//  UIColor+Palettes.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-29.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit
import DynamicColor

extension UIColor {
	static var primary: UIColor {
		return UIColor.black
	}
	
	static var secondary: UIColor {
		return UIColor.white
	}
}

extension UIColor {
	static var primaryText: UIColor {
		return UIColor.black
	}
	
	static var secondaryText: UIColor {
		return UIColor(hexString: "#535258")
	}
	
	static var unimportantText: UIColor {
		return UIColor(white: 0.7, alpha: 1.0)
	}
}

extension UIColor {
	static var separator: UIColor {
		return UIColor(hexString: "#C8C7CC")
	}
}
