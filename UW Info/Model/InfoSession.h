//
//  InfoSession.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoSession : NSObject

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
@property (nonatomic, assign) BOOL saved;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

//- (NSURL *)logoImageURL;

+ (NSURLSessionTask *)infoSessionsWithBlock:(void (^)(NSArray *sessions, NSError *error))block;

@end
