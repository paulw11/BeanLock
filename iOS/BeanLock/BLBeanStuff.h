/*
//  BLBeanStuff.h
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
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

#import <Foundation/Foundation.h>
#import <PTDBean.h>
#import <PTDBeanManager.h>

@interface BLBeanStuff: NSObject <PTDBeanManagerDelegate>

@property (weak,nonatomic) id delegate;
@property (nonatomic,readonly) NSArray *connectedBeans;
@property (nonatomic,readonly) NSArray *discoveredBeans;

-(BOOL) isConnectedToBean:(PTDBean *)bean;
-(BOOL) isConnectedToBeanWithIdentifier:(NSUUID *)identifier;
-(void) connectToBean:(PTDBean *)bean;
-(BOOL) connectToBeanWithIdentifier:(NSUUID *)identifier;
-(void) disconnectFromBean:(PTDBean *)bean;
-(void) startScanningForBeans;
-(void) stopScanningForBeans;

+(BLBeanStuff *)sharedBeanStuff;

@end

@protocol BLBeanStuffDelegate

@optional -(void) didUpdateDiscoveredBeans:(NSArray *)discoveredBeans withBean:(PTDBean *)newBean;
@optional -(void) didConnectToBean:(PTDBean *)bean;
@optional -(void) didDisconnectFromBean:(PTDBean *)bean;

@end


