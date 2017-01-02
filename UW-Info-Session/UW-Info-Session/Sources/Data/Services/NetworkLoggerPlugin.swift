//
//  NetworkLoggerPlugin.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation
import Moya
import Result

final class NetworkLoggerPlugin: PluginType {
	func willSend(_ request: RequestType, target: TargetType) {
		logRequest(request)
	}
	
	private func logRequest(_ request: RequestType) {
		guard let urlRequest = request.request else { return }
		log.info("\(urlRequest.httpMethod ?? "Unknown"): \(urlRequest.url?.absoluteString ?? "Unknown")")
	}
}
