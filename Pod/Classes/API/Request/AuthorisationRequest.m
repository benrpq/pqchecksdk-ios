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
           authorisationHash:(NSString *)authorisationHash
                     summary:(NSString *)summary
{
    self = [super init];
    if (self)
    {
        self.userIdentifier = identifier;
        self.authorisationHash = authorisationHash;
        self.summary = summary;
    }
    return self;
}

+ (NSDictionary *)mapping
{
    return @{@"userIdentifier": @"userIdentifier",
             @"hash": @"authorisationHash",
             @"summary": @"summary"};
}

@end
