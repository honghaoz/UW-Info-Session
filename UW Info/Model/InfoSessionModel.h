//
//  InfoSessionModel.h
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSession.h"
#import "UWInfoSessionClient.h"
@class InfoSessionModel;

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

@protocol InfoSessionModelDelegate <NSObject>

- (void)infoSessionModeldidUpdateInfoSessions:(InfoSessionModel *)model;
- (void)infoSessionModeldidUpdateFailed:(InfoSessionModel *)model;

@end

@interface InfoSessionModel : InfoSession <NSCoding, UWInfoSessionClientDelegate>

@property (nonatomic, weak) id <InfoSessionModelDelegate> delegate;
@property (nonatomic, copy) NSString *apiKey;

// info sessions data retrived from api
@property (nonatomic, strong) NSArray *infoSessions;
@property (nonatomic, strong) NSMutableDictionary *infoSessionsDictionary;

// user saved info sessions
@property (nonatomic, strong) NSMutableArray *myInfoSessions;
//@property (nonatomic, strong) NSMutableDictionary *myInfoSessionsDictionary;

@property (nonatomic, copy) NSString *currentTerm;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, copy) NSString *term;

// store different terms' info sessions
@property (nonatomic, strong) NSMutableDictionary *termInfoDic;

// processed dictionary, seperated in alphabet sequence.
@property (nonatomic, strong) NSMutableDictionary *infoSessionsIndexDic;
@property (nonatomic, strong) NSArray *infoSessionsIndexed;

// Used for manage calendar event, only initiate once!
//@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;

- (void)clearInfoSessions;

- (void)processInfoSessionsDictionary:(NSDictionary *)dictionary withInfoSessions:(NSArray *)array;

- (void)processInfoSessionsIndexDic;

//+ (NSURLSessionTask *)infoSessions:(NSInteger)year andTerm:(NSString *)term withBlock:(void (^)(NSArray *sessions, NSString *currentTerm, NSError *error))block;

+ (NSInteger)findInfoSession:(InfoSession *)infoSession in:(NSArray *)array;
+ (NSInteger)findInfoSessionIdentifier:(NSString *)infoSessionId in:(NSMutableArray *)array;
+ (UW)addInfoSessionInOrder:(InfoSession *)infoSession to:(NSMutableArray *)array;

- (UW)deleteInfoSessionInMyInfo:(InfoSession *)infoSession;

+ (NSString*)documentsDirectory;;
+ (NSString*)dataFilePath:(NSString *)fileName;
+ (void)saveMap;
+ (UIImage *)loadMap;

- (void)saveInfoSessions;
- (void)saveMyInfoSessions;
- (void)loadInfoSessions;

- (void)updateMyInfoSessions;

- (NSInteger)countFutureInfoSessions:(NSArray *)infosessions;
- (void)setYearAndTerm;

- (void)saveToTermInfoDic;
- (BOOL)readInfoSessionsWithTerm:(NSString *)term;

- (void)updateInfoSessionsWithYear:(NSInteger)year andTerm:(NSString *)term;

- (void)setOfflineMode:(BOOL)isOff;

- (InfoSession *)getPreviousInfoSessionAccordingInfoSession:(InfoSession *)info;
- (InfoSession *)getNextInfoSessionAccordingInfoSession:(InfoSession *)info;

@end
