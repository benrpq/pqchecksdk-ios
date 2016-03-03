//
//  BankAccountCell.h
//  PQCheckSample
//
//  Created by CJ on 29/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankAccountCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sortCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;

@end
