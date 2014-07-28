//
//  BLBeanStuff.m
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "BLBeanStuff.h"

@interface BLBeanStuff ()

@property (strong,nonatomic) PTDBeanManager *beanManager;
@property (strong,nonatomic) NSMutableDictionary *discoveredBeansDict;
@property (strong,nonatomic) NSMutableString *receivedData;
@property BOOL connectedToTarget;
@property (strong,nonatomic) PTDBean *theConnectedBean;
@property (strong,nonatomic) NSString *theTargetBean;

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
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

-(NSArray *)discoveredBeans {
    return [self.discoveredBeansDict allValues];
}

-(BOOL) isConnectedToTarget {
    return self.connectedToTarget;
}


-(PTDBean *)getConnectedBean {
    return self.theConnectedBean;
}

-(NSString *)getTargetBean {
    return self.theTargetBean;
}

-(void )setTargetBean:(NSString *)value {
    if (![value isEqualToString:self.theTargetBean]) {
        self.theTargetBean=value;
        if (self.theConnectedBean != nil) {
            [self.beanManager disconnectBean:self.theConnectedBean error:nil];
        }
        for (PTDBean *bean in self.discoveredBeans) {
            if ([bean.name isEqualToString:self.theTargetBean]) {
                [self.beanManager connectToBean:bean error:nil];
                break;
            }
        }
        
    }
}
-(void) processInput:(NSString *)input
{
    NSLog(@"Process input=%@",input);
}

#pragma mark - PTDBeanManagerDelegate methods

// check to make sure we're on
- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        // if we're on, scan for advertisting beans
        NSLog(@"Starting to scan for bean");
        [self.beanManager startScanningForBeans_error:nil];
    }
    else if (self.beanManager.state == BeanManagerState_PoweredOff) {
        // do something else
    }
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)bean error:(NSError*)error {
    if (error) {
        NSLog(@"a %@", [error localizedDescription]);
        return;
    }
    else {
        NSLog(@"Discovered bean %@ (%@)",bean.name,bean.identifier);
        [self.discoveredBeansDict setObject:bean forKey:bean.identifier];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didUpdateDiscoveredBeans:)]) {
            [self.delegate didUpdateDiscoveredBeans:[self discoveredBeans]];
        }
        if ([bean.name isEqualToString:self.targetBean])
        {
            [beanManager connectToBean:bean error:nil];
        }
    }
    // [self.beanManager connectToBean:bean error:nil];
}

// bean connected
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        NSLog(@"b %@", [error localizedDescription]);
        return;
    }
    bean.delegate=self;
    self.connectedToTarget=YES;
    self.theConnectedBean=bean;
    [self.beanManager stopScanningForBeans_error:nil];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didConnectToBean:)]) {
        [self.delegate didConnectToBean:bean];
    }
    // do stuff with your bean
}

-(void)BeanManager:(PTDBeanManager *)beanManager didDisconnectBean:(PTDBean *)bean error:(NSError *)error
{
    if (error) {
        NSLog(@"c %@", [error localizedDescription]);;
    }
    
    self.theConnectedBean=nil;
    self.connectedToTarget=NO;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didDisconnectFromBean:)]) {
        [self.delegate didDisconnectFromBean:bean];
    }
    NSLog(@"connection lost - attempting to reacquire");
    [self.beanManager stopScanningForBeans_error:nil];
    [self.discoveredBeansDict removeAllObjects];
    [self.beanManager startScanningForBeans_error:nil];
    
}

#pragma mark - PTDBeanDelegate methods

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data
{
    NSString *serialDataString=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"Received serial data from Bean - %@",serialDataString);
    
    for (int i=0;i<serialDataString.length;i++) {
        unichar c=[serialDataString characterAtIndex:i];
        if (c=='\n')
        {
            [self processInput:self.receivedData];
            self.receivedData=[NSMutableString new];
        }
        else
        {
            [self.receivedData appendString:[NSString stringWithFormat:@"%c",c]];
        }
    }
}

- (void)bean:(PTDBean *)bean error:(NSError *)error
{
    NSLog(@"d %@", [error localizedDescription]);
}
@end
