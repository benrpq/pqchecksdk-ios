//
//  Attempts.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 29/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "Attempts.h"

@implementation Attempts

+ (NSDictionary *)mapping
{
    return @{@"attemptNumber": @"attemptNumber",
             @"timestamp": @"timestamp",
             @"isSuccessful": @"isSuccessful"
            };
}

@end
