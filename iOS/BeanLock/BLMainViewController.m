//
//  BLMainViewController.m
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "BLMainViewController.h"

@interface BLMainViewController ()

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;

@end

@implementation BLMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Settings View Controller

/*- (void)flipsideViewControllerDidFinish:(BLFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}*/

- (IBAction) settingsDone:(UIStoryboardSegue *)unwindSegue
{
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.settingsPopoverController = nil;
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


@end
