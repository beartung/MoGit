//
//  DBGit.m
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import "DBGit.h"
#import "ShellTask.h"
#import "DBConfig.h"

@implementation DBGit

+ (NSString *)initWorkDir:(NSString *)dir{
    NSString * cmd = [[NSString alloc] initWithFormat:@"mkdir -p %@/git", dir];
    NSLog(@"initWorkDir cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initWorkDir ret=%@", ret);
    
    return [[NSString alloc] initWithFormat:@"init work dir: %@", dir];
}


+ (NSString *)initProject:(NSString *)git{
    
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/git; git clone %@", [DBConfig sharedInstance].workDir, git];
    NSLog(@"initProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initProjectDir ret=%@", ret);
    return ret;
}

@end
