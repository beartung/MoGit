//
//  DBConfig.m
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import "DBConfig.h"
#import "ShellTask.h"

static NSString * kDBPlistPath;
static NSString * const kDBPlistName = @"mogit.plist";
static NSString * const kWORKDIR = @"WORK_DIR";
static NSString * const kDefaultWorkDir = @"~/Desktop/Mogit";
static NSString * const kPROJECTS = @"PROJECT_GITS";
static NSString * const kNOW_PROJECT = @"NOW_PROJECT";

@interface DBConfig ()

@end

static DBConfig * __instance;

@implementation DBConfig

- (void)sync{
    //NSLog(@"sync config workdir=%@", self.workDir);
    //NSLog(@"sync config projects=%@", self.projectGits);
    //NSLog(@"sync config now project=%@", self.nowProject);
    NSDictionary * _dict = @{kWORKDIR:self.workDir, kNOW_PROJECT:self.nowProject, kPROJECTS:self.projectGits};
    NSLog(@"sync config=%@", _dict);
    [_dict writeToFile:kDBPlistPath atomically:YES];
}

+ (DBConfig *)sharedInstance {
    if (__instance == nil) {
        NSLog(@"get config from %@", kDBPlistName);
        NSString * dir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
        NSLog(@"get suppor dir %@", dir);
        NSString * bundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSLog(@"get bundle %@", bundle);
        NSString * cmd = [[NSString alloc] initWithFormat:@"mkdir -p \"%@/%@\"", dir, bundle];
        NSLog(@"mkdir config dir cmd=%@", cmd);
        NSString * ret = [ShellTask executeShellCommandSynchronously:cmd];
        NSLog(@"mkdir config ret=%@", ret);
        kDBPlistPath = [[NSString alloc] initWithFormat:@"%@/%@/%@", dir, bundle, kDBPlistName];
        NSLog(@"config path=%@", kDBPlistPath);
        
        __instance = [[super allocWithZone:NULL] init];
        NSDictionary * _dict = [NSDictionary dictionaryWithContentsOfFile:kDBPlistPath];
        if (_dict == nil){
            _dict = @{kWORKDIR:kDefaultWorkDir, kNOW_PROJECT:@"", kPROJECTS:@[]};
            [_dict writeToFile:kDBPlistName atomically:YES];
            NSLog(@"init config=%@", _dict);
        }
        __instance.workDir = [_dict objectForKey:kWORKDIR];
        __instance.projectGits = [[NSMutableArray alloc] initWithArray:[_dict objectForKey:kPROJECTS]];
        __instance.nowProject = [_dict objectForKey:kNOW_PROJECT];
    }
    //NSLog(@"get config workdir=%@", __instance.workDir);
    //NSLog(@"get config projects=%@", __instance.projectGits);
    NSLog(@"get config now project=%@", __instance.nowProject);

    return __instance;
}

@end
