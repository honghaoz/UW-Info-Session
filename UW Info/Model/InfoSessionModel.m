//
//  InfoSessionModel.m
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "UWInfoSessionClient.h"

#import "InfoSessionModel.h"
#import "InfoSession.h"

#import <Parse/Parse.h>
#import "UWErrorReport.h"

//const NSString *apiKey =  @"abc498ac42354084bf594d52f5570977";
//const NSString *apiKey1 =  @"913034dae16d7233dd1683713cbb4721";

@interface InfoSessionModel() <UIAlertViewDelegate>

@property (nonatomic, copy) NSString *infoSessionBaseURLString;

@end


@implementation InfoSessionModel {
    bool isOffLineMode;
}

-(id)init {
    if ((self = [super init])) {
        //NSLog(@"InfoSessionModel Initiated!");
        isOffLineMode = NO;
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

-(NSMutableDictionary *)infoSessionsDictionary {
    if (_infoSessionsDictionary == nil) {
        _infoSessionsDictionary = [[NSMutableDictionary alloc] init];
        return _infoSessionsDictionary;
    } else {
        return _infoSessionsDictionary;
    }
}

-(NSMutableDictionary *)termInfoDic {
    if (_termInfoDic == nil) {
        _termInfoDic = [[NSMutableDictionary alloc] init];
        return _termInfoDic;
    } else {
        return _termInfoDic;
    }
}

-(NSMutableDictionary *)infoSessionsIndexDic {
    if (_infoSessionsIndexDic == nil) {
        _infoSessionsIndexDic = [[NSMutableDictionary alloc] init];
        return _infoSessionsIndexDic;
    } else {
        return _infoSessionsIndexDic;
    }
}

- (void)clearInfoSessions {
    _infoSessions = @[];
    _infoSessionsDictionary = nil;
    _currentTerm = nil;
    [self setYearAndTerm];
    [self.delegate infoSessionModeldidUpdateFailed:self];
}

- (NSString *)apiKey {
    if (_apiKey == nil) {
        _apiKey = @"0";
    }
    return _apiKey;
}

- (NSString *)infoSessionBaseURLString {
    if (_infoSessionBaseURLString == nil) {
        _infoSessionBaseURLString = @"http://uw-info1.appspot.com/";
    }
    return _infoSessionBaseURLString;
}

- (void)switchInfoSessionBaseURLString {
    NSLog(@"switch!");
    if ([self.infoSessionBaseURLString isEqual:@"http://uw-info1.appspot.com/"]) {
        self.infoSessionBaseURLString = @"http://uw-info2.appspot.com/";
    } else if ([self.infoSessionBaseURLString isEqual:@"http://uw-info2.appspot.com/"]) {
        self.infoSessionBaseURLString = @"http://uw-info1.appspot.com/";
    }
    NSLog(@"switched to %@", self.infoSessionBaseURLString);
}

/**
 *  Initiate NSArray sessions.
 *
 *  @param block
 *
 *  @return
 */
//+ (NSURLSessionTask *)infoSessions:(NSInteger)year andTerm:(NSString *)term withBlock:(void (^)(NSArray *sessions, NSString *currentTerm, NSError *error))block{
//    NSString *getTarget;
//    if (year == 0 || term == nil) {
//        getTarget = @"infosessions.json";
//    } else {
//        getTarget = [NSString stringWithFormat:@"infosessions/%ld%@.json", (long)year, term];
//    }
//    return [[UWInfoSessionClient sharedInfoSessionClient] GET:getTarget parameters:@{@"key" : myApiKey} success:^(NSURLSessionDataTask * __unused task, id JSON) {
//        //response array from jason
//        NSArray *infoSessionsFromResponse = [JSON valueForKeyPath:@"data"];
//        NSString *currentTerm = [JSON valueForKeyPath:@"meta.term"];
//
//        // new empty array to store infoSessions
//        NSMutableArray *mutableInfoSessions = [NSMutableArray arrayWithCapacity:[infoSessionsFromResponse count]];
//        
//        for (NSDictionary *attributes in infoSessionsFromResponse) {
//            InfoSession *infoSession = [[InfoSession alloc] initWithAttributes:attributes];
//            // if start time < end time or date is nil, do not add
//            if (!([infoSession.startTime compare:infoSession.endTime] != NSOrderedAscending ||
//                  infoSession.date == nil ||
//                  [infoSession.employer length] == 0)) {
//                [mutableInfoSessions addObject:infoSession];
//            }
//        }
//        
//        if (block) {
//            // sorted info sessions in ascending order with start time
//            [mutableInfoSessions sortUsingComparator:^(InfoSession *info1, InfoSession *info2){
//                return [info1 compareTo:info2];
//            }];
//            
//            //[mutableInfoSessions sortedArrayUsingSelector:@selector(compareTo:)];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"infoSessionsChanged" object:self];
//            block([NSArray arrayWithArray:mutableInfoSessions], currentTerm, nil);
//        }
//    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
//        if (block) {
//            block([NSArray array], nil, error);
//        }
//    }];
//}

/**
 *  To be called after self.infoSessions is initiated.
 *  initiated self.infoSessionsDictionary with key: weekNum, value: corronsponding infoSession
 */
- (void)processInfoSessionsDictionary:(NSMutableDictionary *)dictionary withInfoSessions:(NSArray *)array {
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
 *  process the index dictionary, key is "A" ,"B", "C"
 *  process the index array
 */
- (void)processInfoSessionsIndexDic {
    [_infoSessionsIndexDic removeAllObjects];
    for (InfoSession *eachSession in _infoSessions) {
        NSString *key = [[eachSession.employer substringToIndex:1] capitalizedString];
        char keyChar = [key characterAtIndex:0];
        if (!(keyChar >= 'A' && keyChar <= 'Z')) {
            key = @"#";
        }
        // if key not exist
        if (self.infoSessionsIndexDic[key] == nil) {
            [self.infoSessionsIndexDic setValue:[[NSMutableArray alloc] initWithObjects:eachSession, nil] forKey:key];
        } else {
            // key exists
            NSComparator comparator = ^(InfoSession *info1, InfoSession *info2) {
                NSComparisonResult compareResult = [[info1.employer capitalizedString] compare:[info2.employer capitalizedString]];
                if (compareResult == NSOrderedSame) {
                    compareResult = [info1.startTime compare:info2.startTime];
                }
                return compareResult;
            };
            
            NSUInteger newIndex = [self.infoSessionsIndexDic[key] indexOfObject:eachSession
                                                                  inSortedRange:(NSRange){0, [self.infoSessionsIndexDic[key] count]}
                                                                        options:NSBinarySearchingInsertionIndex
                                                                usingComparator:comparator];
            
            [self.infoSessionsIndexDic[key] insertObject:eachSession atIndex:newIndex];
        }
    }
    
    _infoSessionsIndexed = [_infoSessions sortedArrayUsingComparator:^(InfoSession *info1, InfoSession *info2) {
        NSComparisonResult compareResult = [[info1.employer capitalizedString] compare:[info2.employer capitalizedString]];
        if (compareResult == NSOrderedSame) {
            compareResult = [info1.startTime compare:info2.startTime];
        }
        return compareResult;
    }];
}

/**
 *  check whether this infoSession exist in array
 *
 *  @param infoSession an InfoSession instance
 *  @param array       array of InfoSessions
 *
 *  @return -1, if not found, else, return index
 */
+ (NSInteger)findInfoSession:(InfoSession *)infoSession in:(NSArray *)array {
    NSInteger existIndex = -1;
    NSInteger count = [array count];
    for (int i = 0; i < count; i++) {
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


- (UW)deleteInfoSessionInMyInfo:(InfoSession *)infoSession{
    NSInteger existIndex = [InfoSessionModel findInfoSession:infoSession in:self.myInfoSessions];
    if (existIndex != -1) {
        [infoSession cancelNotifications];
        // if infoSessions in tab1 contains infoSession to be delete, clear the user defined information
        NSInteger existIndexInInfoSessions = [InfoSessionModel findInfoSession:infoSession in:self.infoSessions];
        if (existIndexInInfoSessions != -1) {
            InfoSession *theInfo = self.infoSessions[existIndexInInfoSessions];
            theInfo.alertIsOn = NO;
            theInfo.note = nil;
        }
        [self.myInfoSessions removeObjectAtIndex:existIndex];
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

/**
 *  Handle for the first time, used for save map.
 */
- (void)handleFirstTime {
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

+ (NSString *)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

+ (NSString *)cachesDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths firstObject];
    return cachesDirectory;
}

+ (NSString*)dataFilePath:(NSString *)fileName{
    return [[self documentsDirectory] stringByAppendingPathComponent:fileName];
}

+ (void)saveMap {
    NSData *pngData = UIImagePNGRepresentation([UIImage imageNamed:@"map_colour300.png"]);
//    [pngData writeToFile:[self dataFilePath:@"uw_map.png"] atomically:YES];
    [pngData writeToFile:[[self cachesDirectory] stringByAppendingPathComponent:@"uw_map.png"] atomically:YES];
}

+ (UIImage *)loadMap {
    
//    NSData *pngData = [NSData dataWithContentsOfFile:[self dataFilePath:@"uw_map.png"]];
    NSData *pngData = [NSData dataWithContentsOfFile:[[self cachesDirectory] stringByAppendingPathComponent:@"uw_map.png"]];
    return [UIImage imageWithData:pngData];
}

+ (BOOL)checkMap {
//    NSString *path = [InfoSessionModel dataFilePath:@"uw_map.png"];
    NSString *path = [[self cachesDirectory] stringByAppendingPathComponent:@"uw_map.png"];
    return [[NSFileManager defaultManager]fileExistsAtPath:path];
}

- (void)saveInfoSessions {
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:_infoSessions forKey:@"infoSessions"];
    [archiver encodeObject:_infoSessionsDictionary forKey:@"infoSessionsDictionary"];
    [archiver encodeObject:_myInfoSessions forKey:@"myInfoSessions"];
    [archiver encodeObject:_currentTerm forKey:@"currentTerm"];
    [archiver encodeInteger:_year forKey:@"year"];
    [archiver encodeObject:_term forKey:@"term"];
    [archiver encodeObject:_termInfoDic forKey:@"termInfoDic"];
    [archiver encodeObject:_apiKey forKey:@"apiKey"];
    [archiver encodeObject:_uwUsername forKey:@"uwUsername"];
    [archiver encodeObject:_uwPassword forKey:@"uwPassword"];
    [archiver encodeBool:_uwValid forKey:@"uwValid"];
    [archiver finishEncoding];
    [data writeToFile:[InfoSessionModel dataFilePath:@"InfoSession.plist"] atomically:YES];
}

- (void)saveMyInfoSessions {
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:_myInfoSessions forKey:@"myInfoSessions"];
    [archiver finishEncoding];
    [data writeToFile:[InfoSessionModel dataFilePath:@"InfoSession.plist"] atomically:YES];
}

- (void)loadInfoSessions {
    NSString *path = [InfoSessionModel dataFilePath:@"InfoSession.plist"];
    if([[NSFileManager defaultManager]fileExistsAtPath:path]){
        NSData *data =[[NSData alloc]initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        //_infoSessions = [unarchiver decodeObjectForKey:@"infoSessions"];
        //_infoSessionsDictionary = [unarchiver decodeObjectForKey:@"infoSessionsDictionary"];
        _myInfoSessions = [unarchiver decodeObjectForKey:@"myInfoSessions"];
        _currentTerm = [unarchiver decodeObjectForKey:@"currentTerm"];
        _year = [unarchiver decodeIntegerForKey:@"year"];
        _term = [unarchiver decodeObjectForKey:@"term"];
        _termInfoDic = [unarchiver decodeObjectForKey:@"termInfoDic"];
        _apiKey = [unarchiver decodeObjectForKey:@"apiKey"];
        _uwUsername = [unarchiver decodeObjectForKey:@"uwUsername"];
        _uwPassword = [unarchiver decodeObjectForKey:@"uwPassword"];
        _uwValid = [unarchiver decodeBoolForKey:@"uwValid"];
    
        [unarchiver finishDecoding];
    }else{
        //self.lists = [[NSMutableArray alloc]initWithCapacity:20];
    }

}

/**
 *  Update my info sessions' information if saved info sessions's information is obselted.
 */
- (void)updateMyInfoSessions {
    for (InfoSession *eachInfoSession in _myInfoSessions) {
        NSInteger existIndex = [InfoSessionModel findInfoSession:eachInfoSession in:(NSMutableArray *)_infoSessions];
        if (existIndex != -1) {
            NSLog(@"updating...");
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
        self.currentTerm = [aDecoder decodeObjectForKey:@"currentTerm"];
        self.year = [aDecoder decodeIntegerForKey:@"year"];
        self.term = [aDecoder decodeObjectForKey:@"term"];
        self.termInfoDic = [aDecoder decodeObjectForKey:@"termInfoDic"];
        self.apiKey = [aDecoder decodeObjectForKey:@"apiKey"];
        self.uwValid = [aDecoder decodeBoolForKey:@"uwValid"];
        self.uwUsername = [aDecoder decodeObjectForKey:@"uwUsername"];
        self.uwPassword = [aDecoder decodeObjectForKey:@"uwPassword"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.infoSessions forKey:@"infoSessions"];
    [aCoder encodeObject:self.infoSessionsDictionary forKey:@"infoSessionsDictionary"];
    [aCoder encodeObject:self.myInfoSessions forKey:@"myInfoSessions"];
    [aCoder encodeObject:self.currentTerm forKey:@"currentTerm"];
    [aCoder encodeInteger:self.year forKey:@"year"];
    [aCoder encodeObject:self.term forKey:@"term"];
    [aCoder encodeObject:self.termInfoDic forKey:@"termInfoDic"];
    [aCoder encodeObject:self.apiKey forKey:@"apiKey"];
    [aCoder encodeBool:self.uwValid forKey:@"uwValid"];
    [aCoder encodeObject:self.uwUsername forKey:@"uwUsername"];
    [aCoder encodeObject:self.uwPassword forKey:@"uwPassword"];
}

/**
 *  set year and term using currentTerm
 */
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

/**
 *  save new term's info sessions to dictionary
 */
- (void)saveToTermInfoDic {
    [self.termInfoDic setValue:[_infoSessions copy] forKey:[_currentTerm copy]];
    [self.termInfoDic setValue:[NSDate date] forKey:[NSString stringWithFormat:@"%@ - QueriedTime", _currentTerm]];
    [self saveInfoSessions];
}

/**
 *  if this term's info sessions haved been saved befor, return it
 *
 *  @param term term string
 *
 *  @return YES if info session is set successfully, NO otherwise
 */
- (BOOL)readInfoSessionsWithTerm:(NSString *)term{
    //NSLog(@"readInfoSessionsWithTerm: %@", term);
    NSInteger existIndex = -1;
    NSInteger index = 0;
    for (NSString *key in self.termInfoDic) {
        if ([key isEqualToString:term]) {
            existIndex = index;
            break;
        }
        index++;
    }
    // this term not exists
    if (existIndex == -1) {
        return NO;
    } else {
        // if last queried time is 20m ago, then need connect to network to refresh
        NSInteger intervalForRefresh = 60 * 20;
        NSDate *lastQueriedTime = [self.termInfoDic objectForKey:[NSString stringWithFormat:@"%@ - QueriedTime", term]];
        ;
        if (isOffLineMode == NO && [[NSDate date] timeIntervalSinceDate:lastQueriedTime] > intervalForRefresh) {
            //NSLog(@"data is too old");
            return NO;
        } else {
            //NSLog(@"read term successfully");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"infoSessionsChanged" object:self];
            _infoSessions = [self.termInfoDic[term] copy];
            [self.infoSessionsDictionary removeAllObjects];
            [self processInfoSessionsDictionary:self.infoSessionsDictionary withInfoSessions:self.infoSessions];
            _currentTerm = [term copy];
            [self setYearAndTerm];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"infoSessionsChanged" object:self];
            [self.delegate infoSessionModeldidUpdateInfoSessions:self];
            return YES;
        }
    }
}

#pragma mark - UWInfoSessionClient connection

- (void)setApiKey {
    UWInfoSessionClient *apiClient = [UWInfoSessionClient sharedApiKeyClient];
    apiClient.delegate = self;
    [apiClient getApiKey];
}

- (void)updateInfoSessionsWithYear:(NSInteger)year andTerm:(NSString *)term {
    if (isOffLineMode == NO) {
        //    NSLog(@"start to update");
        _year = year;
        _term = term;
        if ([self.apiKey isEqualToString:@"0"]) {
            // if key is not vaild
            // first to look up parse keys
            PFQuery *queryForId = [PFQuery queryWithClassName:@"Device"];
            [queryForId whereKey:@"Identifier" equalTo:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            [queryForId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if (objects.count == 0) {
                        NSLog(@"Queried with identifier, but no match found");
                        PFQuery *queryForDeviceName = [PFQuery queryWithClassName:@"Device"];
                        [queryForDeviceName whereKey:@"Device_Name" equalTo:[[UIDevice currentDevice] name]];
                        [queryForDeviceName findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                if (objects.count == 0) {
                                    NSLog(@"Queried with device name, but no match found");
                                    [self setApiKey];
                                } else {
                                    for (PFObject *object in objects) {
                                        if (object[@"Query_Key"] == nil) {
                                            NSLog(@"Queried, Found key: nil");
                                            [self setApiKey];
                                        } else {
                                            self.apiKey = object[@"Query_Key"];
                                            NSLog(@"Queried, Found key: %@", self.apiKey);
                                            if ([self.apiKey isEqualToString:@"0"]) {
                                                self.apiKey = @"1";
                                                [UWErrorReport reportErrorWithDescription:@"Wrong key: 0, set 1 insted (Set key: Device_Name)"];
                                            }
                                            [self updateInfoSessionsWithYear:_year andTerm:_term];
                                            return;
                                        }
                                    }
                                }
                            } else {
                                // Log details of the failure
                                NSLog(@"Error: %@ %@", error, [error userInfo]);
                                [UWErrorReport reportErrorWithDescription:[NSString stringWithFormat:@"Set Key, device name error: %@ %@", error, [error userInfo]]];
                                [self setApiKey];
                                
                            }
                        }];
                    } else {
                        for (PFObject *object in objects) {
                            self.apiKey = object[@"Query_Key"];
                            NSLog(@"Queried, Found key: %@", self.apiKey);
                            if ([self.apiKey isEqualToString:@"0"]) {
                                self.apiKey = @"1";
                                [UWErrorReport reportErrorWithDescription:@"Wrong key: 0, set 1 insted (Set key: Device_Identifier)"];
                            }
                            [self updateInfoSessionsWithYear:_year andTerm:_term];
                            return;
                        }
                    }
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    [UWErrorReport reportErrorWithDescription:[NSString stringWithFormat:@"Set Key, device identifier error: %@ %@", error, [error userInfo]]];
                    [self setApiKey];
                }
            }];
            //  NSLog(@"key is 0");
            
        }
        else {
            //        NSLog(@"key is %@", self.apiKey);
            
            UWInfoSessionClient *client = [UWInfoSessionClient infoSessionClientWithBaseURL:[NSURL URLWithString:self.infoSessionBaseURLString]];
            client.delegate = self;
            [client updateInfoSessionsForYear:year andTerm:term andApiKey:self.apiKey];
        }
    } else {
        [self updateUnderOfflineMode:year andTerm:term];
    }

}

-(void)infoSessionClient:(UWInfoSessionClient *)client didUpdateWithData:(id)data {
    NSArray *infoSessionsFromResponse = [data valueForKeyPath:@"data"];
    NSString *currentTerm = [data valueForKeyPath:@"meta.term"];
    
    // new empty array to store infoSessions
    NSMutableArray *mutableInfoSessions = [NSMutableArray arrayWithCapacity:[infoSessionsFromResponse count]];
    
    for (NSDictionary *attributes in infoSessionsFromResponse) {
        InfoSession *infoSession = [[InfoSession alloc] initWithAttributes:attributes];
        // if start time < end time or date is nil, do not add
        if (!([infoSession.startTime compare:infoSession.endTime] != NSOrderedAscending ||
              infoSession.date == nil ||
              [infoSession.employer length] == 0 ||
              [infoSession.employer isEqualToString:@"First day of lectures"] || [infoSession.employer isEqualToString:@"Last day of lectures"])) {
            [mutableInfoSessions addObject:infoSession];
        }
    }
    
    // sorted info sessions in ascending order with start time
    [mutableInfoSessions sortUsingComparator:^(InfoSession *info1, InfoSession *info2){
        return [info1 compareTo:info2];
    }];
    
    self.infoSessions = mutableInfoSessions;
    self.currentTerm = currentTerm;
    [self setYearAndTerm];
    
    // process infoSessionsDictionary, used for dividing infoSessions into different weeks
    [self.infoSessionsDictionary removeAllObjects];
    [self processInfoSessionsDictionary:self.infoSessionsDictionary withInfoSessions:self.infoSessions];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // update my infoSessions, if same info sessions have been saved before, update to newest information
        [self updateMyInfoSessions];
    });
    // save to TermDic.
    [self saveToTermInfoDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"infoSessionsChanged" object:self];
    [self.delegate infoSessionModeldidUpdateInfoSessions:self];
}

// only called when 503 is return
-(void)infoSessionClient:(UWInfoSessionClient *)client didFailWithCode:(NSInteger)code {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Info Sessions"
//                                                        message:[NSString stringWithFormat:@"%@",error]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
    if (code == 503 || code == 500) {
        [self switchInfoSessionBaseURLString];
    } else if (code == -1) {
        isOffLineMode = YES;
    } else if (code == 1) {
        //retry
    }
    [self updateInfoSessionsWithYear:_year andTerm:_term];
    
}

-(void)apiClient:(UWInfoSessionClient *)client didUpdateWithApiKey:(NSString *)apiKey {
//    NSLog(@"set key %@", apiKey);
    self.apiKey = (NSString *)[apiKey copy];
//    NSLog(@"update again");
    // add key to parseObject
    PFQuery *queryForId = [PFQuery queryWithClassName:@"Device"];
    [queryForId whereKey:@"Identifier" equalTo:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [queryForId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 0) {
                NSLog(@"never reach");
                [UWErrorReport reportErrorWithDescription:@"didUpdateWithApiKey, but identifier not found"];
                PFQuery *queryForDeviceName = [PFQuery queryWithClassName:@"Device"];
                [queryForDeviceName whereKey:@"Device_Name" equalTo:[[UIDevice currentDevice] name]];
                [queryForDeviceName findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        if (objects.count == 0) {
                            NSLog(@"never never reach");
                        } else {
                            for (PFObject *object in objects) {
                                object[@"Query_Key"] = self.apiKey;
                                [object saveEventually];
                            }
                        }
                    } else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        [UWErrorReport reportErrorWithDescription:[NSString stringWithFormat:@"didUpdateWithApiKey, device name error: %@ %@", error, [error userInfo]]];
                    }
                }];
            } else {
                for (PFObject *object in objects) {
                    object[@"Query_Key"] = self.apiKey;
                    [object saveEventually];
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [UWErrorReport reportErrorWithDescription:[NSString stringWithFormat:@"didUpdateWithApiKey, device identifier error: %@ %@", error, [error userInfo]]];
        }
    }];
    [self updateInfoSessionsWithYear:_year andTerm:_term];
}

-(void)apiClient:(UWInfoSessionClient *)client didFailWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet connection error"
                                                        message:@"Please check your Internet connection and try again"
                                                       delegate:self
                                              cancelButtonTitle:@"Try again" otherButtonTitles:nil];
    alertView.tag = 1;
    [alertView show];
}

- (void)setOfflineMode:(BOOL)isOff {
    isOffLineMode = isOff;
}

- (void)updateUnderOfflineMode:(NSInteger)year andTerm:(NSString *)term {
    if ([self readInfoSessionsWithTerm:[NSString stringWithFormat:@"%ld %@", (long)year, term]] == YES) {
        //NSLog(@"offline Mode updated successfully");
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No offline data available"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [self clearInfoSessions];
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // api key retrive failed, try again
    if (alertView.tag == 1 && buttonIndex == 0) {
        [self updateInfoSessionsWithYear:_year andTerm:_term];
    }
}

#pragma mark - other

- (InfoSession *)getPreviousInfoSessionAccordingInfoSession:(InfoSession *)info {
    NSLog(@"%@", info.employer);
    for (NSString *key in _infoSessionsDictionary) {
        NSMutableArray *infoSessionsOfThisWeek = _infoSessionsDictionary[key];
        NSLog(@"count: %d", [infoSessionsOfThisWeek count]);
        for (InfoSession *eachInfo in infoSessionsOfThisWeek) {
            //NSLog(@"%@", eachInfo.employer);
            if (info == eachInfo) {
                if ([infoSessionsOfThisWeek firstObject] == info) {
                    NSLog(@"first info of a week");
                    NSString *preKey = NSIntegerToString([key integerValue] - 1);
                    // if this week is the first week
                    if (_infoSessionsDictionary[preKey] == nil) {
                        return nil;
                    } else {
                        return (InfoSession *)[_infoSessionsDictionary[preKey] lastObject];
                    }
                }
                else {
                    NSInteger index = [infoSessionsOfThisWeek indexOfObject:info];
                    return [infoSessionsOfThisWeek objectAtIndex:index - 1];
                }
            }
        }
    }
    return nil;
}

- (InfoSession *)getNextInfoSessionAccordingInfoSession:(InfoSession *)info {
    for (NSString *key in _infoSessionsDictionary) {
        NSMutableArray *infoSessionsOfThisWeek = _infoSessionsDictionary[key];
        NSLog(@"count: %d", [infoSessionsOfThisWeek count]);
        for (InfoSession *eachInfo in infoSessionsOfThisWeek) {
            //NSLog(@"%@", eachInfo.employer);
            if (info == eachInfo) {
                if ([infoSessionsOfThisWeek lastObject] == info) {
                    NSLog(@"last info of a week");
                    NSString *nextKey = NSIntegerToString([key integerValue] + 1);
                    // if this week is the first week
                    if (_infoSessionsDictionary[nextKey] == nil) {
                        return nil;
                    } else {
                        return (InfoSession *)[_infoSessionsDictionary[nextKey] firstObject];
                    }
                }
                else {
                    NSInteger index = [infoSessionsOfThisWeek indexOfObject:info];
                    return [infoSessionsOfThisWeek objectAtIndex:index + 1];
                }
            }
        }
    }
    return nil;
}

@end
