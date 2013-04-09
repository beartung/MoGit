//
//  DBWindowController.h
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DBWindowController : NSWindowController<NSWindowDelegate>{}

@property IBOutlet NSTextFieldCell * project;
@property IBOutlet NSTextField * projectInput;
@property IBOutlet NSButton * button;
@property IBOutlet NSButton * check;
@property IBOutlet NSButton * syncButton;
@property IBOutlet NSTextView * log;
@property IBOutlet NSProgressIndicator * progress;
@property IBOutlet NSTextFieldCell * comment;
@property IBOutlet NSTextField * commentInput;
@property IBOutlet NSProgressIndicator * progressSync;

@property IBOutlet NSTextField * accountInput;
@property IBOutlet NSTextFieldCell * account;
@property IBOutlet NSTextField * passwordInput;
@property IBOutlet NSTextFieldCell * password;
@property IBOutlet NSButton * accountButton;
@property IBOutlet NSButton * logo;

- (IBAction)onClick:(id)sender;

@end
