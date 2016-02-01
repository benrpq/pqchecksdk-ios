//
//  AuthorisationRequest.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "AuthorisationRequest.h"

@implementation AuthorisationRequest

- (id)initWithUserIdentifier:(NSString *)identifier
                      digest:(NSString *)digest
                     summary:(NSString *)summary
{
    self = [super init];
    if (self)
    {
        self.userIdentifier = identifier;
        self.digest = digest;
        self.summary = summary;
    }
    return self;
}

+ (NSDictionary *)mapping
{
    return @{@"userIdentifier": @"userIdentifier",
             @"hash": @"digest",
             @"summary": @"summary"};
}

@end
