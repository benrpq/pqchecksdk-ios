/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

/**
 *  This class implements an account collection representation object. An array of this representation is returned by `[BankClientManager getAccountsWithUserUUID:completion:]` method of `BankClientManager` class.
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
