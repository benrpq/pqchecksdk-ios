//
//  AccountCollection.h
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class implement an account collection representation object. An array of this representation is returned by `[BankClientManager getAccountsWithUserUUID:completion:]` method of `BankClientManager` class.
 */
@interface AccountCollection : NSObject

/**
 *  The sort-code of the account
 */
@property (nonatomic, copy)   NSString *sortCode;

/**
 *  The number of the account
 */
@property (nonatomic, copy)   NSString *number;

/**
 *  The name of the account holder
 */
@property (nonatomic, copy)   NSString *name;

/**
 *  A set of payments, each is represented by `Payment` class
 *
 *  @see Payment class
 */
@property (nonatomic, strong) NSSet *payments;

/**
 *  The JSON mapping required by RestKit
 *
 *  @return The RestKit mapping dictionary
 */
+ (NSDictionary *)mapping;

@end
