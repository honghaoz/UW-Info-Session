//
//  Logger.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation
import XCGLogger

let log: XCGLogger = {
	let logger = XCGLogger(identifier: "com.honghaoz.uw-info-session")
	
	let logLevel: XCGLogger.Level
	
	#if DEBUG
		logLevel = .debug
	#else
		logLevel = .error
	#endif
	
	logger.setup(
		level: logLevel,
		showLogIdentifier: false,
		showFunctionName: false,
		showThreadName: true,
		showLevel: true,
		showFileNames: true,
		showLineNumbers: true,
		showDate: true,
		writeToFile: nil,
		fileLevel: nil
	)
	
	return logger
}()
