/*
//  BLMainViewController.m
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  
 The MIT License (MIT)
 
 Copyright (c) 2014 Paul Wilkinson
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#import "BLMainViewController.h"
#import "BLAppDelegate.h"

@interface BLMainViewController ()

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;
@property (nonatomic,strong) BLBeanStuff *myBeanStuff;
@property (nonatomic,strong) NSString *targetBean;
@property (nonatomic,strong) PTDBean *connectedBean;

@property (nonatomic,weak) IBOutlet UIButton *openButton;
@property (nonatomic,weak) IBOutlet UILabel *temperatureLabel;
@property (nonatomic,weak) IBOutlet UILabel *batteryLabel;
@property (nonatomic,weak) IBOutlet UIProgressView *batteryProgressView;
@property (nonatomic,weak) IBOutlet UILabel *messageLabel;

@end

@implementation BLMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.myBeanStuff=[BLBeanStuff sharedBeanStuff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockNotificationReceived) name:kBLUnlockNotification object:nil];
  
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.myBeanStuff.delegate=self;
    [self processSettings];
    self.openButton.enabled=(self.connectedBean != nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) unlockNotificationReceived {
    BOOL autoUnlock = [[NSUserDefaults standardUserDefaults] boolForKey:kBLAutoUnlockPref];
    if (autoUnlock ) {
        [self unlock];
    }
}

-(IBAction)openPressed:(UIButton *)sender {
    if (self.connectedBean!=nil) {
        [self unlock];
    }
}
         
-(void) unlock {
    NSString *password=[[NSUserDefaults standardUserDefaults] objectForKey:kBLPasswordPref];
    NSString *openCommand=[NSString stringWithFormat:@"\002%@\003",password];
    [self.connectedBean sendSerialData:[openCommand dataUsingEncoding:NSASCIIStringEncoding]];
    [self.connectedBean readTemperature];
}

-(void) processSettings {
    
    NSString *newTargetBean=[[NSUserDefaults standardUserDefaults] objectForKey:kBLTargetBeanPref];
    
    if (![newTargetBean isEqualToString:self.targetBean]) {
        self.targetBean=newTargetBean;
        NSUUID *beanID=[[NSUUID alloc] initWithUUIDString:newTargetBean];
        if (self.connectedBean != nil) {
            [self.myBeanStuff disconnectFromBean:self.connectedBean];
        }
        else {
            if (![self.myBeanStuff connectToBeanWithIdentifier:beanID] ) {
                [self.myBeanStuff startScanningForBeans];
            }
        }
    }
}

#pragma mark - Settings View Controller


- (IBAction) settingsDone:(UIStoryboardSegue *)unwindSegue
{
    
    [self processSettings];
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.settingsPopoverController = nil;
    [self processSettings];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSettings"]) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.settingsPopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}



#pragma mark - BLBeanStuffDelegate

-(void) didConnectToBean:(PTDBean *)bean {
    bean.delegate=self;
    self.connectedBean=bean;
    self.openButton.enabled=YES;
    [self.myBeanStuff stopScanningForBeans];
    [bean readTemperature];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate new];
    localNotification.alertBody = @"I see a lock";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

-(void) didDisconnectFromBean:(PTDBean *)bean {
    self.connectedBean=nil;
    self.openButton.enabled=NO;
    if (self.targetBean != nil) {
        [self.myBeanStuff connectToBeanWithIdentifier:[[NSUUID alloc] initWithUUIDString:self.targetBean]];
    }
}

-(void) didUpdateDiscoveredBeans:(NSArray *)discoveredBeans withBean:(PTDBean *)newBean {
    if ([self.targetBean isEqualToString:newBean.identifier.UUIDString]) {
        [self.myBeanStuff connectToBean:newBean];
    }
}

#pragma mark - PTDBeanDelegate methods

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data
{
    
    NSString *receivedMessage=[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    if ([receivedMessage isEqualToString:@"OK"]) {
        self.messageLabel.text=@"Lock opened";
    }
    else if ([receivedMessage isEqualToString:@"No"]) {
        self.messageLabel.text=@"Incorrect password!";
    }
    else if ([receivedMessage isEqualToString:@"Error"]) {
        self.messageLabel.text=@"An error occurred";
    }
    else if ([receivedMessage isEqualToString:@"Closed"]) {
        self.messageLabel.text=@"";
    }
}

- (void)bean:(PTDBean *)bean didUpdateTemperature:(NSNumber *)degrees_celsius {
    self.temperatureLabel.text=[NSString stringWithFormat:@"%0.1fºC",[degrees_celsius floatValue]];
}

- (void)beanDidUpdateBatteryVoltage:(PTDBean *)bean error:(NSError *)error {
    self.batteryLabel.text=[NSString stringWithFormat:@"%0.3fV",[bean.batteryVoltage floatValue]];
    self.batteryProgressView.progress=[bean.batteryVoltage floatValue]/3.3;
}

@end
