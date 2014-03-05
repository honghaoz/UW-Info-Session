//
//  EKEvent+NSCoding.m
//  UW Info
//
//  Created by Zhang Honghao on 2/21/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "EKEvent+NSCoding.h"

@implementation EKEvent (NSCoding)

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super init])) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.availability = [aDecoder decodeIntegerForKey:@"availability"];
        self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
        self.endDate = [aDecoder decodeObjectForKey:@"endDate"];
        self.allDay = [aDecoder decodeBoolForKey:@"allDay"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.alarms = [aDecoder decodeObjectForKey:@"alarms"];
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
        //self.calendar = [aDecoder decodeObjectForKey:@"calendar"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeInteger:self.availability forKey:@"availability"];
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.endDate forKey:@"endDate"];
    [aCoder encodeBool:self.allDay forKey:@"allDay"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.alarms forKey:@"alarms"];
    [aCoder encodeObject:self.URL forKey:@"URL"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
    //[aCoder encodeObject:self.calendar forKey:@"calendar"];
}

@end
