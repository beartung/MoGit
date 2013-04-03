//
//  DBGit.h
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>
////https://code.google.com/p/git-osx-installer/downloads/detail?name=git-1.8.2-intel-universal-snow-leopard.dmg

@interface DBGit : NSObject

+ (BOOL)checkGit;
+ (BOOL)checkGitConfig;
+ (NSString *)initWorkDir:(NSString *)dir;
+ (NSString *)initProject:(NSString *)git;
+ (NSString *)statusProject:(NSString *)git;
+ (NSString *)getProjectName:(NSString *)git;
+ (NSString *)syncProject:(NSString *)git;
+ (NSString *)syncProject:(NSString *)git withComment:(NSString*)comment;
@end
