//
//  AccountsViewController.m
//  PQCheckThinSDK
//
//  Created by CJ on 02/01/2016.
//  Copyright (c) 2016 CJ. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "EntityClientManager.h"
#import "AccountCollection.h"
#import "AccountsViewController.h"
#import "PaymentsViewController.h"
#import "AccountCell.h"

static NSString *kAccountToPaymentSegue = @"AccountToPaymentSegue";

@interface AccountsViewController ()
{
    MBProgressHUD *hud;
    NSArray *_accounts;
    NSString *_userUUID;
    BOOL _isLoading;
}
@end

@implementation AccountsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    _isLoading = NO;
    
    _userUUID = [[NSUUID UUID] UUIDString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadAccounts];
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
        [viewController setUserUUID:_userUUID];
        [viewController setPayments:[[account payments] allObjects]];
    }
}

#pragma mark - Private methods

- (void)loadAccounts
{
    if (_isLoading)
    {
        return;
    }
    
    // Show HUD progress
    _isLoading = YES;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Please Wait...", @"Please Wait...");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EntityClientManager defaultManager] getAccountsWithUserUUID:_userUUID completion:^(NSArray *accounts, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _isLoading = NO;
                [hud hide:YES];
                
                if (error)
                {
                    [self showAlert:error];
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

- (void)showAlert:(NSError *)error
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
