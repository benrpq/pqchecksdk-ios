//
//  PaymentsViewController.m
//  PQCheckSample
//
//  Created by CJ on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.payments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Payment *payment = [self.payments objectAtIndex:indexPath.row];
    PaymentCell *cell = (PaymentCell *)[tableView dequeueReusableCellWithIdentifier:@"PaymentCellIdentifier"];
    cell.payeeLabel.text = payment.to.name;
    cell.amountLabel.text = [payment formattedAmount];
    cell.dueLabel.text = [payment formattedDueDate];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Select a payment to approve or decline", @"Select a payment to approve or decline");
}

#pragma mark - Segue actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kPaymentToPaymentDetailSegue])
    {
        PaymentDetailViewController *viewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Payment *payment = [self.payments objectAtIndex:indexPath.row];
        [viewController setUserUUID:self.userUUID];
        [viewController setPayment:payment];
    }
}

@end
