//
//  UWInfoSessionClient.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "UWInfoSessionClient.h"

////static NSString * const AFUwaterlooApiBaseURLString = @"https://api.uwaterloo.ca/v2/";
////static NSString * const getFaviconBaseURLString = @"http://g.etfv.co/";
static NSString * const baseURLString = @"http://uw-info1.appspot.com/";
static NSString * apiKey = @"77881122";

@implementation UWInfoSessionClient


+ (instancetype)sharedInfoSessionClient {
    static UWInfoSessionClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UWInfoSessionClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)updateInfoSessionsForYear:(NSInteger)year andTerm:(NSString *)term {
    NSString *getTarget;
    if (year == 0 || term == nil) {
        getTarget = @"infosessions.json";
    } else {
        getTarget = [NSString stringWithFormat:@"infosessions/%ld%@.json", (long)year, term];
    }
    [self GET:getTarget parameters:@{@"key" : apiKey} success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(infoSessionClient:didUpdateWithData:)]) {
            [self.delegate infoSessionClient:self didUpdateWithData:responseObject];
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(infoSessionClient:didFailWithError:)]) {
            [self.delegate infoSessionClient:self didFailWithError:error];
        }
    }];
}

@end
