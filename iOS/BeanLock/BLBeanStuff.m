/*
//  BLBeanStuff.m
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

#import "BLBeanStuff.h"

@interface BLBeanStuff ()

@property (strong,nonatomic) PTDBeanManager *beanManager;
@property (strong,nonatomic) NSMutableDictionary *discoveredBeansDict;
@property (strong,nonatomic) NSMutableString *receivedData;
@property (strong,nonatomic) NSMutableDictionary *theConnectedBeans;

@end

@implementation BLBeanStuff

#pragma mark Singleton Methods

+ (BLBeanStuff *)sharedBeanStuff {
    static BLBeanStuff *sharedBeanStuff = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBeanStuff = [[self alloc] init];
    });
    return sharedBeanStuff;
}

- (id)init {
    if (self = [super init]) {
        
        self.beanManager=[[PTDBeanManager alloc] init];
        self.beanManager.delegate=self;
        self.discoveredBeansDict=[NSMutableDictionary new];
        self.receivedData=[NSMutableString new];
        self.theConnectedBeans=[NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

-(NSArray *)discoveredBeans {
    return [self.discoveredBeansDict allValues];
}

-(NSArray *)connectedBeans {
    return [self.theConnectedBeans allValues];
}


-(BOOL)isConnectedToBean:(PTDBean *)bean {
    return ([self.theConnectedBeans allKeysForObject:bean].count !=0);
}

-(BOOL)isConnectedToBeanWithIdentifier:(NSUUID *)identifier {
    return ([self.theConnectedBeans objectForKey:identifier] != nil);
}

-(void) startScanningForBeans {
    [self.discoveredBeansDict removeAllObjects];
    [self.beanManager startScanningForBeans_error:nil];
}


-(void) stopScanningForBeans {
    [self.beanManager stopScanningForBeans_error:nil];
}

// Attempt to connect to a bean by identifier.
// Returns YES if bean is known and connection is being attempted
// Returns NO if bean is unknown


-(BOOL)connectToBeanWithIdentifier:(NSUUID *)identifier
{
    BOOL ret=NO;
    PTDBean *bean=[self.discoveredBeansDict objectForKey:identifier];
    if (bean != nil) {
        [self connectToBean:bean];
        ret=YES;
    }
   
    return ret;
}


-(void) connectToBean:(PTDBean *)bean {
    if (![self isConnectedToBean:bean]) {
        [self.beanManager connectToBean:bean error:nil];
    }
}

-(void) disconnectFromBean:(PTDBean *)bean {
    if ([self isConnectedToBean:bean]) {
        [self.beanManager disconnectBean:bean error:nil];
    }
}


#pragma mark - PTDBeanManagerDelegate methods

// check to make sure we're on
- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        // if we're on, scan for advertisting beans
        NSLog(@"Starting to scan for Beans");
        [self.beanManager startScanningForBeans_error:nil];
    }
    else if (self.beanManager.state == BeanManagerState_PoweredOff) {
        // do something else
    }
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)bean error:(NSError*)error {
    if (error) {
        NSLog(@"Error in didDiscoverBean: %@", [error localizedDescription]);
        return;
    }
    else {
        NSLog(@"Discovered Bean %@ (%@)",bean.name,bean.identifier);
        [self.discoveredBeansDict setObject:bean forKey:bean.identifier];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didUpdateDiscoveredBeans:withBean:)]) {
            [self.delegate didUpdateDiscoveredBeans:[self discoveredBeans] withBean:bean];
        }
        
    }
}

// bean connected
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        NSLog(@"Error in didConnectToBean: %@", [error localizedDescription]);
        return;
    }

    [self.theConnectedBeans setObject:bean forKey:bean.identifier];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didConnectToBean:)]) {
        [self.delegate didConnectToBean:bean];
    }
}

-(void)BeanManager:(PTDBeanManager *)beanManager didDisconnectBean:(PTDBean *)bean error:(NSError *)error
{
    if (error) {
        NSLog(@"Error in didDisconnectBean: %@", [error localizedDescription]);;
    }
    
    [self.theConnectedBeans removeObjectForKey:bean.identifier];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didDisconnectFromBean:)]) {
        [self.delegate didDisconnectFromBean:bean];
    }
}


@end
