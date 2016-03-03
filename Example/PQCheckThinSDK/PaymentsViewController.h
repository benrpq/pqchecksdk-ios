//
//  PaymentsViewController.h
//  PQCheckSample
//
//  Created by CJ on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentsViewController : UITableViewController

@property (nonatomic, strong) NSArray *payments;
@property (nonatomic, strong) NSString *userUUID;

@end
