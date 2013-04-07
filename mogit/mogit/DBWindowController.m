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
@property BOOL _timerInited;

@end

@implementation DBWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self._timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                                                     selector:@selector(checkStatus:) userInfo:nil repeats:YES];
        self._timerInited = NO;
        [window setDelegate:self];
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

- (void)initTimer:(BOOL)fire{
    if (!self._timerInited){
        [[NSRunLoop currentRunLoop] addTimer:self._timer forMode:@"test"];
        self._timerInited = YES;
    }
    if (fire && self._timerInited) [self._timer fire];
}

- (void)windowDidBecomeKey:(NSNotification *)notification{
     NSLog(@"！！！！！！！！！！！windowDidBecomeKey");
}

- (void)windowDidBecomeMain:(NSNotification *)notification{
    NSLog(@"！！！！！！！！！！！windowDidBecomeMain");
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
        [self addLog:@"请先安装GIT，也可以联系合作的工程师!!"];
    }else{
        BOOL configed = [DBGit checkGitConfig];
        NSLog(@"check git config %d", configed);
        [self setAccountUI:configed];
        if (!configed){
            [self addLog:@"请先配置好GIT帐号，也可以联系合作的工程师!!"];
        }else{
            [self initTimer:YES];
        }
    }
    
}

- (void)setAccountUI:(BOOL)hide{
    [self.accountButton setHidden:hide];
    [self.accountInput setHidden:hide];
    [self.passwordInput setHidden:hide];
    [self.check setHidden:!hide];
    [self.button setHidden:!hide];
    [self.projectInput setHidden:!hide];
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
    }else{
        [self addLog:@"请输入合法的项目地址"];
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
            [self.progressSync startAnimation:nil];
            [self.commentInput setHidden:YES];
            if ([DBGit checkNetwork]){
                NSLog(@"vpn works try sync");
                [self addLog:[[DBGit sharedInstance] sync:self.comment.stringValue]];
                [self.comment setTitle:@""];                
                [self.syncButton setHidden:YES];
                [self initTimer:NO];
            }else{
                NSLog(@"vpn not works !!!");
                [self.commentInput setHidden:NO];
                [self.syncButton setHidden:NO];
                [self._timer invalidate];
                self._timerInited = NO;
                [self addLog:@"请检查是否连接到网络和VPN!\n然后再次点击同步"];
            }
            [self.progressSync stopAnimation:nil];
        }
    }else if (sender == self.check){
        NSLog(@"onClick... check");
        [self setProjectUI:self.check.state == NSOnState];
        [self doCheckStatus];
    }else if (sender == self.accountButton){
        NSLog(@"onClick... account");
        NSString * inputName = self.account.stringValue;
        NSString * inputPassword = self.password.stringValue;
        if (inputName != nil && inputName.length > 0 && inputPassword != nil &&
            inputPassword.length > 0){
            [[DBGit sharedInstance] config:inputName withPassword:inputPassword];
            [self setAccountUI:YES];
            [self addLog:@"GIT帐号已经设置成功"];
            [self initTimer:NO];
        }else{
            [self addLog:@"请输入你的豆瓣LDAP帐号和密码"];
        }
    }
}

@end