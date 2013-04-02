//
//  DBConfig.h
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBConfig : NSObject

@property (nonatomic, strong) NSDictionary * _dict;
@property (nonatomic, assign) NSString * workDir;
@property (nonatomic, strong) NSMutableArray * projectGits;

- (void)sync;
+ (DBConfig *)sharedInstance;

@end
