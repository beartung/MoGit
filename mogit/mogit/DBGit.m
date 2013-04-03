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
    
    return [[NSString alloc] initWithFormat:@"\n新建工作目录:%@\n", dir];
}


+ (NSString *)initProject:(NSString *)git{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@; date; git clone %@", [DBConfig sharedInstance].workDir, git];
    NSLog(@"initProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:@"\n同步%@项目到本地目录：%@/%@\n", name, [DBConfig sharedInstance].workDir, name];
}

+ (NSString *)getProjectName:(NSString *)git{
    return [[git lastPathComponent] stringByDeletingPathExtension];
}

+ (NSString *)statusProject:(NSString *)git{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; date; git status|grep -v \"no changes added to commit\";", [DBConfig sharedInstance].workDir, name];
    NSLog(@"statusProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", ret);
    
    NSRange range = [ret rangeOfString:@"nothing to commit"];
    if (range.length > 0){
        return @"\n当前项目没有任何改动";
    }
    
    range = [ret rangeOfString:@"Untracked files"];
    NSString * newFiles = @"";
    if (range.length > 0){
        newFiles = [[ret substringFromIndex:range.location] substringFromIndex:86];
        newFiles = [newFiles stringByReplacingOccurrencesOfString:@"#	" withString:@"新加了:\t"];
    }
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; git status|grep \"ed:\";", [DBConfig sharedInstance].workDir, name];
    NSLog(@"statusProject cmd=%@", cmd);
    NSString * changes = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", changes);
    if ([changes length] > 0){
        changes = [changes stringByReplacingOccurrencesOfString:@"#	modified:   " withString:@"修改了:\t"];
        changes = [changes stringByReplacingOccurrencesOfString:@"#	deleted:    " withString:@"删除了:\t"];
    }
    
    return [[NSString alloc] initWithFormat:@"\n当前项目本地改动:\n\n%@\n%@\n", changes, newFiles];
}

+ (NSString *)syncProject:(NSString *)git{
    NSString * name = [DBGit getProjectName:git];

    NSString * cmd;
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; date; ping -c 1  code.dapps.douban.com",
           [DBConfig sharedInstance].workDir, name];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    NSRange range = [ret rangeOfString:@"100.0% packet loss"];
    if (range.length > 0){
        return @"\n请检查当前网络并确保连接上VPN!!!\n";
    }
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; date; git pull",
                      [DBConfig sharedInstance].workDir, name];
    NSLog(@"syncProject cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:@"\n同步%@项目最新修改到本地\n", name];
}

+ (NSString *)syncProject:(NSString *)git withComment:(NSString*)comment{
    NSString * name = [DBGit getProjectName:git];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; date; git add -A; git commit -m \"%@\"; git pull; git push",
                      [DBConfig sharedInstance].workDir, name, comment];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    NSRange range = [ret rangeOfString:@"fatal: could not read Username"];
    if (range.length > 0){
        return @"\n请联系和你合作的工程师，把你加为当前项目的commiter!!!\n";
    }
    return @"\n已经成功提交到远端 ：）\n";
}

@end
