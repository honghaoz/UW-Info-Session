//
//  InfoSession.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSession.h"

#define MAX_NUM_OF_ALERTS 5

static NSDictionary *alertChoiceDictionary;
static NSDictionary *alertIntervalDictionary;
static NSDictionary *alertSequenceDictionary;

// used for notification "*** in 30 minutes ***"
static NSDictionary *alertDescriptionForNotificationDictionary;
// only one eventStore for all infoSession
static EKEventStore *eventStore;

@interface InfoSession()

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

+ (NSDictionary *)alertDescriptionForNotificationDictionary {
    if (alertDescriptionForNotificationDictionary == nil) {
        alertDescriptionForNotificationDictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"", @"now", @"in 5 minutes", @"in 15 minutes", @"in 30 minutes", @"in 1 hour", @"in 2 hours", @"tommorrow", @"in 2 days", @"in this week", nil] forKeys:[[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil]];
        return alertDescriptionForNotificationDictionary;
    } else {
        return alertDescriptionForNotificationDictionary;
    }
}

+ (NSString *)getAlertDescriptionForNitification:(NSNumber *)alertChoice {
    return [InfoSession alertDescriptionForNotificationDictionary][[alertChoice stringValue]];
}

#pragma make - Initiate a new InfoSession instance


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
    
    NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
    
    // set date format: September 5, 2013
    [dateFormatter setDateFormat:@"MMMM d, y"];
    
    self.date = [dateFormatter dateFromString:[attributes valueForKeyPath:@"date"]];
    // set time format: 1:00 PM, September 5, 2013
    [dateFormatter setDateFormat:@"h:mm a, MMMM d, y"];
    
    self.startTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@, %@", [attributes valueForKeyPath:@"start_time"], [attributes valueForKeyPath:@"date"]]];
    //NSLog(@"should: %@, in fact: %@", [attributes valueForKeyPath:@"start_time"], [dateFormatter stringFromDate:self.startTime]);
    //NSLog(@"now: %@", [dateFormatter stringFromDate:[NSDate date]]);
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

#pragma mark - Alerts related methods

/**
 *  Create new alert Dictionary, which is an elements of self.alerts
 *
 *  @param choice alertChoice, to match the alertChoiceDictionary
 *
 *  @return return the a new alertDictionary
 */
- (NSMutableDictionary *)createNewAlertDictionaryWithChoice:(NSInteger)choice {
    return [[NSMutableDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:choice], [NSNumber numberWithDouble:[[InfoSession alertIntervalDictionary][NSIntegerToString(choice)] doubleValue]], [NSNumber numberWithBool:NO]] forKeys:@[@"alertChoice", @"alertInterval", @"isNotified"]];
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
    theAlert[@"isNotified"] = [NSNumber numberWithBool:NO];
}

/**
 *  refreshAlertArray, if some alert(NSDictionary) is set alertChoice to 0 : None,
 *  remove this alert and return true;
 *  @return if removed return true.
 */
- (BOOL)isRemovedAfterRefreshingAlerts {
    BOOL isRemoved = NO;
    NSInteger alertsCount = [self.alerts count];
    //NSLog(@"alert count: %i", alertsCount);
    for (int i = 0; i < alertsCount; i++) {
        NSLog(@"i: %i", i);
        // get each alert
        NSMutableDictionary *theAlert = self.alerts[i];
        NSNumber *alertChoice = theAlert[@"alertChoice"];
        // update alertInterval
        theAlert[@"alertInterval"] = [NSNumber numberWithDouble:[[InfoSession alertIntervalDictionary][NSIntegerToString([alertChoice integerValue])] doubleValue]];
        // if choice is 0, delete this alert
        if ([alertChoice integerValue] == 0) {
            NSLog(@"remove an alert");
            [self.alerts removeObjectAtIndex:i];
            i--;
            alertsCount--;
            isRemoved = YES;
        }
    }
    // is no alerts is set, switch off
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

#pragma mark - UILocalNotification related methods
/**
 *  get a unique identifier string for this info session
 *
 *  @return NSString for identifier
 */
- (NSString *)getIdentifier {
    NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
    
    // set date format: 09 5, 2013
    [dateFormatter setDateFormat:@"MM-d-y"];
    
    NSString *dateString = [dateFormatter stringFromDate:self.date];
    
    // set time format: 1:00 PM, September 5, 2013
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *startString = [dateFormatter stringFromDate:self.startTime];
    NSString *endString = [dateFormatter stringFromDate:self.endTime];
    return [NSString stringWithFormat:@"%lu-%@-%@-%@-%@", (unsigned long)self.sessionId, self.employer, dateString, startString, endString];
}

/**
 *  cancel all notification
 */
- (void)cancelNotifications {
    NSMutableArray *existingNotifications = [self notificationsForThisInfoSession];
    if (existingNotifications != nil) {
        for (UILocalNotification *eachNotification in existingNotifications) {
            [[UIApplication sharedApplication] cancelLocalNotification:eachNotification];
        }
    }
}

/**
 *  schedule notifications for this info session
 */
- (void)scheduleNotifications {
    // if found notification, cancel all of them
    [self cancelNotifications];
    
    // then reschedule notifications
    if (self.alertIsOn) {
        NSMutableDictionary *eachAlert;
        NSInteger alertsCount = [self.alerts count];
        for (NSInteger i = 0; i < alertsCount; i++) {
            eachAlert = self.alerts[i];
            [eachAlert[@"isNotified"] boolValue] ? NSLog(@"isNotified") : NSLog(@"not isNotified");
            if ([eachAlert[@"alertChoice"] integerValue] > 0 && [eachAlert[@"isNotified"] boolValue] == NO) {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [self.startTime dateByAddingTimeInterval:[eachAlert[@"alertInterval"] doubleValue]];
                
                localNotification.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
                //localNotification.timeZone = [NSTimeZone timeZoneWithName:@"EST"];
//                NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
//                [dateFormatter setDateFormat:@"HH:mm"];
//                NSLog(@"%@ -- %@", [dateFormatter stringFromDate:localNotification.fireDate], [dateFormatter stringFromDate:[self.startTime dateByAddingTimeInterval:[eachAlert[@"alertInterval"] doubleValue]]]);
                
                // prepare for alertBody
                NSString *timeString = [InfoSession getAlertDescriptionForNitification:eachAlert[@"alertChoice"]];
                
                localNotification.alertBody = [NSString stringWithFormat:@"%@ %@ at %@", self.employer, timeString, self.location];
                localNotification.soundName = @"alarm.caf";
                localNotification.alertAction = @"view";
//                localNotification.alertLaunchImage = [UIImage imageNamed:@""]
                localNotification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
                localNotification.userInfo = [NSMutableDictionary dictionaryWithObjects:@[[self getIdentifier], self.employer, [NSNumber numberWithInteger:i]] forKeys:@[@"InfoId", @"Employer", @"AlertIndex"]];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                //                localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:4];
                //                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                
            }
        }
    }
}

/**
 *  get notifications for this info session
 *
 *  @return NSMutableArray of notifications
 */
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

#pragma mark - Other helper methods

/**
 *  Get the Week number of NSDate
 *
 *  @param date NSDate
 *
 *  @return NSUInteger
 */
- (NSUInteger)getWeekNumber:(NSDate *)date {
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [InfoSession estDateFormatter];
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

+ (NSDateFormatter *)estDateFormatter {
//    static NSDateFormatter *dateFormatter = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        dateFormatter = [[NSDateFormatter alloc] init];
//        // set the locale to fix the formate to read and write;
//        NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//        [dateFormatter setLocale:enUSPOSIXLocale];
//        // set timezone to EST
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
//    });
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // set the locale to fix the formate to read and write;
    NSLocale *enUSPOSIXLocale= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    // set timezone to EST
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];

    return dateFormatter;
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
        NSNumber *newIsNotified = [[NSNumber alloc] initWithDouble:[eachAlert[@"isNotified"] doubleValue]];
        [newAlert setObject:newInterval forKey:@"alertInterval"];
        [newAlert setObject:newIsNotified forKey:@"isNotified"];
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
@end
