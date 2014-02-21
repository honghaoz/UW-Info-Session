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

@interface InfoSession : NSObject <NSCopying, NSCoding>

//attribute that not changed
@property (nonatomic, readonly, assign) NSUInteger sessionId;
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

@property (nonatomic, assign) BOOL isCancelled;

// alerts related attributes
@property (nonatomic, assign) BOOL alertIsOn;
@property (nonatomic, strong) NSMutableArray *alerts;

// calendar EKEvent
@property (nonatomic, strong) EKEvent *ekEvent;

// other attributes
@property (nonatomic, copy) NSString *note;

// Dictionary of alerts description, interval and sequence
+ (NSDictionary *) alertChoiceDictionary;
+ (NSString *)getAlertDescription:(NSNumber *)alertChoice;
+ (NSDictionary *) alertIntervalDictionary;
+ (NSDictionary *) alertSequenceDictionary;
+ (NSString *)getAlertSequence:(NSNumber *)alertChoice;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

- (BOOL)isEqual:(InfoSession *)anotherInfoSession;

- (BOOL)isChangedCompareTo:(InfoSession *)anotherInfoSession;

//- (NSURL *)logoImageURL;
+ (NSURLSessionTask *)infoSessionsWithBlock:(void (^)(NSArray *sessions, NSError *error))block;

// alerts related methods
- (BOOL)addOneAlert;
- (BOOL)alertsIsFull;

- (id)getValueFromAlertDictionaryAtIndex:(NSInteger)index ForKey:(NSString *)key;
- (void)setAlertChoiceForAlertDictionaryAtIndex:(NSInteger)index newChoice:(NSInteger)alertChoice;

- (BOOL)isRemovedAfterRefreshingAlerts;
// calendar alerts
- (NSArray *)getEKAlarms;
@end
