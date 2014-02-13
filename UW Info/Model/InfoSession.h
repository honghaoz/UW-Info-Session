//
//  InfoSession.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface InfoSession : NSObject

//attribute that not changed
@property (nonatomic, readonly, assign) NSUInteger SessionId;
@property (nonatomic, readonly, copy) NSString *employer;
@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, readonly, strong) NSDate *startTime;
@property (nonatomic, readonly, strong) NSDate *endTime;
@property (nonatomic, readonly, copy) NSString *location;
@property (nonatomic, readonly, copy) NSString *website;
@property (nonatomic, readonly, copy) NSString *audience;
@property (nonatomic, readonly, copy) NSString *programs;
@property (nonatomic, readonly, copy) NSString *description;
//@property (nonatomic, readonly, unsafe_unretained) NSURL *logoImageURL;
@property (nonatomic, readonly, assign) NSUInteger weekNum;


// alerts related attributes
+ (NSDictionary *) alertIntervalDictionary;
@property (nonatomic, assign) BOOL alertIsOn;
@property (nonatomic, strong) NSMutableArray *alerts;

// calendar EKEvent
@property (nonatomic, strong) EKEvent *calendarEvent;

// other attributes
@property (nonatomic, copy) NSString *note;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

//- (NSURL *)logoImageURL;

+ (NSURLSessionTask *)infoSessionsWithBlock:(void (^)(NSArray *sessions, NSError *error))block;

- (BOOL)addOneAlert;
- (BOOL)alertsIsFull;

- (id)getValueFromAlertDictionaryAtIndex:(NSInteger)index ForKey:(NSString *)key;
- (void)setAlertChoiceForAlertDictionaryAtIndex:(NSInteger)index newChoice:(NSInteger)alertChoice;

/**
 *  refreshAlertArray, if some alert(NSDictionary) is set alertChoice to 0 : None,
 *  remove this alert and return true;
 *  @return if removed return true.
 */
- (BOOL)isRemovedAfterRefreshingAlerts;
- (NSArray *)getEKAlarms;

@end
