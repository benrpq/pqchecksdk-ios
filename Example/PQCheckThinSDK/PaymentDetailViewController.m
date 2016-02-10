//
//  PaymentDetailViewController.m
//  PQCheckSample
//
//  Created by CJ on 29/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <PQCheckSDK/PQCheckManager.h>
#import "EntityClientManager.h"
#import "BankAccount.h"
#import "PaymentDetailViewController.h"
#import "BankAccountCell.h"
#import "DetailCell.h"

@interface PaymentDetailViewController () <PQCheckManagerDelegate>
{
    MBProgressHUD *_hud;
    // We need to set PQCheckManager to be a member of this class, otherwise
    // the allocated instance of this object will be released too early. We
    // need the instance as it contains selfie recorder's delegate
    PQCheckManager *_manager;
    BOOL _isPaymentInProgress;
}
@end

@implementation PaymentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 4;
    }
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"Please confirm the details below", @"Please confirm the details below");
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row < 2)
        {
            BankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BankAccountCellIdentifier" forIndexPath:indexPath];
            BankAccount *account = self.payment.from;
            cell.titleLabel.text = NSLocalizedString(@"From", @"From");
            if (indexPath.row == 1)
            {
                account = self.payment.to;
                cell.titleLabel.text = NSLocalizedString(@"To", @"To");
            }
            
            cell.nameLabel.text = account.name;
            cell.sortCodeLabel.text = account.sortCode;
            cell.numberLabel.text = account.number;
            
            return cell;
        }
        else
        {
            DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCellIdentifier" forIndexPath:indexPath];
            if (indexPath.row == 2)
            {
                cell.titleLabel.text = NSLocalizedString(@"Amount", @"Amount");
                cell.detailLabel.text = [self.payment formattedAmount];
            }
            else
            {
                cell.titleLabel.text = NSLocalizedString(@"Due Date", @"Due Date");
                cell.detailLabel.text = [self.payment formattedDueDate];
            }
            
            return cell;
        }
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCellIdentifier" forIndexPath:indexPath];
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"Confirm", @"Confirm");
            cell.textLabel.textColor = [UIColor greenColor];
        }
        else
        {
            cell.textLabel.text = NSLocalizedString(@"Decline", @"Decline");
            cell.textLabel.textColor = [UIColor redColor];
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row < 2)
    {
        return 64.0f;
    }
    
    return 44.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        [self confirmPayment];
    }
    else if (indexPath.section == 1 && indexPath.row == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - PQCheckViewController delegates

- (void)PQCheckManager:(PQCheckManager *)controller didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Do nothing
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)PQCheckManager:(PQCheckManager *)controller didFinishWithAuthorisationStatus:(PQCheckAuthorisationStatus)status
{
    UIView *view = [[[UIApplication sharedApplication] delegate] window];
    if (status == kPQCheckAuthorisationStatusSuccessful)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Great, job done", @"Great, job done");
        [hud hide:YES afterDelay:1.0f];
        
        self.payment.approved = YES;
        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else if (status == kPQCheckAuthorisationStatusTimedOut)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Ooops, timed-out", @"Ooops, timed-out");
        [hud hide:YES afterDelay:1.0f];
        
        self.payment.approved = NO;
        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else if (status == kPQCheckAuthorisationStatusCancelled)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Sorry, cancelled", @"Sorry, cancelled");
        [hud hide:YES afterDelay:1.0f];
        
        self.payment.approved = NO;
        [self dismissViewControllerAnimated:YES completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else if (status == kPQCheckAuthorisationStatusOpen)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Please try again", @"Please try again");
        [hud hide:YES afterDelay:1.0f];
    }
}

#pragma mark - Private methods

- (void)confirmPayment
{
    // Show HUD progress
    _isPaymentInProgress = YES;
    
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    _hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = NSLocalizedString(@"Please Wait...", @"Please Wait...");

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EntityClientManager defaultManager] approvePaymentWithUUID:self.payment.uuid userUUID:self.userUUID completion:^(Authorisation *authorisation, NSError *error) {
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _manager = [[PQCheckManager alloc] initWithAuthorisation:authorisation];
                    [_manager setDelegate:self];
                    [_manager setShouldPaceUser:YES];
                    [_manager performAuthentication];
                    
                    [[MBProgressHUD HUDForView:window] hide:YES];
                });
            }
        }];
    });
}

@end
