//
//  MainService.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation
import Moya

// https://uw-info1.appspot.com/infosessions/2015Fall.json?key=1

enum MainService {
	case infoSessions(year: Int, term: Term)
}

extension MainService : TargetType {
	var baseURL: URL {
		return URL(string: "https://uw-info2.appspot.com")!
	}
	
	var path: String {
		switch self {
		case .infoSessions(let year, let term):
			return "/infosessions/\(year)\(term.rawValue).json"
		}
	}
	
	var method: Moya.Method {
		return .get
	}
	
	var parameters: [String: Any]? { return ["key" : "1"] }
	
	var sampleData: Data { return "".UTF8EncodedData }
	
	var task: Task { return .request }
}

// MARK: - Helpers
private extension String {
	var URLEscapedString: String {
		return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
	}
	var UTF8EncodedData: Data {
		return self.data(using: String.Encoding.utf8)!
	}
}
