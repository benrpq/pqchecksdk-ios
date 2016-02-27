//
//  Payment.h
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BankAccount;

/**
 *  This class implement a payment representation object.
 *
 *  @see AccountCollection class
 */
@interface Payment : NSObject

/**
 *  The identifier of the payment.
 */
@property (nonatomic, copy)   NSString *uuid;

/**
 *  The bank account of the sender, @see `BankAccount` class.
 */
@property (nonatomic, strong) BankAccount *from;

/**
 *  The bank account of the recipient, @see `BankAccount` class.
 */
@property (nonatomic, strong) BankAccount *to;

/**
 *  The sum of the payment.
 */
@property (nonatomic, strong) NSNumber *amount;

/**
 *  The currency of the payment.
 */
@property (nonatomic, copy)   NSString *currency;

/**
 *  The date when the payment will expire.
 */
@property (nonatomic, assign) NSTimeInterval due;

/**
 *  An indicator whether or not the payment has been approved.
 */
@property (nonatomic, assign) BOOL approved;

/**
 *  The payment approval URL, which can be queried to return a payment authorisation representation.
 */
@property (nonatomic, copy)   NSString *approvalUri;

/**
 *  Returns a human-readable string representating the amount of the payment
 *
 *  @return The human-readable form of the payment value
 */
- (NSString *)formattedAmount;

/**
 *  Returns a human-readable string representating the expiry date of the payment
 *
 *  @return The human-readable form of the payment expiry date
 */
- (NSString *)formattedDueDate;

/**
 *  The JSON mapping required by RestKit
 *
 *  @return The RestKit mapping dictionary
 */
+ (NSDictionary *)mapping;

@end
