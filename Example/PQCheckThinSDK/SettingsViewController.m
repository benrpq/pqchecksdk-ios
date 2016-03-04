//
//  SettingsViewController.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 04/03/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import "SettingsViewController.h"
#import "User.h"
#import "UserManager.h"

@interface SettingsViewController ()
{
    NSArray *enrolledUsers;
}
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    enrolledUsers = [[[UserManager defaultManager] enrolledUsers] allObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    if (indexPath.section == 0)
    {
        static NSString *value2CellIdentifier = @"Value2CellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:value2CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:value2CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"ID";
            cell.detailTextLabel.text = [[[UserManager defaultManager] activeUser] identifier];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = [[[UserManager defaultManager] activeUser] name];
        }
    }
    else
    {
        static NSString *defaultCellIdentifier = @"DefaultCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:defaultCellIdentifier];
        }
        
        User *user = [enrolledUsers objectAtIndex:indexPath.row];
        cell.textLabel.text = user.name;
        if ([user.name caseInsensitiveCompare:user.identifier] != NSOrderedSame)
        {
            cell.detailTextLabel.text = user.identifier;
        }
        else
        {
            cell.detailTextLabel.text = nil;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"Active User", @"Active User");
    }
    
    return NSLocalizedString(@"Enrolled Users", @"Enrolled Users");
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        User *user = [enrolledUsers objectAtIndex:indexPath.row];
        [[UserManager defaultManager] setActiveUser:user];
        
        [self.tableView reloadData];
    }
}

#pragma mark - Private methods

- (IBAction)doneButtonTapped:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
