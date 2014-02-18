//
//  InfoSession.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSession.h"
#import "AFHTTPRequestOperation.h"
#import "AFUwaterlooApiClient.h"
#import "InfoSessionModel.h"


#define MAX_NUM_OF_ALERTS 5

//const NSString *apiKey =  @"abc498ac42354084bf594d52f5570977";
//const NSString *apiKey1 =  @"913034dae16d7233dd1683713cbb4721";
const NSString *myApiKey = @"77881122";

static NSDictionary *alertChoiceDictionary;
static NSDictionary *alertIntervalDictionary;
static NSDictionary *alertSequenceDictionary;

@interface InfoSession()

@property (nonatomic, readwrite, assign) NSUInteger SessionId;
@property (nonatomic, readwrite, copy) NSString *employer;
@property (nonatomic, readwrite, strong) NSDate *date;
@property (nonatomic, readwrite, strong) NSDate *startTime;
@property (nonatomic, readwrite, strong) NSDate *endTime;
@property (nonatomic, readwrite, copy) NSString *location;
@property (nonatomic, readwrite, copy) NSString *website;
@property (nonatomic, readwrite, copy) NSString *audience;
@property (nonatomic, readwrite, copy) NSString *programs;
@property (nonatomic, readwrite, copy) NSString *description;
//@property (nonatomic, readwrite, copy) NSString *logoImageURLString;

@property (nonatomic, readwrite, assign) NSUInteger weekNum;

@end

@implementation InfoSession

// Dictionary of alerts description, interval and sequence
+ (NSDictionary *)alertChoiceDictionary {
    if (alertChoiceDictionary == nil) {
        alertChoiceDictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"None", @"At time of event", @"5 minutes before", @"15 minutes before", @"30 minutes before", @"1 hour before", @"2 hours before", @"1 day before", @"2 days before", @"1 week before", nil] forKeys:[[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil]];
        return alertChoiceDictionary;
    } else {
        return alertChoiceDictionary;
    }
}

+ (NSString *)getAlertDescription:(NSNumber *)alertChoice {
    return [InfoSession alertChoiceDictionary][[alertChoice stringValue]];
}

+ (NSDictionary *)alertIntervalDictionary {
    if (alertIntervalDictionary == nil) {
        alertIntervalDictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"0", @"0", @"-300", @"-900", @"-1800", @"-3600", @"-7200", @"-86400", @"-172800", @"-604800", nil] forKeys:[[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil]];
        return alertIntervalDictionary;
    } else {
        return alertIntervalDictionary;
    }
}

+ (NSDictionary *)alertSequenceDictionary {
    if (alertSequenceDictionary == nil) {
        alertSequenceDictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"Alert", @"Second Alert", @"Third Alert", @"Fourth Alert", @"Fifth Alert", @"Sixth Alert", @"Seventh Alert",nil] forKeys:[[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", nil]];
        return alertSequenceDictionary;
    } else {
        return alertSequenceDictionary;
    }
}

+ (NSString *)getAlertSequence:(NSNumber *)alertChoice {
    return [InfoSession alertSequenceDictionary][[alertChoice stringValue]];
}

/**
 *  Initiate NSArray sessions.
 *
 *  @param block
 *
 *  @return
 */
+ (NSURLSessionTask *)infoSessionsWithBlock:(void (^)(NSArray *sessions, NSError *error))block{
    
    return [[AFUwaterlooApiClient sharedClient] GET:@"infosessions.json" parameters:@{@"key" : myApiKey} success:^(NSURLSessionDataTask * __unused task, id JSON) {
        //response array from jason
        NSArray *infoSessionsFromResponse = [JSON valueForKeyPath:@"data"];
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
            [mutableInfoSessions sortedArrayUsingSelector:@selector(compareTo:)];
            block([NSArray arrayWithArray:mutableInfoSessions], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

/**
 *  Initiate an InfoSession instance
 *
 *  @param attributes NSDictionary from JSON
 *
 *  @return InfoSession instance
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.SessionId = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    self.employer = [attributes valueForKeyPath:@"employer"];
    
    NSString *cancelledString = @"CANCELLED";
    // is employer's name contains @"CANCELLED", then this info session is cancelled.
    if ([self.employer rangeOfString:cancelledString].location == NSNotFound) {
        self.isCancelled = NO;
    } else {
        self.isCancelled = YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set the locale to fix the formate to read and write;
    NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    // set timezone to EST
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    
    // set date format: September 5, 2013
    [dateFormatter setDateFormat:@"MMMM d, y"];
    
    self.date = [dateFormatter dateFromString:[attributes valueForKeyPath:@"date"]];
    // set time format: 1:00 PM, September 5, 2013
    [dateFormatter setDateFormat:@"h:mm a, MMMM d, y"];
    
    self.startTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@, %@", [attributes valueForKeyPath:@"start_time"], [attributes valueForKeyPath:@"date"]]];
    self.endTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@, %@", [attributes valueForKeyPath:@"end_time"], [attributes valueForKeyPath:@"date"]]];
    
    self.weekNum = [self getWeekNumber:self.date];
    
    self.location = [attributes valueForKeyPath:@"location"];
    self.website = [attributes valueForKeyPath:@"website"];
    self.audience = [attributes valueForKeyPath:@"audience"];
    self.programs = [attributes valueForKeyPath:@"programs"];
    self.description = [attributes valueForKeyPath:@"description"];
    
    //self.note = @"Taking some notes here.";
    
    self.alertIsOn = NO;
    NSMutableDictionary *oneAlert = [self createNewAlertDictionaryWithChoice:1];
    self.alerts = [[NSMutableArray alloc] initWithObjects:oneAlert, nil];
    return self;
    
}


/**
 *  Get the Week number of NSDate
 *
 *  @param date NSDate
 *
 *  @return NSUInteger
 */
- (NSUInteger)getWeekNumber:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"w"];
    return [[dateFormatter stringFromDate:date] intValue];
}

//- (NSURL *)logoImageURL {
//    return [NSURL URLWithString:[NSString stringWithFormat:@"http://g.etfv.co/%@", self.website]];
//}


/**
 *  Compare to another inforsession, according startTime
 *
 *  @param anotherInfoSession InfoSession
 *
 *  @return NSComparisonResult
 */
- (NSComparisonResult)compareTo:(InfoSession *)anotherInfoSession {
    return [self.startTime compare:anotherInfoSession.startTime];
}

/**
 *  Create new alert Dictionary, which is an elements of self.alerts
 *
 *  @param choice alertChoice, to match the alertChoiceDictionary
 *
 *  @return return the a new alertDictionary
 */
- (NSMutableDictionary *)createNewAlertDictionaryWithChoice:(NSInteger)choice {
    return [[NSMutableDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:choice],[NSNumber numberWithDouble:[[InfoSession alertIntervalDictionary][NSIntegerToString(choice)] doubleValue]]] forKeys:@[@"alertChoice", @"alertInterval"]];
}

/**
 *  Add a new alert Dictionary to self.alerts
 *
 *  @return if self.alerts if full, return false, otherwise, true
 */
- (BOOL)addOneAlert {
    if (![self alertsIsFull]) {
        NSMutableDictionary *oneAlert = [self createNewAlertDictionaryWithChoice:[self.alerts count] + 1];
        [self.alerts addObject:oneAlert];
        return YES;
    } else {
        return NO;
    }
    
}

/**
 *  check whether self.alerts is full
 *
 *  @return ture - self.alerts is full, false, otherwise
 */
- (BOOL)alertsIsFull {
    if ([self.alerts count] < MAX_NUM_OF_ALERTS) {
        return NO;
    } else {
        return YES;
    }
}

/**
 *  Use index in self.alerts and key to get the value store in the alertDictionary
 *
 *  @param index index in self.alerts
 *  @param key   key in alertDictionary
 *
 *  @return value for that key
 */
- (id)getValueFromAlertDictionaryAtIndex:(NSInteger)index ForKey:(NSString *)key{
    NSMutableDictionary *theAlert = self.alerts[index];
    return theAlert[key];
}

/**
 *  Set the alertChoice for the alertDictionary at the index of self.alerts
 *
 *  @param index       index in self.alerts
 *  @param alertChoice the choice want to change to.
 */
- (void)setAlertChoiceForAlertDictionaryAtIndex:(NSInteger)index newChoice:(NSInteger)alertChoice {
    NSMutableDictionary *theAlert = self.alerts[index];
    theAlert[@"alertChoice"] = [NSNumber numberWithInteger:alertChoice];
}

/**
 *  refreshAlertArray, if some alert(NSDictionary) is set alertChoice to 0 : None,
 *  remove this alert and return true;
 *  @return if removed return true.
 */
- (BOOL)isRemovedAfterRefreshingAlerts {
    BOOL isRemoved = NO;
    for (int i = 0; i < [self.alerts count]; i++) {
        NSMutableDictionary *theAlert = self.alerts[i];
        NSNumber *alertChoice = theAlert[@"alertChoice"];
        
        theAlert[@"alertInterval"] = [NSNumber numberWithDouble:[[InfoSession alertIntervalDictionary][NSIntegerToString([alertChoice integerValue])] doubleValue]];
        
        if ([alertChoice integerValue] == 0) {
            [self.alerts removeObjectAtIndex:i];
            i--;
            isRemoved = YES;
        }
    }
    if ([self.alerts count] == 0) {
        self.alertIsOn = NO;
    }
    return isRemoved;
}

/**
 *  Get an array of EKAlarm, used for set calendar event's alerts
 *
 *  @return an array of EKAlarm from self.alerts
 */
- (NSArray *)getEKAlarms {
    if (self.alertIsOn) {
        NSMutableArray *ekalarms = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *eachAlert in self.alerts) {
            NSLog(@"offset %f", [eachAlert[@"alertInterval"] doubleValue]);
            [ekalarms addObject:[EKAlarm alarmWithRelativeOffset:[eachAlert[@"alertInterval"] doubleValue]]];
        }
        return ekalarms;
    }
    return nil;
}

@end
