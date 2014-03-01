//
//  InfoSessionModel.m
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "AFUwaterlooApiClient.h"

#import "InfoSessionModel.h"
#import "InfoSession.h"

//const NSString *apiKey =  @"abc498ac42354084bf594d52f5570977";
//const NSString *apiKey1 =  @"913034dae16d7233dd1683713cbb4721";
const NSString *myApiKey = @"77881122";

@implementation InfoSessionModel

-(id)init {
    if ((self = [super init])) {
        //NSLog(@"InfoSessionModel Initiated!");
        [self loadInfoSessions];
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
        //NSLog(@"myInfoSessions initiated!");
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

- (void)clearInfoSessions {
    _infoSessions = nil;
    _infoSessionsDictionary = nil;
    _currentTerm = nil;
    [self setYearAndTerm];
}

/**
 *  Initiate NSArray sessions.
 *
 *  @param block
 *
 *  @return
 */
+ (NSURLSessionTask *)infoSessions:(NSInteger)year andTerm:(NSString *)term withBlock:(void (^)(NSArray *sessions, NSString *currentTerm, NSError *error))block{
    NSString *getTarget;
    if (year == 0 || term == nil) {
        getTarget = @"infosessions.json";
    } else {
        getTarget = [NSString stringWithFormat:@"infosessions/%li%@.json", (long)year, term];
    }
    return [[AFUwaterlooApiClient sharedClient] GET:getTarget parameters:@{@"key" : myApiKey} success:^(NSURLSessionDataTask * __unused task, id JSON) {
        //response array from jason
        NSArray *infoSessionsFromResponse = [JSON valueForKeyPath:@"data"];
        NSString *currentTerm = [JSON valueForKeyPath:@"meta.term"];

        // new empty array to store infoSessions
        NSMutableArray *mutableInfoSessions = [NSMutableArray arrayWithCapacity:[infoSessionsFromResponse count]];
        
        for (NSDictionary *attributes in infoSessionsFromResponse) {
            InfoSession *infoSession = [[InfoSession alloc] initWithAttributes:attributes];
            // if start time < end time or date is nil, do not add
            if (!([infoSession.startTime compare:infoSession.endTime] != NSOrderedAscending
                  || infoSession.date == nil
                  || [infoSession.employer length] == 0)) {
                [mutableInfoSessions addObject:infoSession];
            }
        }
        
        if (block) {
            // sorted info sessions in ascending order with start time
            [mutableInfoSessions sortUsingComparator:^(InfoSession *info1, InfoSession *info2){
                return [info1 compareTo:info2];
            }];
            
            //[mutableInfoSessions sortedArrayUsingSelector:@selector(compareTo:)];
            block([NSArray arrayWithArray:mutableInfoSessions], currentTerm, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            NSLog(@"failure");
            block([NSArray array], nil, error);
        }
    }];
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
 *  check whether this infoSession identifier exists in array
 *
 *  @param infoSessionId an InfoSession identifier
 *  @param array       array of InfoSessions
 *
 *  @return -1, if not found, else, return index
 */
+ (NSInteger)findInfoSessionIdentifier:(NSString *)infoSessionId in:(NSMutableArray *)array {
    NSInteger existIndex = -1;
    for (int i = 0; i < [array count]; i++) {
        InfoSession *eachInfoSession = [array objectAtIndex:i];
        if ([[eachInfoSession getIdentifier] isEqual:infoSessionId]) {
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
        [infoSession scheduleNotifications];
        return UWAdded;
    }
    // else exist
    else {

        // check whether information is changed
        // changed
        if ([[array objectAtIndex:existIndex] isChangedCompareTo:infoSession]) {
            [array replaceObjectAtIndex:existIndex withObject:infoSession];
            [infoSession scheduleNotifications];
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
        [infoSession cancelNotifications];
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

- (void)handleFirstTime {
    NSLog([[NSUserDefaults standardUserDefaults] boolForKey:@"hasRun"] ? @"Has Run" : @"Run For The First Time");
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasRun"]) {
        // for the first time, save map to local documents directory
        [InfoSessionModel saveMap];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // if has run, but map file is missing, then saveMap again.
    else if (![InfoSessionModel checkMap]) {
        [InfoSessionModel saveMap];
    }
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

+ (BOOL)checkMap {
    NSString *path = [InfoSessionModel dataFilePath:@"uw_map.png"];
    return [[NSFileManager defaultManager]fileExistsAtPath:path];
}

- (void)saveInfoSessions {
    NSLog(@"saved data");
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:_infoSessions forKey:@"infoSessions"];
    [archiver encodeObject:_infoSessionsDictionary forKey:@"infoSessionsDictionary"];
    [archiver encodeObject:_myInfoSessions forKey:@"myInfoSessions"];
    [archiver finishEncoding];
    [data writeToFile:[InfoSessionModel dataFilePath:@"InfoSession.plist"] atomically:YES];
}

- (void)loadInfoSessions {
    NSLog(@"start load infoSessions");
    NSString *path = [InfoSessionModel dataFilePath:@"InfoSession.plist"];
    if([[NSFileManager defaultManager]fileExistsAtPath:path]){
        NSLog(@"loaded infoSessions");
        NSData *data =[[NSData alloc]initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        //_infoSessions = [unarchiver decodeObjectForKey:@"infoSessions"];
        //_infoSessionsDictionary = [unarchiver decodeObjectForKey:@"infoSessionsDictionary"];
        _myInfoSessions = [unarchiver decodeObjectForKey:@"myInfoSessions"];
        NSLog(@"infoSessionsCount: %lu", (unsigned long)[_infoSessions count]);
        NSLog(@"myInfoSessionsCount: %lu", (unsigned long)[_myInfoSessions count]);
        [unarchiver finishDecoding];
    }else{
        //self.lists = [[NSMutableArray alloc]initWithCapacity:20];
    }

}

- (void)updateMyInfoSessions {
    for (InfoSession *eachInfoSession in _myInfoSessions) {
        NSInteger existIndex = [InfoSessionModel findInfoSession:eachInfoSession in:(NSMutableArray *)_infoSessions];
        if (existIndex != -1) {
            InfoSession *theCorrespondingInfoSession = _infoSessions[existIndex];
            eachInfoSession.employer = [theCorrespondingInfoSession.employer copy];
            eachInfoSession.date = [theCorrespondingInfoSession.date copy];
            eachInfoSession.startTime = [theCorrespondingInfoSession.startTime copy];
            eachInfoSession.endTime = [theCorrespondingInfoSession.endTime copy];
            eachInfoSession.location = [theCorrespondingInfoSession.location copy];
            eachInfoSession.website = [theCorrespondingInfoSession.website copy];
            eachInfoSession.audience = [theCorrespondingInfoSession.audience copy];
            eachInfoSession.programs = [theCorrespondingInfoSession.programs copy];
            eachInfoSession.description = [theCorrespondingInfoSession.description copy];
            eachInfoSession.weekNum = theCorrespondingInfoSession.weekNum;
            eachInfoSession.isCancelled = theCorrespondingInfoSession.isCancelled;
            if (theCorrespondingInfoSession.isCancelled) {
                [eachInfoSession cancelNotifications];
                eachInfoSession.alertIsOn = NO;
            } else {
                [eachInfoSession scheduleNotifications];
            }
        }
    }
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.infoSessions = [aDecoder decodeObjectForKey:@"infoSessions"];
        self.infoSessionsDictionary = [aDecoder decodeObjectForKey:@"infoSessionsDictionary"];
        self.myInfoSessions = [aDecoder decodeObjectForKey:@"myInfoSessions"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.infoSessions forKey:@"infoSessions"];
    [aCoder encodeObject:self.infoSessionsDictionary forKey:@"infoSessionsDictionary"];
    [aCoder encodeObject:self.myInfoSessions forKey:@"myInfoSessions"];
}

- (void)setYearAndTerm {
    if (_currentTerm == nil) {
        _year = 0;
        _term = nil;
        return;
    } else if ([_currentTerm length] > 6) {
        _year = [[_currentTerm substringToIndex:4] integerValue];
        _term = [_currentTerm substringFromIndex:5];
    } else {
        _year = 0;
        _term = nil;
    }
}

- (void)saveToTermInfoDic {
    if (_termInfoDic == nil) {
        _termInfoDic = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"save!!!!!");
    [_termInfoDic setValue:[_infoSessions copy] forKey:[_currentTerm copy]];
    [_termInfoDic setValue:[NSDate date] forKey:[NSString stringWithFormat:@"%@ - QueriedTime", _currentTerm]];
    NSLog(@"dic: %i", [_termInfoDic count]);
    for (NSString *key in _termInfoDic) {
        NSLog(@"%@ ==", key);
    }
}

- (BOOL)readInfoSessionsWithTerm:(NSString *)term{
    NSLog(@"set!!!!");
    NSInteger existIndex = -1;
    NSInteger index = 0;
    for (NSString *key in _termInfoDic) {
        if ([key isEqualToString:term]) {
            NSLog(@"equal!");
            existIndex = index;
            break;
        }
        index++;
    }
    // this term not exists
    if (existIndex == -1) {
        NSLog(@"set failed");
        return false;
    } else {
        // if last queried time is 20m ago, then need connect to network to refresh
        NSInteger intervalForRefresh = 60 * 20;
        NSDate *lastQueriedTime = [_termInfoDic objectForKey:[NSString stringWithFormat:@"%@ - QueriedTime", term]];
        ;
        if ([[NSDate date] timeIntervalSinceDate:lastQueriedTime] > intervalForRefresh) {
            NSLog(@"too old, need refesh");
            return false;
        } else {
            NSLog(@"set successfully");
            _infoSessions = [_termInfoDic[term] copy];
            [self processInfoSessionsDictionary:_infoSessionsDictionary withInfoSessions:_infoSessions];
            _currentTerm = [term copy];
            [self setYearAndTerm];
            return true;
        }
    }
}

@end
