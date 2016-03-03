//
//  BankAccount.m
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "BankAccount.h"

@implementation BankAccount

+ (NSDictionary *)mapping
{
    return @{@"sortCode": @"sortCode",
             @"number": @"number",
             @"name": @"name"
             };
}

@end
