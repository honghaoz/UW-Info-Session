//
//  DataProvider.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation
import ObjectMapper

struct InfoSessionProvider {
	static var infoSessions: [InfoSession] = []
	
	static func fetchInfoSessions(year: Int, term: Term, completion: @escaping ([InfoSession]?, Error?) -> Void) {
		ServiceProvider.mainServiceProvider.request(.infoSessions(year: year, term: term)) { result in
			switch result {
			case .success(let response):
				do {
					let json = try response.mapJSON() as? [String : Any]
					
					if let dataJSON = json?["data"] as? [[String : Any]] {
						var infoSessions: [InfoSession] = dataJSON.flatMap {
							let infoSession = Mapper<InfoSession>().map(JSON: $0)
							return infoSession
							}
						
						filterOutClosedInfoSessions(infoSessions: &infoSessions)
						
						self.infoSessions = infoSessions
						completion(infoSessions, nil)
					}
				} catch {
					completion(nil, error)
				}
				
			case .failure(let error):
				completion(nil, error)
			}
		}
	}
	
	private static func filterOutClosedInfoSessions(infoSessions: inout [InfoSession]) {
		var i = 0
		while i < infoSessions.count {
			if infoSessions[i].employer?.lowercased().contains("no info session") == true {
				infoSessions.remove(at: i)
				i -= 1
			}
			i += 1
		}
	}
}
