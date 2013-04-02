//
//  DBWindowController.m
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import "DBWindowController.h"
#import "DBConfig.h"
#import "DBGit.h"

@interface DBWindowController ()

@end

@implementation DBWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)onClick:(id)sender
{
    NSLog(@"onClick...");
    NSString * inputDir = [[self workdir] stringValue];
    NSLog(@"work dir=%@", inputDir);
    DBConfig * config = [DBConfig sharedInstance];
    config.workDir = inputDir;
    [DBGit initWorkDir:config.workDir];
    [config sync];
    
    NSLog(@"projects=%@", config.projectGits);
    
    NSString * inputProject = [[self project] stringValue];
    NSLog(@"new project=%@", inputProject);
    if ([inputProject length] > 0 && [inputProject hasPrefix:@"http://"] && [inputProject hasSuffix:@".git"]){
        if ([config.projectGits indexOfObject:inputProject] == NSNotFound ){
            [config.projectGits addObject:inputProject];
            [config sync];
            [DBGit initProject:inputProject];
        }
    }
    
}

@end