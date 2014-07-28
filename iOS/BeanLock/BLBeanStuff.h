//
//  BLBeanStuff.h
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PTDBean.h>
#import <PTDBeanManager.h>

@interface BLBeanStuff: NSObject <PTDBeanManagerDelegate,PTDBeanDelegate>

@property (weak,nonatomic) id delegate;
@property (nonatomic) NSString *targetBean;
@property (nonatomic,readonly) PTDBean *connectedBean;

-(NSArray *)discoveredBeans;

-(BOOL) isConnectedToTarget;
-(PTDBean *)getConnectedBean;

+(BLBeanStuff *)sharedBeanStuff;

@end

@protocol BLBeanStuffDelegate

-(void) didUpdateDiscoveredBeans:(NSArray *)discoveredBeans;
-(void) didConnectToBean:(PTDBean *)bean;
-(void) didDisconnectFromBean:(PTDBean *)bean;

@end


