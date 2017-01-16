//
//  InfoSession.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftDate

class InfoSession: Mappable {
	var id: Int?
	var employer: String?
	var startDate: DateInRegion?
	var endDate: DateInRegion?
	var location: String?
	var website: String?
	var audience: String?
	var programs: String?
	var description: String?
	
	var isCancelled: Bool = false
	
	/// Whether this is a notice item
	var isNotice: Bool {
		return employer?.lowercased() == "closed info session" ||
			employer?.lowercased() == "closed information session" ||
			location == nil || location!.isEmpty
	}
	
	required init?(map: Map) {}
	func mapping(map: Map) {
		id <- map["id"]
		employer <- map["employer"]
		employer = employer?.trimmed()
		
		if let employer = employer, employer.lowercased().contains("cancelled") {
			isCancelled = true
		}
		
		// September 5, 2013
		if let dateString = (map["date"].currentValue as? String)?.trimmed() {
			let toronto = Region(tz: .americaToronto, cal: .gregorian, loc: .englishCanada)
			let dateFormat = DateFormat.custom("h:mm a, MMMM d, y")
			
			// 1:00 PM
			if let startTime = (map["start_time"].currentValue as? String)?.trimmed() {
				startDate = try? DateInRegion(string: "\(startTime), \(dateString)", format: dateFormat, fromRegion: toronto)
			}
			
			// 3:00 PM
			if let endTime = (map["end_time"].currentValue as? String)?.trimmed() {
				endDate = try? DateInRegion(string: "\(endTime), \(dateString)", format: dateFormat, fromRegion: toronto)
			}
		}
		
		location <- map["location"]
		location = location?.trimmed()
		
		website <- map["website"]
		website = website?.trimmed()
		
		audience <- map["audience"]
		audience = audience?.trimmed()
		
		programs <- map["programs"]
		programs = programs?.trimmed()
		
		description <- map["description"]
		description = description?.trimmed()
	}
}
