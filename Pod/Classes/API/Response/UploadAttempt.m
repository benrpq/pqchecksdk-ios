//
//  UploadAttempt.m
//  PQCheckSDK
//
//  Created by CJ on 24/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "UploadAttempt.h"

@implementation UploadAttempt

- (NSString *)description
{
    NSDictionary *dict = @{@"number" : @(self.number),
                           @"status": self.status,
                           @"nextDigest": self.nextDigest
                           };
    return [dict description];
}

+ (NSDictionary *)mapping
{
    return @{@"number": @"number",
             @"status": @"status",
             @"nextDigest": @"nextDigest"};
}

@end
