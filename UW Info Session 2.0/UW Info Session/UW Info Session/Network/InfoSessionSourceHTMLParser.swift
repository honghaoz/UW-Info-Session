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
    let kEmployer = "Employer"
    let kDate = "Date"
    let kTime = "Time"
    let kLocation = "Location"
    let kWebSite = "Web Site"
    let kAudience = "Audience"
    let kProgram = "Program"
    let kDescription = "Description"
    let kId = "id"
    
    var result = [String: AnyObject]()
    
    func parserHTMLString(string: String) {
        log.debug("Parsing")
        
        let doc: Ji! = Ji(htmlString: string)
        if doc == nil {
            log.error("Setup Ji doc failed")
        }
        
        let nodes = doc.xPath("//*[@id='tableform']")
        if let tableNode = nodes?.first where tableNode.name == "table" {
            // Divide trs into different sessions
            // Each session is a list of tr Ji node
            var trSessionGroups = [[JiNode]]()
            var trSessionGroup: [JiNode]?
            for tr in tableNode {
                if var tdContent = tr.firstChildWithName("td")?.content {
                    if tdContent.hasPrefix("\(kEmployer):") {
                        if let trSessionGroup = trSessionGroup { trSessionGroups.append(trSessionGroup) }
                        trSessionGroup = [tr]
                        continue
                    }
                    trSessionGroup!.append(tr)
                }
            }
            
            // Process each session group to a dictionary
            let json = JSON(trSessionGroups.map { self.processTrSessionGroupToDict($0) })
            log.debug(json)
        }
    }
    
    private func processTrSessionGroupToDict(trSession: [JiNode]) -> [[String: String]] {
        var result = [[String: String]]()
        
        var webSiteIndex: Int?
        for (index, tr) in enumerate(trSession) {
            if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kEmployer):") {
                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
                result.append([kEmployer: secondString ?? "null"])
            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kDate):") {
                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
                result.append([kDate: secondString ?? "null"])
            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kTime):") {
                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
                result.append([kTime: secondString ?? "null"])
            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kLocation):") {
                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
                result.append([kLocation: secondString ?? "null"])
            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kWebSite):") {
                var secondString = tr.firstChild?.nextSibling?.content?.trimmed()
                if secondString == "http://" { secondString = "" }
                result.append([kWebSite: secondString ?? "null"])
                webSiteIndex = index
            }
            else if let webSiteIndex = webSiteIndex where index == webSiteIndex + 1 {
                // Audience + Programs
                if let rawContent = tr.xPath("./td/i").first?.rawContent?.replaceMatches("<(i|/i)>", withString: "", ignoreCase: false) {
                    let components = rawContent.componentsSeparatedByString("<br>")
                    if components.count == 3 {
                        let levelString = (components[0].hasPrefix("For ") ? components[0].stringByReplacingOccurrencesOfString("For ", withString: "", options: NSStringCompareOptions(0), range: nil) : components[0]).trimmed()
                        let studentString = components[1].replaceMatches(", ", withString: ",", ignoreCase: true)?.stringByReplacingOccurrencesOfString(",", withString: ", ", options: NSStringCompareOptions(0), range: nil).trimmed() ?? ""
                        let programString = components[2].trimmed()
                        result.append([kAudience: "\(levelString) \(studentString)".trimmed()])
                        result.append([kProgram: programString])
                    } else {
                        log.error("Parsing Audient and Program failed.")
                    }
                } else {
                    log.error("Get raw text for Audience failed.")
                }
            } else if let webSiteIndex = webSiteIndex where index == webSiteIndex + 2 {
                // Description
                if let rawContent = tr.xPath("./td/i").first?.rawContent?.replaceMatches("<(i|/i)>", withString: "", ignoreCase: false) {
                    let removedBrString = rawContent.stringByReplacingOccurrencesOfString("<br>", withString: "\n", options: NSStringCompareOptions(0), range: nil)
                    result.append([kDescription: removedBrString])
                } else {
                    log.error("Get raw text for Audience failed.")
                }
            }
        }
        
        return result
    }
}

// Summary
// 0: Employer √
// 1: Date √
// 2: Time √
// 3: Location √
// 4: Web Site √
// 5: Audiences + Programm √
// 6: Description √
// 7: Attendance ???
// 8: Bakc to listing
// 9: You are not logged in

// MARK: - 2015 Jul Sample
//    0: Optional("Employer: \r\n         No info sessions")[;
//    [fg60,161,202;1: Optional("Date: \r\n         July 1, 2015")[;
//    [fg60,161,202;2: Optional("Time: \r\n         08:00 AM - 11:30 PM")[;
//    [fg60,161,202;3: Optional("Location:")[;
//    [fg60,161,202;4: Optional("Web Site: \r\n         http://")[;
//    [fg60,161,202;5: Optional("For   Students")[;
//    [fg60,161,202;6: Optional("")[;
//    [fg60,161,202;7: Optional("Attendance: \r\n            0")[;
//    [fg60,161,202;8: Optional("Back to Listing |\r\n                              Check registrations (employers)")[;
//    [fg60,161,202;9: Optional("You are not logged in.")[

//    [fg60,161,202;10: Optional("Employer: \r\n         Canada Day")[;
//    [fg60,161,202;11: Optional("Date: \r\n         July 1, 2015")[;
//    [fg60,161,202;12: Optional("Time: \r\n         08:00 AM - 11:30 PM")[;
//    [fg60,161,202;13: Optional("Location:")[;
//    [fg60,161,202;14: Optional("Web Site: \r\n         http://")[;
//    [fg60,161,202;15: Optional("For   Students")[;
//    [fg60,161,202;16: Optional("")[;
//    [fg60,161,202;17: Optional("Attendance: \r\n            1")[;
//    [fg60,161,202;18: Optional("Back to Listing |\r\n                              Check registrations (employers)")[;
//    [fg60,161,202;19: Optional("You are not logged in.")[;

//    [fg60,161,202;20: Optional("Employer: \r\n         Spin Master Ltd.")[;
//    [fg60,161,202;21: Optional("Date: \r\n         July 2, 2015")[;
//    [fg60,161,202;22: Optional("Time: \r\n         11:30 AM - 1:30 PM")[;
//    [fg60,161,202;23: Optional("Location: \r\n         DC 1301")[;
//    [fg60,161,202;24: Optional("Web Site: \r\n         http://www.spinmaster.com")[;
//    [fg60,161,202;25: Optional("For Junior, Intermediate, Senior, MastersCo-op Students ENG - Mechatronics, ENG - Mechanical, ENG - Electrical")[;
//    [fg60,161,202;26: Optional("An opportunity to get to know one of the world\'s largest and most innovative toy companies.  Learn about our products, our process and how you can be an integral part of the team!")[;
//    [fg60,161,202;27: Optional("Back to Listing |\r\n                              Check registrations (employers)")[;
//    [fg60,161,202;28: Optional("You are not logged in.")[;

//    [fg60,161,202;29: Optional("Employer: \r\n         BlackBerry")[;
//    [fg60,161,202;30: Optional("Date: \r\n         July 21, 2015")[;
//    [fg60,161,202;31: Optional("Time: \r\n         5:00 PM - 7:00 PM")[;
//    [fg60,161,202;32: Optional("Location: \r\n         TC 2218")[;
//    [fg60,161,202;33: Optional("Web Site: \r\n         http://")[;
//    [fg60,161,202;34: Optional("For Junior, Intermediate, Senior, Masters, PhDGraduating,Co-op Students ENG - System Design, ENG - Software, ENG - Nanotechnology, ENG - Mechatronics, ENG - Mechanical, ENG - Management, ENG - Electrical, ENG - Computer")[;
//    [fg60,161,202;35: Optional("Connecting the world - people, machines and devices - securely and reliably is in our DNA.You can help us push the boundaries of innovation and enable people and businesses to not just do more, but be more.UNIVERSITY OF WATERLOO, INFO SESSION:Come join BlackBerry\'s University of Waterloo campus ambassadors to learn more about the co-op and full time opportunities at BlackBerry.")[;
//    [fg60,161,202;36: Optional("Back to Listing |\r\n                              Check registrations (employers)")[;
//    [fg60,161,202;37: Optional("You are not logged in.")[;

//    [fg60,161,202;38: Optional("Employer: \r\n         Lectures end")[;
//    [fg60,161,202;39: Optional("Date: \r\n         July 28, 2015")[;
//    [fg60,161,202;40: Optional("Time: \r\n         08:00 AM - 11:30 PM")[;
//    [fg60,161,202;41: Optional("Location:")[;
//    [fg60,161,202;42: Optional("Web Site: \r\n         http://")[;
//    [fg60,161,202;43: Optional("For  Students")[;
//    [fg60,161,202;44: Optional("")[;
//    [fg60,161,202;45: Optional("Attendance: \r\n            0")[;
//    [fg60,161,202;46: Optional("Back to Listing |\r\n                              Check registrations (employers)")[;
//    [fg60,161,202;47: Optional("You are not logged in.")[;

//    [fg60,161,202;48: Optional("Employer: \r\n         No info sessions")[;
//    [fg60,161,202;49: Optional("Date: \r\n         July 28, 2015")[;
//    [fg60,161,202;50: Optional("Time: \r\n         08:00 AM - 11:30 PM")[;
//    [fg60,161,202;51: Optional("Location:")[;
//    [fg60,161,202;52: Optional("Web Site: \r\n         http://")[;
//    [fg60,161,202;53: Optional("For  Students")[;
//    [fg60,161,202;54: Optional("")[;
//    [fg60,161,202;55: Optional("Attendance: \r\n            0")[;
//    [fg60,161,202;56: Optional("Back to Listing |\r\n                              Check registrations (employers)")[;
//    [fg60,161,202;57: Optional("You are not logged in.")[;


// MARK: - 2015 Oct Sample
//    0: Optional("Employer: \r\n         Dematic Limited")[;
//    [fg60,161,202;1: Optional("Date: \r\n         October 1, 2015")[;
//    [fg60,161,202;2: Optional("Time: \r\n         09:00 AM - 11:00 AM")[;
//    [fg60,161,202;3: Optional("Location: \r\n         Tatham Centre 2218 A & B")[;
//    [fg60,161,202;4: Optional("Web Site: \r\n         http://www.dematic.com")[;
//    [fg60,161,202;5: Optional("For Junior, Intermediate, Senior, Masters, PhDGraduating,Co-op Students MATH - Scientific Computation, MATH - Information Technology Management, MATH - Computer Science, MATH - Computational Mathematics, MATH - Applied Mathematics, ENG - Software")[;
//    [fg60,161,202;6: Optional("Our new team in Waterloo is designing and developing a new analytics software platform to provide our customers with a revolutionary level of warehouse automation visibility.  Our customers, many of the largest distributors and manufacturers in the world, depend on Dematic to enable the delivery of products to stores and doorsteps faster than ever before.")[;
//    [fg60,161,202;7: Optional("<tr><td width=\"100\" colspan=\"3\"><b>You are currently not registered for the above information session. Please <a href=\"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=3524&mode=on\">RSVP</a> if you will be attending this session.</b></td></tr>")[;
//    [fg60,161,202;8: Optional("Please register if you will be attending this session or cancel the session if you have registered for this and no longer want to attend it.")[;
//    [fg60,161,202;9: Optional("Back to Listing |\r\n         Register (students) |                     Check registrations (employers)")[;
//    [fg60,161,202;10: Optional("You are not logged in.")[;
//    [fg60,161,202;11: Optional("Employer: \r\n         Visier Solutions")[;
//    [fg60,161,202;12: Optional("Date: \r\n         October 1, 2015")[;
//    [fg60,161,202;13: Optional("Time: \r\n         11:30 AM - 1:30 PM")[;
//    [fg60,161,202;14: Optional("Location: \r\n         Fed Hall - Multipurpose Room A")[;
//    [fg60,161,202;15: Optional("Web Site: \r\n         http://www.visier.com")[;
//    [fg60,161,202;16: Optional("For Junior, Intermediate, Senior, Masters, PhDCo-op and Graduating Students MATH - Computer Science, ENG - Software, ENG - Computer")[;
//    [fg60,161,202;17: Optional("")[;
//    [fg60,161,202;18: Optional("<tr><td width=\"100\" colspan=\"3\"><b>You are currently not registered for the above information session. Please <a href=\"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=3205&mode=on\">RSVP</a> if you will be attending this session.</b></td></tr>")[;
//    [fg60,161,202;19: Optional("Please register if you will be attending this session or cancel the session if you have registered for this and no longer want to attend it.")[;
//    [fg60,161,202;20: Optional("Back to Listing |\r\n         Register (students) |                     Check registrations (employers)")[;
//    [fg60,161,202;21: Optional("You are not logged in.")[;
//    [fg60,161,202;22: Optional("Employer: \r\n         Metro Vancouver")[;
//    [fg60,161,202;23: Optional("Date: \r\n         October 1, 2015")[;
//    [fg60,161,202;24: Optional("Time: \r\n         11:30 AM - 1:30 PM")[;
//    [fg60,161,202;25: Optional("Location: \r\n         TC 2218")[;
//    [fg60,161,202;26: Optional("Web Site: \r\n         http://www.metrovancouver.org")[;
//    [fg60,161,202;27: Optional("For BachelorGraduating Students ENG - System Design, ENG - Mechanical, ENG - Management, ENG - Geological, ENG - Environmental, ENG - Electrical, ENG - Civil")[;
//    [fg60,161,202;28: Optional("")[;
//    [fg60,161,202;29: Optional("<tr><td width=\"100\" colspan=\"3\"><b>You are currently not registered for the above information session. Please <a href=\"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=3553&mode=on\">RSVP</a> if you will be attending this session.</b></td></tr>")[;
//    [fg60,161,202;30: Optional("Please register if you will be attending this session or cancel the session if you have registered for this and no longer want to attend it.")[;
//    [fg60,161,202;31: Optional("Back to Listing |\r\n         Register (students) |                     Check registrations (employers)")[;
//    [fg60,161,202;32: Optional("You are not logged in.")[;
//    [fg60,161,202;33: Optional("Employer: \r\n         Wealthsimple")[;
//    [fg60,161,202;34: Optional("Date: \r\n         October 1, 2015")[;
//    [fg60,161,202;35: Optional("Time: \r\n         2:30 PM - 4:30 PM")[;
//    [fg60,161,202;36: Optional("Location: \r\n         TC 2218")[;
//    [fg60,161,202;37: Optional("Web Site: \r\n         http://www.wealthsimple.com")[;
//    [fg60,161,202;38: Optional("For Intermediate, Senior, Masters, PhDCo-op,Graduating Students ENG - Software, MATH - Computing & Financial Management, MATH - Computer Science, MATH - Applied Mathematics, ENG - System Design")[;
//    [fg60,161,202;39: Optional("Wealthsimple is on a mission to make investing smarter and simpler for everyone. As one of the fastest growing startups in Canada, we recently raised a $30M series A to accelerate growth and expand our team. If you think you\'d be a good fit, we\'d love to meet you!")[;
//    [fg60,161,202;40: Optional("<tr><td width=\"100\" colspan=\"3\"><b>You are currently not registered for the above information session. Please <a href=\"https://info.uwaterloo.ca/infocecs/students/rsvp/index.php?id=3461&mode=on\">RSVP</a> if you will be attending this session.</b></td></tr>")[;
//    [fg60,161,202;41: Optional("Please register if you will be attending this session or cancel the session if you have registered for this and no longer want to attend it.")[;
//    [fg60,161,202;42: Optional("Back to Listing |\r\n         Register (students) |                     Check registrations (employers)")[;
//    [fg60,161,202;43: Optional("You are not logged in.")[;
