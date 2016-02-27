//
//  BankAccount.h
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class implement a bank account representation object.
 */
@interface BankAccount : NSObject

/**
 *  The sort-code of the account
 */
@property (nonatomic, copy) NSString *sortCode;

/**
 *  The number of the account
 */
@property (nonatomic, copy) NSString *number;

/**
 *  The name of the account holder
 */
@property (nonatomic, copy) NSString *name;

/**
 *  The JSON mapping required by RestKit
 *
 *  @return The RestKit mapping dictionary
 */
+ (NSDictionary *)mapping;

@end
