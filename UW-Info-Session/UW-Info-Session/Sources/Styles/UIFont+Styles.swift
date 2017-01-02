//
//  UIFont+Styles.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-29.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit

//extension UIFont {
//	// Company Name
//	static var titleFont: UIFont {
//		//.gillSansFont(22)
//		return UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
//	}
//	
//	static var unimportantFont: UIFont {
//		
//	}
//
//	// Location/Time
//	static var subtitleFont: UIFont {
//		// .gillSansLightFont(18)
//		return UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
//	}
//	
//	// Section Header
//	static var headerFont: UIFont {
//		return UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
//	}
//	
//	// Content
//	static var bodyFont: UIFont {
//		return UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
//	}
//	
//	static var heading1TextFont: UIFont {
//		return UIFont.systemFont(ofSize: 24, weight: UIFontWeightSemibold)
//	}
//	
//	static var heading2TextFont: UIFont {
//		return UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
//	}
//	
//	static var heading3TextFont: UIFont {
//		return UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
//	}
//}

extension UIFont {
	// Company Name
	static var titleFont: UIFont {
		return UIFont.gillSansFont(18) ?? UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
	}
	
	static var unimportantTitleFont: UIFont {
		return UIFont.gillSansItalicFont(18) ?? UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
	}
	
	// Location/Time
	static var subtitleFont: UIFont {
		return UIFont.gillSansLightFont(16) ?? UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
	}
	
	// Section Header
	static var headerFont: UIFont {
		return UIFont.gillSansFont(16) ?? UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
	}
	
	// Content
	static var bodyFont: UIFont {
		return UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular)
	}
	
	static var heading1TextFont: UIFont {
		return UIFont.gillSansFont(32) ?? UIFont.systemFont(ofSize: 32, weight: UIFontWeightSemibold)
	}
	
	static var heading2TextFont: UIFont {
		return UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
	}
	
	static var heading3TextFont: UIFont {
		return UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
	}
}
