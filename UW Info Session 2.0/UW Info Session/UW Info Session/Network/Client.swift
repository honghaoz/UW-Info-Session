//
//  Client.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Alamofire

class Client {
	let infoSessionSourceURL = "http://www.ceca.uwaterloo.ca/students/sessions_details.php?id=2015Jun"
	static let sharedInstance = Client()
	
	func updateFromSourceURL() {
		Alamofire.request(.GET, infoSessionSourceURL).responseString { (request, response, string, error) -> Void in
			println(string)
		}
	}
}