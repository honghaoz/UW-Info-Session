//
//  InfoSessionModel.h
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSession.h"

@interface InfoSessionModel : InfoSession

// info sessions data retrived from api
@property (nonatomic, strong) NSArray *infoSessions;
@property (nonatomic, strong) NSMutableDictionary *infoSessionsDictionary;

// user saved info sessions
@property (nonatomic, strong) NSMutableArray *myInfoSessions;
@property (nonatomic, strong) NSMutableDictionary *myInfoSessionsDictionary;

// Used for manage calendar event, only initiate once!
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKCalendar *defaultCalendar;

- (void)processInfoSessionsDictionary:(NSDictionary *)dictionary withInfoSessions:(NSArray *)array;
- (void)addInfoSessionInOrder:(InfoSession *)infoSession to:(NSMutableArray *)array;

@end
