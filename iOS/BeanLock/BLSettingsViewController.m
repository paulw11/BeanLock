/*
//  BLSettingsViewController.m
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

#import "BLSettingsViewController.h"
#import "BLAppDelegate.h"


@interface BLSettingsViewController ()

@property (nonatomic,weak) IBOutlet UITableView *beanTableView;
@property (nonatomic,weak) IBOutlet UISwitch *autoUnlockSwitch;
@property (nonatomic,weak) IBOutlet UITextField *passwordTextField;

@property (nonatomic,strong) NSArray *beans;
@property (nonatomic,strong) BLBeanStuff *myBeanStuff;
@property (nonatomic,strong) NSString *targetBean;

@end

@implementation BLSettingsViewController

#pragma mark - view lifecycle

-(void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.myBeanStuff=[BLBeanStuff sharedBeanStuff];
    
    self.myBeanStuff.delegate=self;
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(tableRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.beanTableView addSubview:refreshControl];
    
    self.targetBean=[[NSUserDefaults standardUserDefaults] objectForKey:kBLTargetBeanPref];
    
    self.autoUnlockSwitch.on=[[NSUserDefaults standardUserDefaults] boolForKey:kBLAutoUnlockPref];
    
    self.passwordTextField.text=[[NSUserDefaults standardUserDefaults] objectForKey:kBLPasswordPref];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.beans=[self.myBeanStuff discoveredBeans];
    
}


#pragma mark - Event handling

-(void)tableRefresh:(UIRefreshControl *)sender {
    [self.myBeanStuff stopScanningForBeans];
    [self.myBeanStuff startScanningForBeans];
    [sender endRefreshing];
}

-(IBAction)autoUnlockSwitched:(UISwitch *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:kBLAutoUnlockPref];
    
}

#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kBLPasswordPref];
    return YES;
}

#pragma mark - BLBeanStuffDelegate

- (void) didUpdateDiscoveredBeans:(NSArray *)discoveredBeans withBean:(PTDBean *)newBean
{
    self.beans=discoveredBeans;
    [self.beanTableView reloadData];
}


#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PTDBean *bean=[self.beans objectAtIndex:indexPath.row];
    self.targetBean=bean.identifier.UUIDString;
    NSString *targetBeanName=bean.name;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.targetBean forKey:kBLTargetBeanPref];
    [userDefaults setObject:targetBeanName forKey:kBLTargetBeanNamePref];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData];
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
    cell.detailTextLabel.text=bean.identifier.UUIDString;
    
    if ([self.targetBean isEqualToString:bean.identifier.UUIDString] ) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    return cell;
    
    
}

@end
