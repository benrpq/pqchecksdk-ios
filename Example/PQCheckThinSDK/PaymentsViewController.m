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

#import "BankAccount.h"
#import "Payment.h"
#import "PaymentsViewController.h"
#import "PaymentDetailViewController.h"
#import "PaymentCell.h"

static NSString *kPaymentToPaymentDetailSegue = @"PaymentToPaymentDetailSegue";

@implementation PaymentsViewController

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

- (void)setPayments:(NSArray *)payments
{
    NSMutableArray *approvedPayments = [NSMutableArray new];
    NSMutableArray *nonapprovedPayments = [NSMutableArray new];
    for (Payment *aPayment in payments)
    {
        if (aPayment.approved)
        {
            [approvedPayments addObject:aPayment];
        }
        else
        {
            [nonapprovedPayments addObject:aPayment];
        }
    }
    
    _payments = @[nonapprovedPayments, approvedPayments];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSMutableArray *nonapprovedPayments = [self.payments objectAtIndex:0];
    NSMutableArray *approvedPayments = [self.payments objectAtIndex:1];
    for (Payment *aPayment in [nonapprovedPayments mutableCopy])
    {
        if (aPayment.approved)
        {
            [nonapprovedPayments removeObject:aPayment];
            [approvedPayments addObject:aPayment];
        }
    }
    
    _payments = @[nonapprovedPayments, approvedPayments];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.payments count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.payments objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Payment *payment = [[self.payments objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    PaymentCell *cell = (PaymentCell *)[tableView dequeueReusableCellWithIdentifier:@"PaymentCellIdentifier"];
    cell.payeeLabel.text = payment.to.name;
    cell.amountLabel.text = [payment formattedAmount];
    cell.dueLabel.text = [payment formattedDueDate];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (payment.approved == YES)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"Select a payment to approve or decline", @"Select a payment to approve or decline");
    }
    
    return NSLocalizedString(@"Approved payments", @"Approved payments");
}

#pragma mark - Segue actions

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:kPaymentToPaymentDetailSegue])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Payment *payment = [[self.payments objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return (payment.approved == NO);
    }
    
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kPaymentToPaymentDetailSegue])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Payment *payment = [[self.payments objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if (payment.approved == NO)
        {
            PaymentDetailViewController *viewController = [segue destinationViewController];
            [viewController setUserUUID:self.userUUID];
            [viewController setPayment:payment];
        }
    }
}

@end
