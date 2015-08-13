//
//  InfoSessionSourceHTMLParser.swift
//  UW Info Session
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Ji
import SwiftyJSON

struct InfoSessionSourceHTMLParser {
    static func parserHTMLString(string: String) {
        println("Parsing")
        let doc: Ji! = Ji(htmlString: string)
        if doc == nil {
            println("ERROR: Setup Ji doc error")
        }
        
        let nodes = doc.xPath("//*[@id='tableform']")
        if let tableNode = nodes?.first where tableNode.name == "table" {
            for (index, tr) in enumerate(tableNode) {
                print("\(index): ")
                println(tr.content)
            }
        }
    }
}
