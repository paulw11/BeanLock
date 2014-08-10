//
//  AppDelegate.m
//  BeanLockOSX
//
//  Created by Paul Wilkinson on 9/08/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet MainViewController *mainViewController;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    
}

            
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    BLBeanStuff *beanStuff=[BLBeanStuff sharedBeanStuff];
    NSArray *connectedBeans=beanStuff.connectedBeans;
    for (PTDBean *bean in connectedBeans) {
        NSLog(@"Disconnecting Bean %@",bean.name);
        [beanStuff disconnectFromBean:bean];
    }
    
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
