//
//  PaymentDetailViewController.h
//  PQCheckSample
//
//  Created by CJ on 29/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Payment;

@interface PaymentDetailViewController : UITableViewController

@property (nonatomic, strong) NSString *userUUID;
@property (nonatomic, strong) Payment *payment;

@end
