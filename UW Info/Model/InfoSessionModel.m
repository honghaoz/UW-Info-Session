//
//  InfoSessionModel.m
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSessionModel.h"

@implementation InfoSessionModel 

-(id)init {
    if ((self = [super init])) {
        _alertIndexDictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"At time of event", @"5 minutes before", @"15 minutes before", @"30 minutes before", @"1 hour before", @"2 hours before", @"1 day before", @"2 days before", @"1 week before", nil] forKeys:[[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil]];
    }
    return self;
}

-(NSMutableArray *)myInfoSessions {
    if (_myInfoSessions == nil) {
        _myInfoSessions = [[NSMutableArray alloc] init];
        return _myInfoSessions;
    } else {
        return _myInfoSessions;
    }
}

-(NSMutableDictionary *)myInfoSessionsDictionary {
    if (_myInfoSessionsDictionary == nil) {
        _myInfoSessionsDictionary = [[NSMutableDictionary alloc] init];
        return _myInfoSessionsDictionary;
    } else {
        return _myInfoSessionsDictionary;
    }
}

-(NSMutableDictionary *)infoSessionsDictionary {
    if (_infoSessionsDictionary == nil) {
        _infoSessionsDictionary = [[NSMutableDictionary alloc] init];
        return _infoSessionsDictionary;
    } else {
        return _infoSessionsDictionary;
    }
}

/**
 *  To be called after self.infoSessions is initiated.
 *  initiated self.infoSessionsDictionary with key: weekNum, value: corronsponding infoSession
 */
-(void)processInfoSessionsDictionary:(NSMutableDictionary *)dictionary withInfoSessions:(NSArray *)array {
    for (InfoSession *eachSession in array) {
        // if key not exist
        if (dictionary[NSIntegerToString(eachSession.weekNum)] == nil) {
            [dictionary setValue:[[NSMutableArray alloc] initWithObjects:eachSession, nil] forKey:NSIntegerToString(eachSession.weekNum)];
        } else {
            // key exists
            [dictionary[NSIntegerToString(eachSession.weekNum)] addObject:eachSession];
        }
    }
}

- (void)addInfoSessionInOrder:(InfoSession *)infoSession to:(NSMutableArray *)array {
    // check whether this infoSession exist in array
    NSInteger existIndex = -1;
    for (int i = 0; i < [array count]; i++) {
        InfoSession *eachInfoSession = [array objectAtIndex:i];
        if (infoSession.SessionId == eachInfoSession.SessionId) {
            existIndex = i;
        }
    }
    // if doesn't exist
    if (existIndex == -1) {
        NSComparator comparator = ^(InfoSession *info1, InfoSession *info2) {
            return [info1.startTime compare:info2.startTime];
        };
        
        NSUInteger newIndex = [array indexOfObject:infoSession
                                     inSortedRange:(NSRange){0, [array count]}
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:comparator];
        
        [array insertObject:infoSession atIndex:newIndex];
    } else {
        [array replaceObjectAtIndex:existIndex withObject:infoSession];
    }
}

///**
// *  Compare to another inforsession, according startTime
// *
// *  @param anotherInfoSession InfoSession
// *
// *  @return NSComparisonResult
// */
//- (NSComparisonResult)compareTo:(InfoSession *)anotherInfoSession {
//    return [self.startTime compare:anotherInfoSession.startTime];
//}
@end