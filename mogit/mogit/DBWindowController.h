//
//  DBWindowController.h
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DBWindowController : NSWindowController

@property IBOutlet NSTextFieldCell * project;
@property IBOutlet NSButton * button;
@property IBOutlet NSButton * check;
@property IBOutlet NSButton * syncButton;
@property IBOutlet NSTextView * log;
@property IBOutlet NSProgressIndicator * progress;
@property IBOutlet NSTextFieldCell * comment;
@property IBOutlet NSTextField * commentInput;
@property IBOutlet NSProgressIndicator * progressSync;

- (IBAction)onClick:(id)sender;

@end
