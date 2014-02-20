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
        NSLog(@"InfoSessionModel Initiated!");
        [self handleFirstTime];
    }
    return self;
}

/**
 *  Get method, lazy initiation
 *
 *  @return return the array of user saved info sessions
 */
-(NSMutableArray *)myInfoSessions {
    if (_myInfoSessions == nil) {
        NSLog(@"myInfoSessions initiated!");
        _myInfoSessions = [[NSMutableArray alloc] init];
        return _myInfoSessions;
    } else {
        return _myInfoSessions;
    }
}


//-(NSMutableDictionary *)myInfoSessionsDictionary {
//    if (_myInfoSessionsDictionary == nil) {
//        _myInfoSessionsDictionary = [[NSMutableDictionary alloc] init];
//        return _myInfoSessionsDictionary;
//    } else {
//        return _myInfoSessionsDictionary;
//    }
//}

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
/**
 *  check whether this infoSession exist in array
 *
 *  @param infoSession an InfoSession instance
 *  @param array       array of InfoSessions
 *
 *  @return -1, if not found, else, return index
 */
+ (NSInteger)findInfoSession:(InfoSession *)infoSession in:(NSMutableArray *)array {
    NSInteger existIndex = -1;
    for (int i = 0; i < [array count]; i++) {
        InfoSession *eachInfoSession = [array objectAtIndex:i];
        if ([infoSession isEqual:eachInfoSession]) {
            existIndex = i;
        }
    }
    return existIndex;
}

/**
 *  Add a new InfoSession instance to the array in order, start time in ascending
 *
 *  @param infoSession the InfoSession to be added
 *  @param array       the Array add to.
 */
+ (UW)addInfoSessionInOrder:(InfoSession *)infoSession to:(NSMutableArray *)array {
    NSInteger existIndex = [InfoSessionModel findInfoSession:infoSession in:array];
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
        return UWAdded;
    }
    // else exist
    else {

        // check whether information is changed
        // changed
        if ([[array objectAtIndex:existIndex] isChangedCompareTo:infoSession]) {
            [array replaceObjectAtIndex:existIndex withObject:infoSession];
            return UWReplaced;
        }
        // no information is changed
        else {
            return UWNonthing;
        }
    }
}

+ (UW)deleteInfoSession:(InfoSession *)infoSession in:(NSMutableArray *)array {
    NSInteger existIndex = [InfoSessionModel findInfoSession:infoSession in:array];
    if (existIndex != -1) {
        [array removeObjectAtIndex:existIndex];
        return UWDeleted;
    }
    return UWNonthing;
}

/**
 *  Count the number of InfoSession objects in array, which is after today's date
 *
 *  @param infosessions an NSArray of InfoSession objects
 *
 *  @return NSInteger
 */
- (NSInteger)countFutureInfoSessions:(NSArray *)infosessions {
    NSInteger count = 0;
    for (InfoSession *eachSession in infosessions) {
        if ([eachSession.startTime compare:[NSDate date]] == NSOrderedDescending) {
            count++;
        }
    }
    return count;
}

#pragma mark - documents operations

+ (NSString*)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

+ (NSString*)dataFilePath:(NSString *)fileName{
    return [[self documentsDirectory] stringByAppendingPathComponent:fileName];
}

+ (void)saveMap {
    NSData *pngData = UIImagePNGRepresentation([UIImage imageNamed:@"map_colour300.png"]);
    [pngData writeToFile:[self dataFilePath:@"uw_map.png"] atomically:YES];
}

+ (UIImage *)loadMap {
    NSData *pngData = [NSData dataWithContentsOfFile:[self dataFilePath:@"uw_map.png"]];
    return [UIImage imageWithData:pngData];
}

- (void)handleFirstTime {
    NSLog([[NSUserDefaults standardUserDefaults] boolForKey:@"hasRun"] ? @"Has Run" : @"Run For The First Time");
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasRun"]) {
        // for the first time, save map to local documents directory
        [InfoSessionModel saveMap];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
