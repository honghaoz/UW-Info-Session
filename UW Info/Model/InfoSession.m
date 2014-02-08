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

const NSString *apiKey =  @"abc498ac42354084bf594d52f5570977";

@interface InfoSession()

@property (nonatomic, readwrite, assign) NSUInteger SessionId;
@property (nonatomic, readwrite, copy) NSString *employer;
@property (nonatomic, readwrite, copy) NSString *date;
@property (nonatomic, readwrite, copy) NSString *startTime;
@property (nonatomic, readwrite, copy) NSString *endTime;
@property (nonatomic, readwrite, copy) NSString *location;
@property (nonatomic, readwrite, copy) NSString *website;
@property (nonatomic, readwrite, copy) NSString *audience;
@property (nonatomic, readwrite, copy) NSString *programs;
@property (nonatomic, readwrite, copy) NSString *description;
@property (nonatomic, readwrite, unsafe_unretained) NSURL *logoImageURL;

@end

@implementation InfoSession

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.SessionId = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    self.employer = [attributes valueForKeyPath:@"employer"];
    self.date = [attributes valueForKeyPath:@"date"];
    self.startTime = [attributes valueForKeyPath:@"start_time"];
    self.endTime = [attributes valueForKeyPath:@"end_time"];
    self.location = [attributes valueForKeyPath:@"location"];
    self.website = [attributes valueForKeyPath:@"website"];
    self.audience = [attributes valueForKeyPath:@"audience"];
    self.programs = [attributes valueForKeyPath:@"programs"];
    self.description = [attributes valueForKeyPath:@"description"];
    return self;
    
}

+ (NSURLSessionTask *)infoSessionsWithBlock:(void (^)(NSArray *sessions, NSError *error))block{
    return [[AFUwaterlooApiClient sharedClient] GET:@"resources/infosessions.json" parameters:@{@"key" : apiKey} success:^(NSURLSessionDataTask * __unused task, id JSON) {
        NSArray *infoSessionsFromResponse = [JSON valueForKeyPath:@"data"];
        NSMutableArray *mutableInfoSessions = [NSMutableArray arrayWithCapacity:[infoSessionsFromResponse count]];
        for (NSDictionary *attributes in infoSessionsFromResponse) {
            InfoSession *infoSession = [[InfoSession alloc] initWithAttributes:attributes];
            [mutableInfoSessions addObject:infoSession];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutableInfoSessions], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

@end
