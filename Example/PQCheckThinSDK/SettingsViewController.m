/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "SettingsViewController.h"
#import "AccountsViewController.h"
#import "EnrolmentViewController.h"
#import "User.h"
#import "UserManager.h"

@interface SettingsViewController ()
{
    NSArray *enrolledUsers;
}
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@end

@implementation SettingsViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    enrolledUsers = [[[UserManager defaultManager] enrolledUsers] allObjects];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return [enrolledUsers count];
    }
    
    return 1;
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
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = [[[UserManager defaultManager] activeUser] name];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"ID";
            cell.detailTextLabel.text = [[[UserManager defaultManager] activeUser] identifier];
        }
    }
    else if (indexPath.section == 1)
    {
        static NSString *subtitleCellIdentifier = @"SubtitleCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:subtitleCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:subtitleCellIdentifier];
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
    else if (indexPath.section == 2)
    {
        static NSString *defaultCellIdentifier = @"DefaultCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier];
        }

        UIColor *color = [UIColor colorWithRed:13.0f/255.0f
                                         green:185.0f/255.0f
                                          blue:78.0f/255.0f
                                         alpha:1.0f];
        cell.textLabel.textColor = color;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        cell.textLabel.text = NSLocalizedString(@"New User", @"New User");
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"Active User", @"Active User");
    }
    else if (section == 1)
    {
        return NSLocalizedString(@"Enrolled Users", @"Enrolled Users");
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0 && [[UserManager defaultManager] activeUser])
    {
        return NSLocalizedString(@"Tap on Name to change the name of the active user", @"Tap on Name to change the name of the active user");
    }
    else if (section == 1 && [enrolledUsers count] > 0)
    {
        return NSLocalizedString(@"Tap to select an active user or swipe to delete a user.", @"Tap to select an active user or swipe to delete a user.");
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return YES;
    }
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && editingStyle == UITableViewCellEditingStyleDelete)
    {
        User *user = [enrolledUsers objectAtIndex:indexPath.row];
        [[UserManager defaultManager] deleteEnrolledUser:user];
        enrolledUsers = [[[UserManager defaultManager] enrolledUsers] allObjects];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [self editActiveUserName];
        }
    }
    else if (indexPath.section == 1)
    {
        [self resetAccounts];
        
        User *user = [enrolledUsers objectAtIndex:indexPath.row];
        [[UserManager defaultManager] setActiveUser:user];
        
        [tableView reloadData];
    }
    else if (indexPath.section == 2)
    {
        [self enrolUser];
    }
}

#pragma mark - Private methods

- (IBAction)doneButtonTapped:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetAccounts
{
    if ([[self presentingViewController] isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController *)[self presentingViewController];
        if ([[[navController viewControllers] lastObject] isKindOfClass:[AccountsViewController class]])
        {
            AccountsViewController *viewController = [[navController viewControllers] lastObject];
            [viewController resetAccounts];
        }
    }
}

- (void)enrolUser
{
    [self resetAccounts];
    
    User *aNewUser = [[User alloc] init];
    
    // Enrol this new user
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EnrolmentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EnrolmentViewController"];
    [viewController setUser:aNewUser];
    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)editActiveUserName
{
    User *activeUser = [[UserManager defaultManager] activeUser];
    if (activeUser == nil)
    {
        return;
    }
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Name", @"Name") message:NSLocalizedString(@"Set the name of this active user", @"Set the name of this active user") preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = activeUser.name;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.placeholder = NSLocalizedString(@"Active user name", @"Active user name");
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = controller.textFields.firstObject;
        NSString *newName = textField.text;
        if (newName && [newName length] > 0)
        {
            activeUser.name = textField.text;
            [[UserManager defaultManager] setActiveUser:activeUser];
            [[UserManager defaultManager] update];
            
            enrolledUsers = [[[UserManager defaultManager] enrolledUsers] allObjects];
            [self.tableView reloadData];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Do nothing
    }];
    [controller addAction:okAction];
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:^{
        UITextField *textField = controller.textFields.firstObject;
        [textField selectAll:nil];
    }];
}

@end
