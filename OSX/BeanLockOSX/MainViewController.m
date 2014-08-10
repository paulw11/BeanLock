//
//  MainViewController.m
//  BeanLockOSX
//
//  Created by Paul Wilkinson on 9/08/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "MainViewController.h"
#import "BLBeanStuff.h"
#import "AppDelegate.h"
#import "PreferencesViewController.h"
#import <PTDBean.h>

@interface MainViewController ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *temperatureLabel;
@property (weak) IBOutlet NSTextField *batteryLabel;
@property (weak) IBOutlet NSLevelIndicator *temperatureIndicator;
@property (weak) IBOutlet NSLevelIndicator *batteryIndicator;
@property (weak) IBOutlet NSTextField *messageLabel;
@property (weak) IBOutlet NSButton *openButton;
@property (weak) BLBeanStuff *myBeanStuff;
@property (strong,nonatomic) NSString *targetBean;
@property (strong,nonatomic) NSString *targetBeanName;
@property (strong,nonatomic) PTDBean *connectedBean;


@end

@implementation MainViewController

-(void) awakeFromNib {
    self.temperatureLabel.stringValue=@"-";
    self.batteryLabel.stringValue=@"-";
    self.temperatureIndicator.intValue=-200;
    self.batteryIndicator.doubleValue=0.0;
    
    self.myBeanStuff=[BLBeanStuff sharedBeanStuff];
    
    [self processSettings];
    self.openButton.enabled=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

-(void) loadView {
    [super loadView];
    [self becomeFirstResponder];
    
    
}

-(void) defaultsChanged:(NSNotification *)notification {
    [self processSettings];
}

-(void) processSettings {
   
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    
    NSString *newTargetBean=[[defaultsController values] valueForKey:kBLTargetBeanPref];
    
    if (newTargetBean == nil) {
        self.messageLabel.stringValue=@"Please select a lock in settings";
    }
    
    if (![newTargetBean isEqualToString:self.targetBean]) {
        self.targetBean=newTargetBean;
        self.targetBeanName=[[defaultsController values] valueForKey:kBLTargetBeanNamePref];
        if (self.connectedBean != nil) {
            [self.myBeanStuff disconnectFromBean:self.connectedBean];
        }
        else {
            [self connect];
        }
    }
    
}

#pragma mark - User Actions

-(IBAction)openPressed:(NSButton *)sender {
    if (self.connectedBean!=nil) {
        [self unlock];
    }
}

-(void) unlock {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *password=[[defaultsController values] valueForKey:kBLPasswordPref];
    NSString *openCommand=[NSString stringWithFormat:@"\002%@\003",password];
    [self.connectedBean sendSerialData:[openCommand dataUsingEncoding:NSASCIIStringEncoding]];
    [self.connectedBean readTemperature];
}


#pragma mark - Connection

-(void) connect {
    NSUUID *beanID=[[NSUUID alloc] initWithUUIDString:self.targetBean];
    
    self.messageLabel.stringValue=[NSString stringWithFormat:@"Connecting to %@",self.targetBeanName];
  //  self.messageLabel.stringValue=@"";
    self.temperatureLabel.stringValue=@"-";
    self.batteryLabel.stringValue=@"-";
    self.batteryIndicator.floatValue=0;
    self.temperatureIndicator.intValue=-100;
    
    if (![self.myBeanStuff connectToBeanWithIdentifier:beanID] ) {  // Connect directly if we can
        [self.myBeanStuff startScanningForBeans];                   // Otherwise scan for the bean
    }
    
}

#pragma mark - BLBeanStuffDelegate

-(void) didConnectToBean:(PTDBean *)bean {
    // Bean may have been renamed
    if (![self.targetBeanName isEqualToString:bean.name]) {
        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        [[defaultsController values] setValue:bean.name forKey:kBLTargetBeanNamePref];
        self.targetBeanName=bean.name;
    }
    
    self.messageLabel.stringValue=[NSString stringWithFormat:@"Connected to %@",self.targetBeanName];
    
    bean.delegate=self;
    self.connectedBean=bean;
    self.openButton.enabled=YES;
    [self.myBeanStuff stopScanningForBeans];
    [bean readTemperature];
}

-(void) didDisconnectFromBean:(PTDBean *)bean {
    self.messageLabel.stringValue=@"Disconnected";
    self.connectedBean=nil;
    self.openButton.enabled=NO;
    if (self.targetBean != nil) {
        [self connect];
    }
}

-(void) didUpdateDiscoveredBeans:(NSArray *)discoveredBeans withBean:(PTDBean *)newBean {
    if ([self.targetBean isEqualToString:newBean.identifier.UUIDString]) {
        [self connect];
    }
}

#pragma mark - PTDBeanDelegate methods

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data
{
    
    NSString *receivedMessage=[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    if ([receivedMessage isEqualToString:@"OK"]) {
        self.messageLabel.stringValue=@"Lock opened";
    }
    else if ([receivedMessage isEqualToString:@"No"]) {
        self.messageLabel.stringValue=@"Incorrect password!";
    }
    else if ([receivedMessage isEqualToString:@"Error"]) {
        self.messageLabel.stringValue=@"An error occurred";
    }
    else if ([receivedMessage isEqualToString:@"Closed"]) {
        self.messageLabel.stringValue=@"";
    }
}

- (void)bean:(PTDBean *)bean didUpdateTemperature:(NSNumber *)degrees_celsius {
    self.temperatureLabel.stringValue=[NSString stringWithFormat:@"%0.1fºC",[degrees_celsius floatValue]];
    self.temperatureIndicator.floatValue=[degrees_celsius floatValue];
}

- (void)beanDidUpdateBatteryVoltage:(PTDBean *)bean error:(NSError *)error {
    float batteryVoltage = [bean.batteryVoltage floatValue];
    self.batteryLabel.stringValue=[NSString stringWithFormat:@"%0.4fV",batteryVoltage];
    self.batteryIndicator.floatValue=[bean.batteryVoltage floatValue]*10;
}


@end
