//
//  DBWindowController.m
//  mogit
//
//  Created by Bear on 4/2/13.
//  Copyright (c) 2013 Bear. All rights reserved.
//

#import "DBWindowController.h"
#import "DBConfig.h"

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
    NSLog(@"config=%@", [DBConfig sharedInstance]._dict);
}

@end