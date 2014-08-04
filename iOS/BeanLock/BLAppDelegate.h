//
//  BLAppDelegate.h
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBLTargetBeanPref @"targetBean"
#define kBLTargetBeanNamePref @"targetBeanName"
#define kBLPasswordPref @"password"
#define kBLAutoUnlockPref @"autoUnlock"
#define kBLUnlockNotification @"kBLUnlockNotification"

@interface BLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
