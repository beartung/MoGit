//
//  DBGit.m
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import "DBGit.h"
#import "ShellTask.h"

@implementation DBGit

+ (void)initWorkDir:(NSString *)dir{
    NSString * ret = [ShellTask executeShellCommandSynchronously:[[NSString alloc] initWithFormat:@"mkdir -p %@/git", dir]];
    NSLog(@"initWorkDir %@", ret);
}
@end
