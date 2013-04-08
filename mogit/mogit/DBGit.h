//
//  DBGit.h
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBGit : NSObject

@property (nonatomic, strong) NSString * git;

- (void)config:(NSString *)name withPassword:(NSString *)password;
- (NSString *)clone;
- (NSString *)status;
- (NSString *)pull;
- (NSString *)sync:(NSString*)comment;

+ (BOOL)checkGit;
+ (BOOL)checkGitConfig;
+ (BOOL)checkNetwork;
+ (NSString *)initWorkDir:(NSString *)dir;
+ (DBGit *)sharedInstance;
@end
