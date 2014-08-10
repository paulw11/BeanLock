//
//  PreferencesViewController.m
//  BeanLockOSX
//
//  Created by Paul Wilkinson on 10/08/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AppDelegate.h"


@interface PreferencesViewController ()

@property (weak,nonatomic) IBOutlet NSTableView *tableView;
@property (weak,nonatomic) BLBeanStuff *myBeanStuff;
@property (strong,nonatomic) NSString *targetBeanId;
@property (strong,nonatomic) NSArray *discoveredBeans;

@end

@implementation PreferencesViewController

- (void)awakeFromNib {

    self.myBeanStuff=[BLBeanStuff sharedBeanStuff];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beanFound:) name:BLBeanFoundNotification object:nil];
    
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    
    self.targetBeanId=[[defaultsController values] valueForKey:kBLTargetBeanPref];
    
    
    // Do view setup here.
    
}

- (IBAction)refreshBeans:(id)sender {
    [self.myBeanStuff stopScanningForBeans];
    self.discoveredBeans=nil;
    [self.tableView reloadData];
    [self.myBeanStuff startScanningForBeans];
}

- (void) beanFound:(PTDBean *)bean {
    NSLog(@"Bean found");
    self.discoveredBeans=self.myBeanStuff.discoveredBeans;
    [self.tableView reloadData];
}

#pragma mark - NSTableviewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return (self.myBeanStuff.discoveredBeans.count);
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    
    PTDBean *bean = (PTDBean *)[self.discoveredBeans objectAtIndex:rowIndex];
    if ([aTableColumn.identifier isEqualToString:@"name"]) {
        return bean.name;
    }
    
    if ([aTableColumn.identifier isEqualToString:@"id"]) {
        return bean.identifier.UUIDString;
    }
    if ([aTableColumn.identifier isEqualToString:@"check"]) {
        NSButtonCell *cell=[aTableColumn dataCell];
        cell.title=@"";
        if ([self.targetBeanId isEqualToString:bean.identifier.UUIDString]) {
            cell.state=1;
        }
        else {
            cell.state=0;
        }
        return [aTableColumn dataCell];
    }
    
    return nil;
    
}

#pragma mark - NSTableviewDelegate methods 

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger selectedRow=self.tableView.selectedRow;
    
    if (selectedRow != -1 ) {
        
        PTDBean *bean=[self.discoveredBeans objectAtIndex:selectedRow];
        
        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        
        [[defaultsController values] setValue:bean.name forKey:kBLTargetBeanNamePref];
        [[defaultsController values] setValue:bean.identifier.UUIDString forKey:kBLTargetBeanPref];
        self.targetBeanId=bean.identifier.UUIDString;
        
        [self.tableView deselectRow:selectedRow];
        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,self.discoveredBeans.count)] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        
    }
    
    
}


@end
