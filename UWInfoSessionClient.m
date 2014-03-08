//
//  UWInfoSessionClient.m
//  UW Info
//
//  Created by Zhang Honghao on 2/7/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "UWInfoSessionClient.h"
#import "UIAlertView+AFNetworking.h"
//#import "UIAlertView+Blocks.h"

////static NSString * const AFUwaterlooApiBaseURLString = @"https://api.uwaterloo.ca/v2/";
////static NSString * const getFaviconBaseURLString = @"http://g.etfv.co/";
static NSString * const keyBaseURLString = @"http://uw-info.appspot.com/";

//static NSString * const infoSessionBaseURLString = @"http://uw-app.appspot.com/";
//static NSString * const baseURLString = @"http://localhost:13080/";

@interface UWInfoSessionClient () <UIAlertViewDelegate>

@end

@implementation UWInfoSessionClient {
    NSInteger yearToQuery;
    NSString *termToQuery;
    NSString *apiKeyToUse;
}

+ (instancetype)sharedApiKeyClient {
    static UWInfoSessionClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[UWInfoSessionClient alloc] initWithBaseURL:[NSURL URLWithString:keyBaseURLString]];
    });
    
    return _sharedClient;
}

+ (instancetype)infoSessionClientWithBaseURL:(NSURL *)url {
    UWInfoSessionClient *_sharedClient = nil;
    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    _sharedClient = [[UWInfoSessionClient alloc] initWithBaseURL:url];
    //});
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)getApiKey {
    NSLog(@"get api key");
    [self GET:@"getkey" parameters:@{@"key" : @"77881122"} success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            NSString *isValid = [responseObject valueForKeyPath:@"status"];
            if ([isValid isEqualToString:@"valid"]) {
                NSString  *apiKey = [[responseObject valueForKeyPath:@"key"] stringValue];
                if ([self.delegate respondsToSelector:@selector(apiClient:didUpdateWithApiKey:)]) {
                    [self.delegate apiClient:self didUpdateWithApiKey:apiKey];
                }
            }
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
//        if (httpResponse.statusCode == 503) {
//            //NSLog(@"key failed: 503");
//        }
//        else {
//            //NSLog(@"key failed");
//        }
    }];
}

- (void)updateInfoSessionsForYear:(NSInteger)year andTerm:(NSString *)term andApiKey:(NSString *)apiKey{
    NSLog(@"base url: %@", self.baseURL);
    yearToQuery = year;
    termToQuery = term;
    NSString *getTarget;
    if (year == 0 || term == nil) {
        getTarget = @"infosessions.json";
    } else {
        getTarget = [NSString stringWithFormat:@"infosessions/%ld%@.json", (long)year, term];
    }
    [self GET:getTarget parameters:@{@"key" : apiKey} success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        //NSLog(@"%@" ,[httpResponse allHeaderFields]);
        
        if (httpResponse.statusCode == 200) {
            if ([self.delegate respondsToSelector:@selector(infoSessionClient:didUpdateWithData:)]) {
                [self.delegate infoSessionClient:self didUpdateWithData:responseObject];
            }
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Success with wrong code: %d", httpResponse.statusCode]
                                                                message:[NSString stringWithFormat:@"All header fields: %@\n\nResponseObject:%@",[httpResponse allHeaderFields], responseObject]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try again" otherButtonTitles:nil];
            [alertView show];
            //NSLog(@"Received: %@", responseObject);
            //NSLog(@"Received HTTP %d", httpResponse.statusCode);
        }
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                completion(nil, nil);
        //            });
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 503) {
            //NSLog(@"503");
            
            if ([self.delegate respondsToSelector:@selector(infoSessionClient:didFailWithError:)]) {
                [self.delegate infoSessionClient:self didFailWithError:error];
            }
        }
        else {
            [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:self cancelButtonTitle:@"Try again" otherButtonTitles: nil];
        }
    }];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self updateInfoSessionsForYear:yearToQuery andTerm:termToQuery andApiKey:apiKeyToUse];
}

@end
