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
    
    func updateFromSourceURLForYear(year: Int, month: Month) {
        let sourceURL = String(format: infoSessionSourceURL, year, month.rawValue)
        println("Request: \(sourceURL)")
        
        Alamofire.request(.GET, sourceURL).responseString { (request, response, string, error) -> Void in
            if let string = string {
                println("Get content successfully!")
                InfoSessionSourceHTMLParser.parserHTMLString(string)
            } else {
                println("ERROR: Get HTML String error")
            }
        }
    }
}
