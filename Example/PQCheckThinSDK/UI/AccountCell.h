//
//  AccountCell.h
//  PQCheckSample
//
//  Created by CJ on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sortCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;

@end
