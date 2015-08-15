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
    let infoSessionSourceURL = "http://www.ceca.uwaterloo.ca/students/sessions_details.php?id=%d%@"
    static let sharedInstance = Client()
    let parser = InfoSessionSourceHTMLParser()
    
    func updateFromSourceURLForYear(year: Int, month: Month) {
        let sourceURL = String(format: infoSessionSourceURL, year, month.rawValue)
        log.info("Requesting: \(sourceURL)")
        
        Alamofire.request(.GET, sourceURL).responseString {[unowned self] (request, response, string, error) -> Void in
            if let string = string {
                log.debug("Get content successfully!")
                self.parser.parserHTMLString(string)
            } else {
                log.error("Get content failed!")
            }
        }
    }
}
