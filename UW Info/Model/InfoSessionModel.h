//
//  InfoSessionModel.h
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSession.h"
typedef NS_ENUM(NSUInteger, UW){
    UWAdded,
    UWReplaced,
    UWDeleted,
    UWNonthing
};

typedef NS_ENUM(NSUInteger, UWTerm) {
    UWWinter = 0,
    UWSpring,
    UWFall
};

@interface InfoSessionModel : InfoSession <NSCoding>

// info sessions data retrived from api
@property (nonatomic, strong) NSArray *infoSessions;
@property (nonatomic, strong) NSMutableDictionary *infoSessionsDictionary;

// user saved info sessions
@property (nonatomic, strong) NSMutableArray *myInfoSessions;
//@property (nonatomic, strong) NSMutableDictionary *myInfoSessionsDictionary;

@property (nonatomic, copy) NSString *currentTerm;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, copy) NSString *term;

@property (nonatomic, strong) NSMutableDictionary *termInfoDic;

// Used for manage calendar event, only initiate once!
//@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;

- (void)clearInfoSessions;

- (void)processInfoSessionsDictionary:(NSDictionary *)dictionary withInfoSessions:(NSArray *)array;

+ (NSURLSessionTask *)infoSessions:(NSInteger)year andTerm:(NSString *)term withBlock:(void (^)(NSArray *sessions, NSString *currentTerm, NSError *error))block;

+ (NSInteger)findInfoSession:(InfoSession *)infoSession in:(NSMutableArray *)array;
+ (NSInteger)findInfoSessionIdentifier:(NSString *)infoSessionId in:(NSMutableArray *)array;
+ (UW)addInfoSessionInOrder:(InfoSession *)infoSession to:(NSMutableArray *)array;
+ (UW)deleteInfoSession:(InfoSession *)infoSession in:(NSMutableArray *)array;

+ (NSString*)documentsDirectory;;
+ (NSString*)dataFilePath:(NSString *)fileName;
+ (void)saveMap;
+ (UIImage *)loadMap;

- (void)saveInfoSessions;
- (void)loadInfoSessions;

- (void)updateMyInfoSessions;

- (NSInteger)countFutureInfoSessions:(NSArray *)infosessions;
- (void)setYearAndTerm;

- (void)saveToTermInfoDic;
- (BOOL)readInfoSessionsWithTerm:(NSString *)term;

@end
