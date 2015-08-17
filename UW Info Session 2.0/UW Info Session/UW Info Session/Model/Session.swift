//
//  Session.swift
//  
//
//  Created by Honghao Zhang on 2015-08-16.
//
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var employer: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate
    @NSManaged var location: String?
    @NSManaged var website: String?
    @NSManaged var audience: String?
    @NSManaged var program: String?
    @NSManaged var descriptions: String?
    @NSManaged var rating: NSNumber?

}
