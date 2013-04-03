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
    NSString * cmd = [[NSString alloc] initWithFormat:@"mkdir -p %@", dir];
    NSLog(@"initWorkDir cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initWorkDir ret=%@", ret);
    
    return [[NSString alloc] initWithFormat:@"init work dir: %@", dir];
}


+ (NSString *)initProject:(NSString *)git{
    
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@; git clone %@", [DBConfig sharedInstance].workDir, git];
    NSLog(@"initProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initProject ret=%@", ret);
    return ret;
}

+ (NSString *)getProjectName:(NSString *)git{
    return [[git lastPathComponent] stringByDeletingPathExtension];
}

+ (NSString *)statusProject:(NSString *)git{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; git status", [DBConfig sharedInstance].workDir, name];
    NSLog(@"statusProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", ret);
    return ret;
}

+ (NSString *)syncProject:(NSString *)git withComment:(NSString*)comment{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; git ci -a -m %@; git pull; git push",
                      [DBConfig sharedInstance].workDir, name, comment];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    return ret;
}

@end
