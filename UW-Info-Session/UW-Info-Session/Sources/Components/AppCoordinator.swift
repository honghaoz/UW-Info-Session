//
//  AppCoordinator.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-22.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation

enum BuildType: String {
	case Debug
	case Release
}

class AppCoordinator {
	static let sharedAppController = AppCoordinator()
	
	let appViewController = AppViewController()
	
	#if DEBUG
	let buildType: BuildType = .Debug
	#elseif RELEASE
	let buildType: BuildType = .Release
	#endif
}
