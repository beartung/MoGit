//
//  DBConfig.m
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import "DBConfig.h"

static NSString * const kDBPlistName = @"plist";
static NSString * const kWORKDIR = @"WORK_DIR";
static NSString * const kDefaultWorkDir = @"~/Desktop/Mogit/";
static NSString * const kPROJECTS = @"PROJECT_GITS";

static DBConfig * __instance;

@implementation DBConfig

- (void)sync{
    NSLog(@"sync config workdir=%@", [self workDir]);
    NSArray * projects = [self projectGits];
    NSLog(@"sync config projects=%@", projects);
    [[self _dict] setValue:projects forKey:kPROJECTS];
    [[self _dict] writeToFile:kDBPlistName atomically:YES];
}

+ (DBConfig *)sharedInstance {
    
    if (__instance == nil) {
        __instance = [[super allocWithZone:NULL] init];
        __instance._dict = [NSDictionary dictionaryWithContentsOfFile:kDBPlistName];
        if (__instance._dict == nil){
            __instance._dict = @{kWORKDIR:kDefaultWorkDir, kPROJECTS:@[]};
            [__instance._dict writeToFile:kDBPlistName atomically:YES];
        }
        __instance.workDir = [__instance._dict objectForKey:kWORKDIR];
        __instance.projectGits = [[NSMutableArray alloc] initWithArray:[__instance._dict objectForKey:kPROJECTS]];
    }
    return __instance;
}

@end
