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

static NSString * const kHOST = @"code.dapps.douban.com";
static NSString * const kERROR_CLONE_FAIL = @"not found";
static NSString * const kERROR_CLONE_FAIL_CN = @"请检查git地址，初始化项目失败";
static NSString * const kERROR_CLONE_EXIST = @"already exists";
static NSString * const kERROR_CLONE_EXIST_CN = @"本地已经存在项目目录";
static NSString * const kERROR_INVALID_GIT_CN = @"请输入合法的git地址";
static NSString * const kCLONE_SUCCESS = @"项目%@成功初始化到本地目录：%@/%@";
static NSString * const kERROR_STATUS_NO_REPO = @"No such file or directory";
static NSString * const kERROR_STATUS_NO_REPO_CN = @"本地项目目录不存在，请重新设定项目地址";
static NSString * const kERROR_STATUS_NOCHANGE = @"nothing to commit";
static NSString * const kERROR_STATUS_NOCHANGE_CN = @"当前项目没有任何改动";
static NSString * const kERROR_STATUS_NEED_MERGE = @"both modified";
static NSString * const kERROR_STATUS_NEED_MERGE_CN = @"发生冲突，请联系和你合作的工程师帮助解决!!";
static NSString * const kSTATUS_CHANGED = @"当前项目本地改动:\n%@\n%@\n%@\n";
static NSString * const kSTATUS_HAS_COMMITS = @"# Your branch is ahead of 'origin/master' by";
static NSString * const kSTATUS_HAS_COMMITS_CN = @"当前已经提交到本地的有";
static NSString * const kSTATUS_COMMITS = @"commit";
static NSString * const kSTATUS_COMMITS_CN = @"个改动\n请联系和你合作的工程师，检查GIT帐号配置!!\n并且把你加为当前项目的commiter!!";
static NSString * const kSTATUS_NEW = @"#	";
static NSString * const kSTATUS_NEW_CN = @"新加了:\t";
static NSString * const kSTATUS_MODIFY = @"#	modified:   ";
static NSString * const kSTATUS_MODIFY_CN = @"修改了:\t";
static NSString * const kNEED_PUSH = @"Your branch is ahead of";
static NSString * const kSTATUS_DELETE = @"#	deleted:    ";
static NSString * const kSTATUS_DELETE_CN = @"删除了:\t";
static NSString * const kPULL_SUCCESS = @"你真棒！已经同步%@项目最新修改到本地";
static NSString * const kERROR_NOT_COMMITER = @"fatal: could not read Username";
static NSString * const kERROR_NOT_COMMITER_CN = @"提交失败，请联系和你合作的工程师，检查GIT帐号配置!!\n并且把你加为当前项目的commiter!!";
static NSString * const kERROR_FAIL_MERGE = @"Failed to merge";
static NSString * const kERROR_FAIL_MERGE_CN = @"你的修改提交到远端时发生冲突，请联系和你合作的工程师帮助解决";
static NSString * const kPUSH_SUCCESS = @"你真棒！ 已经成功将你的修改提交到远端 ：）";
static NSString * const kGIT_LOCAL = @"/usr/local/git/bin/git";
static NSString * const kGIT_ALT = @"/usr/bin/git";

static NSString * kGIT = @"git";

@interface DBGit()

@property (nonatomic, strong) NSDictionary * const kERROR_DICT;

- (BOOL)findString:(NSString *)s withKey:(NSString *)k;
- (NSString *)getErrorString:(NSString *)s withKey:(NSString *)k;
- (NSString *)checkError:(NSString *)r withErrors:(NSArray *)errors;

@end

static DBGit * __instance;

@implementation DBGit

+ (DBGit *)sharedInstance {
    if (__instance == nil) {
        __instance = [[super allocWithZone:NULL] init];
        __instance.kERROR_DICT = @{
        
    kERROR_CLONE_EXIST:kERROR_CLONE_EXIST_CN,
    kERROR_CLONE_FAIL:kERROR_CLONE_FAIL_CN,
    kERROR_STATUS_NOCHANGE:kERROR_STATUS_NOCHANGE_CN,
    kERROR_STATUS_NEED_MERGE:kERROR_STATUS_NEED_MERGE_CN,
    kERROR_STATUS_NO_REPO:kERROR_STATUS_NO_REPO_CN,
    kERROR_NOT_COMMITER:kERROR_NOT_COMMITER_CN,
    kERROR_FAIL_MERGE:kERROR_CLONE_FAIL_CN,
        
        };
    }    
    return __instance;
}

- (void)config:(NSString *)name withPassword:(NSString *)password{
    NSString * cmd = [[NSString alloc] initWithFormat:@"cp ~/.netrc ~/.netrc.bak; echo \"machine %@ login %@ password %@\" >> ~/.netrc", kHOST, name, password];
    NSLog(@"gitConfig cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"gitConfig ret=%@", ret);
    cmd = [[NSString alloc] initWithFormat:@"cp ~/.gitconfig ~/.gitconfig.back; %@ config --global user.name %@; %@ config --global user.email %@@douban.com;%@ config --global push.default matching", kGIT, name, kGIT, name, kGIT];
    NSLog(@"gitConfig cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"gitConfig ret=%@", ret);
}

- (NSString *)clone{
    NSString * workdir = [DBConfig sharedInstance].workDir;
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@; %@ clone %@", workdir, kGIT, self.git];
    NSLog(@"initProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"initProject ret=%@", ret);
    NSString * error = [self checkError:ret withErrors:@[kERROR_CLONE_EXIST, kERROR_CLONE_FAIL]];
    if (error != nil) return error;
    NSString * name = [self name];
    return [[NSString alloc] initWithFormat:kCLONE_SUCCESS, name, workdir, name];
}

- (NSString *)status{
    NSString * name = [self name];
    NSString * commits = @"";
    NSString * cmd;
    NSString * ret;
    NSRange range;
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ status|grep \"Your branch is ahead of\"", [DBConfig sharedInstance].workDir, name, kGIT];
    NSLog(@"statusProject cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", ret);
    
    if (ret.length > 0){
        commits = [ret stringByReplacingOccurrencesOfString:kSTATUS_HAS_COMMITS
                                                 withString:kSTATUS_HAS_COMMITS_CN];
        commits = [commits stringByReplacingOccurrencesOfString:kSTATUS_COMMITS
                                                 withString:kSTATUS_COMMITS_CN];
        commits = [commits stringByReplacingOccurrencesOfString:@"s"
                                                     withString:@""];
        commits = [commits stringByReplacingOccurrencesOfString:@"."
                                                     withString:@""];
    }
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ status|grep -v \"no changes added to commit\"|grep -v \"nothing added to commit\";", [DBConfig sharedInstance].workDir, name, kGIT];
    NSLog(@"statusProject cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", ret);
    
    NSString * error = [self checkError:ret withErrors:@[kERROR_STATUS_NOCHANGE, kERROR_STATUS_NEED_MERGE, kERROR_STATUS_NO_REPO]];
    if (error != nil && [commits length] == 0) return error;
    
    
    range = [ret rangeOfString:@"Untracked files"];
    NSString * newFiles = @"";
    if (range.length > 0){
        newFiles = [[ret substringFromIndex:range.location] substringFromIndex:86];
        newFiles = [newFiles stringByReplacingOccurrencesOfString:kSTATUS_NEW
                            withString:kSTATUS_NEW_CN];
    }
    
    cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ status|grep \"ed:\";", [DBConfig sharedInstance].workDir, name, kGIT];
    NSLog(@"statusProject cmd=%@", cmd);
    NSString * changes = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"statusProject ret=%@", changes);
    if ([changes length] > 0){
        changes = [changes stringByReplacingOccurrencesOfString:kSTATUS_MODIFY
                                                     withString:kSTATUS_MODIFY_CN];
        changes = [changes stringByReplacingOccurrencesOfString:kSTATUS_DELETE
                                                     withString:kSTATUS_DELETE_CN];
    }

    return [[NSString alloc] initWithFormat:kSTATUS_CHANGED, commits, changes, newFiles];
}

- (NSString *)pull{
    NSString * name = [self name];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ pull",
                      [DBConfig sharedInstance].workDir, name, kGIT];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);
    return [[NSString alloc] initWithFormat:kPULL_SUCCESS, name];
}

- (NSString *)sync:(NSString*)comment{
    NSString * name = [self name];
    NSString * cmd = [[NSString alloc] initWithFormat:@"cd %@/%@; %@ add -A; %@ commit -m \"%@\"; %@ pull; %@ push origin master",
                      [DBConfig sharedInstance].workDir, name, kGIT, kGIT, comment, kGIT, kGIT];
    NSLog(@"syncProject cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"syncProject ret=%@", ret);

    NSString * error = [self checkError:ret withErrors:@[kERROR_NOT_COMMITER,kERROR_FAIL_MERGE]];
    if (error != nil) return error;
    return kPUSH_SUCCESS;
}
    
+ (BOOL)checkGit{
    NSString * cmd = @"which git";
    NSLog(@"checkGit cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkGit ret=%@", ret);
    NSRange range = [ret rangeOfString:@"git"];
    NSLog(@"checkGit kGIT=%@", kGIT);
    if (range.length > 0) return YES;

    cmd = @"ls /usr/local/git/bin/git";
    NSLog(@"checkGit cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkGit ret=%@", ret);
    range = [ret rangeOfString:@"No such file or directory"];
    if (range.length == 0) {
        NSLog(@"checkGit kGIT=%@", kGIT);
        kGIT = kGIT_LOCAL;
        return YES;
    }
    
    cmd = @"ls /usr/bin/git";
    NSLog(@"checkGit cmd=%@", cmd);
    ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkGit ret=%@", ret);
    range = [ret rangeOfString:@"No such file or directory"];
    if (range.length == 0) {
        NSLog(@"checkGit kGIT=%@", kGIT);
        kGIT = kGIT_ALT;
        return YES;
    }
    return NO;
    
}

+ (BOOL)checkGitConfig{
    NSString * cmd = [[NSString alloc] initWithFormat:@"grep \"%@\" ~/.netrc", kHOST];
    NSLog(@"checkGitConfig cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    if ([ret length] > 35){
        NSLog(@"checkGitConfig ret=%@", [ret substringToIndex:35]);
    }
    NSRange range = [ret rangeOfString:kHOST];
    return range.length > 0;
}

+ (BOOL)checkNetwork{
    NSString * cmd = [[NSString alloc] initWithFormat:@"ping -c 1 %@", kHOST];
    NSLog(@"checkNetWork cmd=%@", cmd);
    NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
    NSLog(@"checkNetWork ret=%@", ret);
    NSRange r1 = [ret rangeOfString:@"100.0% packet loss"];
    NSRange r2 = [ret rangeOfString:@"cannot resolve"];
    return r1.length == 0 && r2.length == 0;
}

+ (NSString *)initWorkDir:(NSString *)dir{
        NSString * cmd = [[NSString alloc] initWithFormat:@"mkdir -p %@", dir];
        NSLog(@"initWorkDir cmd=%@", cmd);
        NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
        NSLog(@"initWorkDir ret=%@", ret);
        return ret;
}

- (NSString *)name{
    return [[self.git lastPathComponent] stringByDeletingPathExtension];
}

- (BOOL)findString:(NSString *)s withKey:(NSString *)k{
        NSRange range = [s rangeOfString:k];
        return range.length > 0;
}

- (NSString *)getErrorString:(NSString *)s withKey:(NSString *)k{
    NSRange range = [s rangeOfString:k];
    NSLog(@"checkError by %@ find %ld", k, range.length);
    if (range.length > 0){
        return [self.kERROR_DICT objectForKey:k];
    }
    return nil;
}

- (NSString *)checkError:(NSString *)r withErrors:(NSArray *)errors{
    NSString * ret;
    for (NSString * error in errors) {
        ret = [self getErrorString:r withKey:error];
        if (ret != nil){
            return ret;
        }
    }
    return nil;
}

@end
