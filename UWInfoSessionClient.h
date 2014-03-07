//
//  UWInfoSessionClient.h
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@protocol UWInfoSessionClientDelegate;

@interface UWInfoSessionClient : AFHTTPSessionManager

@property (nonatomic, weak) id <UWInfoSessionClientDelegate>delegate;

+ (instancetype)sharedInfoSessionClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)updateInfoSessionsForYear:(NSInteger)year andTerm:(NSString *)term;

@end

@protocol UWInfoSessionClientDelegate <NSObject>

@optional
-(void)infoSessionClient:(UWInfoSessionClient *)client didUpdateWithData:(id)data;
-(void)infoSessionClient:(UWInfoSessionClient *)client didFailWithError:(NSError *)error;
@end