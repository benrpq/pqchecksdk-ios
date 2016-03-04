//
//  AccountsViewController.m
//  PQCheckThinSDK
//
//  Created by CJ on 02/01/2016.
//  Copyright (c) 2016 CJ. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "EnrolmentViewController.h"
#import "BankClientManager.h"
#import "AccountCollection.h"
#import "AccountsViewController.h"
#import "PaymentsViewController.h"
#import "AccountCell.h"
#import "User.h"
#import "UserManager.h"

static NSString *kAccountToPaymentSegue = @"AccountToPaymentSegue";

@interface AccountsViewController ()
{
    MBProgressHUD *hud;
    NSArray *_accounts;
    User *_user;
    BOOL _isLoading;
}
@end

@implementation AccountsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    _isLoading = NO;
    
    _user = [[UserManager defaultManager] activeUser];
    if (_user == nil)
    {
        _user = [[User alloc] init];
    }
    
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetAccounts)];
    self.navigationItem.rightBarButtonItem = resetButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Is this user enrolled? A user must be enrolled before he/she
    // can use the system.
    if ([[UserManager defaultManager] isUserEnrolled:_user] == NO)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EnrolmentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EnrolmentViewController"];
        [viewController setUser:_user];
        [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else
    {
        [self loadAccounts];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_accounts)
    {
        return [_accounts count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountCollection *account = [_accounts objectAtIndex:indexPath.row];
    AccountCell *cell = (AccountCell *)[tableView dequeueReusableCellWithIdentifier:@"AccountCellIdentifier"];
    cell.nameLabel.text = account.name;
    cell.sortCodeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Sort-code: %@", @"Sort-code: %@"), account.sortCode];
    cell.numberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Account number: %@", @"Account number: %@"), account.number];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Please select an account", @"Please select an account");
}

#pragma mark - Segue actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kAccountToPaymentSegue])
    {
        PaymentsViewController *viewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AccountCollection *account = [_accounts objectAtIndex:indexPath.row];
        [viewController setUserUUID:_user.identifier];
        [viewController setPayments:[[account payments] allObjects]];
    }
}

#pragma mark - Private methods

- (void)resetAccounts
{
    _accounts = nil;
    _user = [[User alloc] init];
    
    // Enrol this new user
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EnrolmentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"EnrolmentViewController"];
    [viewController setUser:_user];
    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)loadAccounts
{
    if (_isLoading || (_accounts && [_accounts count] > 0))
    {
        return;
    }
    
    // Show HUD progress
    _isLoading = YES;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Please Wait...", @"Please Wait...");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[BankClientManager defaultManager] getAccountsWithUserUUID:_user.identifier completion:^(NSArray *accounts, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _isLoading = NO;
                [hud hide:YES];
                
                if (error)
                {
                    [self presentAlertViewControllerWithError:error];
                }
                else
                {
                    _accounts = [[NSArray alloc] initWithArray:accounts];
                    [self.tableView reloadData];
                }
            });
        }];
    });
}

- (void)presentAlertViewControllerWithError:(NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Nothing to do
    }];
    [alertController addAction:okButton];
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
