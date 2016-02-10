//
//  PaymentCell.h
//  PQCheckSample
//
//  Created by CJ on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *payeeLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *dueLabel;

@end
