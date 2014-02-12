//
//  InfoSessionModel.h
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "InfoSession.h"

@interface InfoSessionModel : InfoSession

@property (nonatomic, strong) NSArray *infoSessions;
@property (nonatomic, strong) NSMutableDictionary *infoSessionsDictionary;
@property (nonatomic, strong) NSMutableArray *myInfoSessions;
@property (nonatomic, strong) NSMutableDictionary *myInfoSessionsDictionary;

@property (nonatomic, strong) NSDictionary *alertChoiceDictionary;
@property (nonatomic, strong) NSDictionary *alertSequenceDictionary;

- (void)processInfoSessionsDictionary:(NSDictionary *)dictionary withInfoSessions:(NSArray *)array;
- (void)addInfoSessionInOrder:(InfoSession *)infoSession to:(NSMutableArray *)array;

- (NSString *)getAlertDescription:(NSNumber *)alertChoice;
- (NSString *)getAlertSequence:(NSNumber *)alertChoice;
@end
