//
//  Payment.h
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BankAccount;

@interface Payment : NSObject

@property (nonatomic, copy)   NSString *uuid;
@property (nonatomic, strong) BankAccount *from;
@property (nonatomic, strong) BankAccount *to;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, copy)   NSString *currency;
@property (nonatomic, assign) NSTimeInterval due;
@property (nonatomic, assign) BOOL approved;
@property (nonatomic, copy)   NSString *approvalUri;

- (NSString *)formattedAmount;

- (NSString *)formattedDueDate;

+ (NSDictionary *)mapping;

@end
