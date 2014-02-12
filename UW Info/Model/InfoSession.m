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

#define MAX_NUM_OF_ALERTS 5

const NSString *apiKey =  @"abc498ac42354084bf594d52f5570977";

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
    
    self.weekNum = [self getWeekNumbe:self.date];
    
    self.location = [attributes valueForKeyPath:@"location"];
    self.website = [attributes valueForKeyPath:@"website"];
    self.audience = [attributes valueForKeyPath:@"audience"];
    self.programs = [attributes valueForKeyPath:@"programs"];
    self.description = [attributes valueForKeyPath:@"description"];
    
    NSMutableDictionary *oneAlert = [self createNewAlertDictionaryWithChoice:1];
    self.alerts = [[NSMutableArray alloc] initWithObjects:oneAlert, nil];
    return self;
    
}

/**
 *  Initiate NSArray sessions.
 *
 *  @param block
 *
 *  @return
 */
+ (NSURLSessionTask *)infoSessionsWithBlock:(void (^)(NSArray *sessions, NSError *error))block{
    
    return [[AFUwaterlooApiClient sharedClient] GET:@"resources/infosessions.json" parameters:@{@"key" : apiKey} success:^(NSURLSessionDataTask * __unused task, id JSON) {
        //response array from jason
        NSArray *infoSessionsFromResponse = [JSON valueForKeyPath:@"data"];
        // new empty array to store infoSessions
        NSMutableArray *mutableInfoSessions = [NSMutableArray arrayWithCapacity:[infoSessionsFromResponse count]];
        for (NSDictionary *attributes in infoSessionsFromResponse) {
            InfoSession *infoSession = [[InfoSession alloc] initWithAttributes:attributes];
            // if start time < end time or date is nil, do not add
            if (!([infoSession.startTime compare:infoSession.endTime] != NSOrderedAscending || infoSession.date == nil)) {
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
 *  Get the Week number of NSDate
 *
 *  @param date NSDate
 *
 *  @return NSUInteger
 */
- (NSUInteger)getWeekNumbe:(NSDate *)date {
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


- (NSMutableDictionary *)createNewAlertDictionaryWithChoice:(NSInteger)choice {
    return [[NSMutableDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:choice], [[NSDate alloc] init]] forKeys:@[@"alertChoice", @"alertDate"]];
}

- (BOOL)addOneAlert {
    if (![self alertsIsFull]) {
        NSMutableDictionary *oneAlert = [self createNewAlertDictionaryWithChoice:[self.alerts count] + 1];
        [self.alerts addObject:oneAlert];
        return YES;
    } else {
        return NO;
    }
    
}

- (BOOL)alertsIsFull {
    if ([self.alerts count] < MAX_NUM_OF_ALERTS) {
        return NO;
    } else {
        return YES;
    }
}

- (id)getValueFromAlertDictionaryAtIndex:(NSInteger)index ForKey:(NSString *)key{
    NSMutableDictionary *theAlert = self.alerts[index];
    return theAlert[key];
}

- (void)setAlertChoiceForAlertDictionaryAtIndex:(NSInteger)index newChoice:(NSInteger)alertChoice {
    NSMutableDictionary *theAlert = self.alerts[index];
    theAlert[@"alertChoice"] = [NSNumber numberWithInteger:alertChoice];
}

@end
