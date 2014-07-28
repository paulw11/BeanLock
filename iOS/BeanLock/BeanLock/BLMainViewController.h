//
//  BLMainViewController.h
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "BLFlipsideViewController.h"

@interface BLMainViewController : UIViewController <BLFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
