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

@property (nonatomic, strong) NSTimer * _timer;

@end

@implementation DBWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"awakeFromNib...");
    [self.log setEditable:NO];
    [self.comment setTitle:@""];
    [self.commentInput setHidden:YES];
    [self.syncButton setHidden:YES];
    DBConfig * config = [DBConfig sharedInstance];
    NSLog(@"window load workdir=%@", config.workDir);
    if (config.workDir != nil && [config.workDir length] > 0){
        [self.workdir setTitle:config.workDir];        
    }
    if (config.projectGits != nil && config.nowProject != nil && [config.nowProject length] > 0){
        [self.project setTitle:config.nowProject];
        [self.workdir setEnabled:NO];
        [self.project setEnabled:NO];
        [self.button setEnabled:NO];
        self.check.state = NSOffState;
        [self doCheckStatus];
    }

    NSLog(@"window load now project=%@", config.nowProject);
    NSLog(@"window load projects=%@", config.nowProject);
    self._timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                        selector:@selector(checkStatus:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self._timer forMode:@"test"];
    
}

- (void)initSetting{
    [self.progressSetting startAnimation:nil];
    NSString * inputDir = self.workdir.stringValue;
    NSLog(@"work dir=%@", inputDir);
    DBConfig * config = [DBConfig sharedInstance];
    config.workDir = inputDir;
    [DBGit initWorkDir:config.workDir];
    [config sync];
    
    NSLog(@"projects=%@", config.projectGits);
    
    NSString * inputProject = self.project.stringValue;
    NSLog(@"new project=%@", inputProject);
    if ([inputProject length] > 0 && [inputProject hasPrefix:@"http://"] && [inputProject hasSuffix:@".git"]){
        if ([config.projectGits indexOfObject:inputProject] == NSNotFound ){
            [config.projectGits addObject:inputProject];
            config.nowProject = inputProject;
            [config sync];
            [self addLog:[DBGit initProject:inputProject]];
        }
        [self addLog:[DBGit statusProject:inputProject]];
        [self.workdir setEnabled:NO];
        [self.project setEnabled:NO];
        [self.button setEnabled:NO];
        self.check.state = NSOffState;
    }
    [self.progressSetting stopAnimation:nil];
}

- (void)checkStatus:(id)sender{
    NSLog(@"checkStatus");
    [self doCheckStatus];
}

- (void)doCheckStatus{
    DBConfig * config = [DBConfig sharedInstance];
    if ([config.nowProject length] > 0){
        [self.progress startAnimation:nil];
        NSString * status = [DBGit statusProject:config.nowProject];
        [self addLog:status];
        NSRange range = [status rangeOfString:@"当前项目没有任何改动"];
        [self.syncButton setHidden:range.length > 0];
        [self.commentInput setHidden:range.length > 0];
        [self.progress stopAnimation:nil];
    }
}

- (void)addLog:(NSString *)msg{
    //self.log.string = [[NSString alloc] initWithFormat:@"%@\n%@", self.log.string, msg];
    self.log.string = msg;
    [self.log scrollToEndOfDocument:nil];
}

- (IBAction)onClick:(id)sender
{
    NSLog(@"onClick...");
    if (sender == self.button){
        NSLog(@"onClick... setting");
        [self initSetting];
    }else if (sender == self.syncButton){
        NSLog(@"onClick... sync");
        [self.progress startAnimation:nil];
        DBConfig * config = [DBConfig sharedInstance];
        NSLog(@"comment: %@", self.comment.stringValue);
        if ([self.comment.stringValue length] > 0){
            [self.progress startAnimation:nil];
            [self addLog:[DBGit syncProject:config.nowProject withComment:self.comment.stringValue]];
            [self.commentInput setHidden:YES];
            [self.syncButton setHidden:YES];
        }
        [self.progress stopAnimation:nil];
    }else if (sender == self.check){
        NSLog(@"onClick... check");
        BOOL s = self.check.state == NSOnState;
        [self.workdir setEnabled:s];
        [self.project setEnabled:s];
        [self.button setEnabled:s];
        [self.syncButton setHidden:s];
    }
    
}

@end