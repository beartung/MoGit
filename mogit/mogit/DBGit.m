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
    NSString * cmd = [[NSString alloc] initWithFormat:@"date; mkdir -p %@", dir];
    NSLog(@"initWorkDir cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initWorkDir ret=%@", ret);
    
    return [[NSString alloc] initWithFormat:@"init work dir:\n%@", cmd];
}


+ (NSString *)initProject:(NSString *)git{
    
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@; date; git clone %@", [DBConfig sharedInstance].workDir, git];
    NSLog(@"initProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:@"init project git:\n%@\n%@\n%@", git, cmd, ret];
}

+ (NSString *)getProjectName:(NSString *)git{
    return [[git lastPathComponent] stringByDeletingPathExtension];
}

+ (NSString *)statusProject:(NSString *)git{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; date; git status", [DBConfig sharedInstance].workDir, name];
    NSLog(@"statusProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:@"project %@ status:\n%@\n%@", name, cmd, ret];
}

+ (NSString *)syncProject:(NSString *)git{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; date; git pull",
                      [DBConfig sharedInstance].workDir, name];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:@"project %@ sync:\n%@\n%@", name, cmd, ret];
}

+ (NSString *)syncProject:(NSString *)git withComment:(NSString*)comment{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; date; git ci -a -m %@; git pull; git push",
                      [DBConfig sharedInstance].workDir, name, comment];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:@"project %@ sync:\n%@\n%@", name, cmd, ret];
}

@end
