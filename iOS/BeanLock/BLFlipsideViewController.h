//
//  BLFlipsideViewController.h
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLFlipsideViewController;

@protocol BLFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(BLFlipsideViewController *)controller;
@end

@interface BLFlipsideViewController : UIViewController

@property (weak, nonatomic) id <BLFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
