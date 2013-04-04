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

- (void)setSyncUI:(BOOL)hide{
    [self.comment setTitle:@""];
    [self.commentInput setHidden:hide];
    [self.syncButton setHidden:hide];
}

- (void)setProjectUI:(BOOL)enable{
    [self.project setEnabled:enable];
    [self.button setEnabled:enable];
    self.check.state = enable ? NSOnState : NSOffState;
}

- (void)initTimer{
    self._timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                                                 selector:@selector(checkStatus:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self._timer forMode:@"test"];
    [self._timer fire];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSLog(@"awakeFromNib...");
    DBConfig * config = [DBConfig sharedInstance];
    BOOL isNowProjectAvail = config.projectGits != nil &&
            config.nowProject != nil && [config.nowProject length] > 0;
    if (isNowProjectAvail){
        [self.project setTitle:config.nowProject];
        DBGit * dg = [DBGit sharedInstance];
        dg.git = config.nowProject;
    }
    [self setProjectUI:!isNowProjectAvail];
    [self.log setEditable:NO];
    [self setSyncUI:YES];
    
    NSLog(@"check git %d", [DBGit checkGit]);
    if (![DBGit checkGit]){
        [self setProjectUI:NO];
        [self.check setEnabled:NO];
        [self addLog:@"请先安装GIT，也可以联系合作的工程师！"];
    }else{
        NSLog(@"check git config %d", [DBGit checkGitConfig]);
        if (![DBGit checkGitConfig]){
            [self addLog:@"请先配置好GIT帐号，也可以联系合作的工程师！"];
        }else{
            [self initTimer];
        }
    }
    
}

- (void)setNowProject{
    [self.progress startAnimation:nil];
    DBConfig * config = [DBConfig sharedInstance];
    [DBGit initWorkDir:config.workDir];
    NSLog(@"projects=%@", config.projectGits);
    NSString * inputProject = self.project.stringValue;
    NSLog(@"new project=%@", inputProject);
    if ([inputProject length] > 0 && [inputProject hasSuffix:@".git"]){
        config.nowProject = inputProject;   
        if ([config.projectGits indexOfObject:inputProject] == NSNotFound ){
            [config.projectGits addObject:inputProject];         
        }
        [config sync];
        DBGit * dg = [DBGit sharedInstance];
        dg.git = config.nowProject;
        [self addLog:[dg clone]];
        [self setProjectUI:NO];
    }
    [self.progress stopAnimation:nil];
}

- (void)checkStatus:(id)sender{
    NSLog(@"checkStatus");
    [self doCheckStatus];
}

- (void)doCheckStatus{
    DBConfig * config = [DBConfig sharedInstance];
    if ([config.nowProject length] > 0 && self.check.state == NSOffState){
        [self.progress startAnimation:nil];
        NSString * status = [[DBGit sharedInstance] status];
        [self addLog:status];
        NSRange range = [status rangeOfString:@"当前项目本地改动"];
        [self.syncButton setHidden:range.length == 0];
        [self.commentInput setHidden:range.length == 0];
        [self.progress stopAnimation:nil];
    }
}

- (void)addLog:(NSString *)msg{
    //self.log.string = [[NSString alloc] initWithFormat:@"%@\n%@", self.log.string, msg];
    self.log.string = [[NSString alloc] initWithFormat:@"\n%@",msg];
    [self.log scrollToEndOfDocument:nil];
}

- (IBAction)onClick:(id)sender
{
    NSLog(@"onClick...");
    if (sender == self.button){
        NSLog(@"onClick... setting");
        [self setNowProject];
    }else if (sender == self.syncButton){
        NSLog(@"onClick... sync");
        NSLog(@"comment: %@", self.comment.stringValue);
        if ([self.comment.stringValue length] > 0){
            [self.commentInput setHidden:YES];
            [self.progressSync startAnimation:nil];
            [self addLog:[[DBGit sharedInstance] sync:self.comment.stringValue]];
            [self.comment setTitle:@""];
            [self.progressSync stopAnimation:nil];            
            [self.syncButton setHidden:YES];
        }
    }else if (sender == self.check){
        NSLog(@"onClick... check");
        [self setProjectUI:self.check.state == NSOnState];
        [self doCheckStatus];
    }
    
}

@end