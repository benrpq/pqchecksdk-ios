//
//  Authorisation.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "Authorisation.h"

@implementation Authorisation

+ (NSDictionary *)mapping
{
    return @{@"uuid": @"uuid",
             @"status": @"status",
             @"digest": @"digest",
             @"startTime": @"startTime",
             @"expiryTime": @"expiryTime"};
}

@end
