//
//  ServiceProvider.swift
//  UW-Info-Session
//
//  Created by Honghao Zhang on 2016-12-28.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation
import Moya

struct ServiceProvider {
	static let mainServiceProvider = MoyaProvider<MainService>(plugins: [NetworkLoggerPlugin()])
}
