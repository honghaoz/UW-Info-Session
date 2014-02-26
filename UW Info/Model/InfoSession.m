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

static EKEventStore *eventStore;

@interface InfoSession()

@property (nonatomic, readwrite, assign) NSUInteger sessionId;
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

#pragma mark - query Dictionary (Alert related)

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

#pragma make - Initiate a new InfoSession instance

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
    self.sessionId = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    //NSLog(@"%i", self.SessionId);
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

//- (NSURL *)logoImageURL {
//    return [NSURL URLWithString:[NSString stringWithFormat:@"http://g.etfv.co/%@", self.website]];
//}

#pragma mark - Other helper methods

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

/**
 *  Compare to another infoSession, according startTime
 *
 *  @param anotherInfoSession InfoSession
 *
 *  @return NSComparisonResult
 */
- (NSComparisonResult)compareTo:(InfoSession *)anotherInfoSession {
    return [self.startTime compare:anotherInfoSession.startTime];
}

/**
 *  Compare to another infoSession, based id and date
 *
 *  @param anotherInfoSession anotherInfoSession
 *
 *  @return BOOL
 */
- (BOOL)isEqual:(InfoSession *)anotherInfoSession {
    if (anotherInfoSession == nil) {
        return NO;
    }
    else if (self.sessionId == anotherInfoSession.sessionId) {
        // if session ID is valid and same
        if (self.sessionId > 10) {
            return YES;
        }
        // else session ID is not valid (no sessionID)
        else {
            if ([self.employer isEqualToString:anotherInfoSession.employer] &&
                [self.date isEqualToDate:anotherInfoSession.date] &&
                [self.startTime isEqualToDate:anotherInfoSession.startTime] &&
                [self.endTime isEqualToDate:anotherInfoSession.endTime]) {
                return YES;
            }
        }
    } else {
        return NO;
    }
    return NO;
}

/**
 *  Detect whether one infosession is have the same editable data
 *
 *  @param anotherInfoSession anotherInfoSession
 *
 *  @return NO, if infomation is the same, else, YES
 */
- (BOOL)isChangedCompareTo:(InfoSession *)anotherInfoSession {
    if (self.alertIsOn == anotherInfoSession.alertIsOn &&
        [self.alerts isEqualToArray:anotherInfoSession.alerts] &&
        (self.note == anotherInfoSession.note || [self.note isEqualToString:anotherInfoSession.note])) {
        return NO;
    }
    else {
        return YES;
    }
}

/**
 *  Static variable eventStore, only initiate once.
 *
 *  @return EKEventStore instance
 */
+ (EKEventStore *)eventStore {
    if (eventStore == nil) {
        eventStore = [[EKEventStore alloc] init];
        return eventStore;
    } else {
        return eventStore;
    }

}

#pragma mark - Alerts related methods

/**
 *  Create new alert Dictionary, which is an elements of self.alerts
 *
 *  @param choice alertChoice, to match the alertChoiceDictionary
 *
 *  @return return the a new alertDictionary
 */
- (NSMutableDictionary *)createNewAlertDictionaryWithChoice:(NSInteger)choice {
    return [[NSMutableDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:choice], [NSNumber numberWithDouble:[[InfoSession alertIntervalDictionary][NSIntegerToString(choice)] doubleValue]]] forKeys:@[@"alertChoice", @"alertInterval"]];
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
            //NSLog(@"offset %f", [eachAlert[@"alertInterval"] doubleValue]);
            [ekalarms addObject:[EKAlarm alarmWithRelativeOffset:[eachAlert[@"alertInterval"] doubleValue]]];
        }
        return ekalarms;
    }
    return nil;
}

#pragma mark - NSCopying Protocol method

/**
 *  NSCopying Protocal method, make a copy of InfoSession object (ekEvent is not copied!!!)
 *
 *  @param zone zone description
 *
 *  @return new InfoSession object
 */
- (id)copyWithZone:(NSZone *)zone {
    // allocate new copy
    InfoSession *copy = [[InfoSession alloc] init];
    // for Integer/ NSsstrin/ NSDate/ BOOL, just use copy or assgin directly
    copy.sessionId = self.sessionId;
    copy.employer = [self.employer copy];
    copy.date = [self.date copy];
    copy.startTime = [self.startTime copy];
    copy.endTime = [self.endTime copy];
    copy.location = [self.location copy];
    copy.website = [self.website copy];
    copy.audience = [self.audience copy];
    copy.programs = [self.programs copy];
    copy.description = [self.description copy];
    copy.weekNum = self.weekNum;
    copy.isCancelled = self.isCancelled;
    copy.alertIsOn = self.alertIsOn;
    
    // allocate a new alerts for this copy
    copy.alerts = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *eachAlert in self.alerts) {
        NSMutableDictionary *newAlert = [[NSMutableDictionary alloc] init];
        NSNumber *newChoice = [[NSNumber alloc] initWithInteger:[eachAlert[@"alertChoice"] integerValue]];
        [newAlert setObject:newChoice forKey:@"alertChoice"];
        
        NSNumber *newInterval = [[NSNumber alloc] initWithDouble:[eachAlert[@"alertInterval"] doubleValue]];
        [newAlert setObject:newInterval forKey:@"alertInterval"];
        [copy.alerts addObject:newAlert];
    }
    // !!! ekEvent is not conform NSCopying Protocol, so, need process specially
    if (self.ekEvent == nil) {
        copy.ekEvent = nil;
    } else {
        copy.ekEvent = [EKEvent eventWithEventStore:eventStore];
        copy.ekEvent = [eventStore eventWithIdentifier:self.ekEvent.eventIdentifier];
        [copy.ekEvent setTitle:[self.ekEvent.title copy]];
        [copy.ekEvent setLocation:[self.ekEvent.location copy]];
        [copy.ekEvent setStartDate:[self.ekEvent.startDate copy]];
        [copy.ekEvent setEndDate:[self.ekEvent.endDate copy]];
        [copy.ekEvent setAlarms:[self.ekEvent.alarms copy]];
        [copy.ekEvent setURL:[self.ekEvent.URL copy]];
        [copy.ekEvent setNotes:[self.ekEvent.notes copy]];
        
        [copy.ekEvent setCalendar:[eventStore calendarWithIdentifier:self.ekEvent.calendarItemIdentifier]];
    }
    copy.calendarId = [self.calendarId copy];
    copy.eventId = [self.eventId copy];
    copy.note = [self.note copy];
    return copy;
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.sessionId = [aDecoder decodeIntegerForKey:@"sessionId"];
        self.employer = [aDecoder decodeObjectForKey:@"employer"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.website = [aDecoder decodeObjectForKey:@"website"];
        self.audience = [aDecoder decodeObjectForKey:@"audience"];
        self.programs = [aDecoder decodeObjectForKey:@"programs"];
        self.description = [aDecoder decodeObjectForKey:@"description"];
        
        self.weekNum = [aDecoder decodeIntegerForKey:@"weekNum"];
        self.isCancelled = [aDecoder decodeBoolForKey:@"isCancelled"];
        self.alertIsOn = [aDecoder decodeBoolForKey:@"alertIsOn"];
        self.alerts = [aDecoder decodeObjectForKey:@"alerts"];
        //self.ekEvent = [aDecoder decodeObjectForKey:@"ekEvent"];
        self.calendarId = [aDecoder decodeObjectForKey:@"calendarId"];
        self.eventId = [aDecoder decodeObjectForKey:@"eventId"];
        self.note = [aDecoder decodeObjectForKey:@"note"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.sessionId forKey:@"sessionId"];
    [aCoder encodeObject:self.employer forKey:@"employer"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.website forKey:@"website"];
    [aCoder encodeObject:self.audience forKey:@"audience"];
    [aCoder encodeObject:self.programs forKey:@"programs"];
    [aCoder encodeObject:self.description forKey:@"description"];
    
    [aCoder encodeInteger:self.weekNum forKey:@"weekNum"];
    [aCoder encodeBool:self.isCancelled forKey:@"isCancelled"];
    [aCoder encodeBool:self.alertIsOn forKey:@"alertIsOn"];
    
    [aCoder encodeObject:self.alerts forKey:@"alerts"];
    //[aCoder encodeObject:self.ekEvent forKey:@"ekEvent"];
    [aCoder encodeObject:self.calendarId forKey:@"calendarId"];
    [aCoder encodeObject:self.eventId forKey:@"eventId"];
    [aCoder encodeObject:self.note forKey:@"note"];

}

#pragma mark - UILocalNotification related methods

- (NSString *)getIdentifier {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set the locale to fix the formate to read and write;
    NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    // set timezone to EST
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
    
    // set date format: 09 5, 2013
    [dateFormatter setDateFormat:@"MM-d-y"];
    
    NSString *dateString = [dateFormatter stringFromDate:self.date];

    // set time format: 1:00 PM, September 5, 2013
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *startString = [dateFormatter stringFromDate:self.startTime];
    NSString *endString = [dateFormatter stringFromDate:self.endTime];
    return [NSString stringWithFormat:@"%i-%@-%@-%@-%@", self.sessionId, self.employer, dateString, startString, endString];
}

- (void)cancelNotifications {
    NSLog(@"Start to cancel notifications");
    NSMutableArray *existingNotifications = [self notificationsForThisInfoSession];
    if (existingNotifications != nil) {
        NSLog(@"Cancel %i exist notifications", [existingNotifications count]);
        for (UILocalNotification *eachNotification in existingNotifications) {
            NSLog(@"  Canceled: %@", eachNotification);
            [[UIApplication sharedApplication] cancelLocalNotification:eachNotification];
        }
    }
}

- (void)scheduleNotifications {
    NSLog(@"Start to Schedule notifications");
    // if found notification, cancel all of them
    [self cancelNotifications];
    
    // then reschedule notifications
    if (self.alertIsOn) {
        for (NSInteger i = 0; i < [self.alerts count]; i++) {
            NSMutableDictionary *eachAlert = self.alerts[i];
            if ([eachAlert[@"alertChoice"] integerValue] > 0) {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [self.startTime dateByAddingTimeInterval:[eachAlert[@"alertInterval"] doubleValue]];
                localNotification.timeZone = [NSTimeZone timeZoneWithName:@"EST"];
                localNotification.alertBody = self.employer;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.userInfo = [NSMutableDictionary dictionaryWithObjects:@[[self getIdentifier], [NSNumber numberWithInteger:i]] forKeys:@[@"InfoId", @"Count"]];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                NSLog(@"scheduled notification for %@", [self getIdentifier]);
                NSLog(@"%@", localNotification);
            }
        }
    }
}

- (NSMutableArray*)notificationsForThisInfoSession{
    NSMutableArray *resultNotifications = [[NSMutableArray alloc] init];
    NSArray *allNotifications = [[UIApplication sharedApplication]scheduledLocalNotifications];
    for(UILocalNotification *notification in allNotifications){
        NSString *infoIdentifier = [notification.userInfo objectForKey:@"InfoId"];
        if([infoIdentifier isEqual:[self getIdentifier]]){
            [resultNotifications addObject:notification];
        }
    }
    if ([resultNotifications count] == 0) {
        return nil;
    } else {
        return resultNotifications;
    }
}
//
//-(void)dealloc{
//    NSLog(@"dealloc");
//    [self cancelNotifications];
//}

@end
