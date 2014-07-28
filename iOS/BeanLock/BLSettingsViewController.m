//
//  BLSettingsViewController.m
//  BeanLock
//
//  Created by Paul Wilkinson on 28/07/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "BLSettingsViewController.h"


@interface BLSettingsViewController ()

@property (nonatomic,weak) IBOutlet UITableView *beanTableView;

@property (nonatomic,strong) NSArray *beans;
@property (nonatomic,strong) BLBeanStuff *myBeanStuff;

@end

@implementation BLSettingsViewController

#pragma mark - view lifecycle

-(void) viewDidLoad {
    
    self.myBeanStuff=[BLBeanStuff sharedBeanStuff];
    
    self.myBeanStuff.delegate=self;
    
}

#pragma mark - BLBeanStuffDelegate

- (void) didUpdateDiscoveredBeans:(NSArray *)discoveredBeans
{
    self.beans=discoveredBeans;
    [self.beanTableView reloadData];
}

- (void) didConnectToBean:(PTDBean *)bean
{
    
    if ([self.beans containsObject:bean]) {
        NSUInteger index=[self.beans indexOfObject:bean];
        UITableViewCell *cell=[self.beanTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (cell != nil) {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
    }
    
}

- (void) didDisconnectFromBean:(PTDBean *)bean
{
    if ([self.beans containsObject:bean]) {
        NSUInteger index=[self.beans indexOfObject:bean];
        UITableViewCell *cell=[self.beanTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        if (cell != nil) {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PTDBean *bean=[self.beans objectAtIndex:indexPath.row];
    self.myBeanStuff.targetBean=bean.name;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beans.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"BeanTableCell"];
    
    PTDBean *bean=[self.beans objectAtIndex:indexPath.row];
    
    cell.textLabel.text=bean.name;
    
    if (bean == self.myBeanStuff.connectedBean ) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    return cell;
    
    
}

@end
