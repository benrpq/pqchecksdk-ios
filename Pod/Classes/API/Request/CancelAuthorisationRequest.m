//
//  CancelAuthorisationRequest.m
//  PQCheckSDK
//
//  Created by CJ on 23/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "CancelAuthorisationRequest.h"
#import "AuthorisationStatus.h"

@implementation CancelAuthorisationRequest

- (id)init
{
    self = [super init];
    if (self)
    {
        self.status = [AuthorisationStatus authorisationStatusStringOfValue:kPQCheckAuthorisationStatusCancelled];
    }
    return self;
}

- (void)setStatus:(NSString *)status
{
    // One cannot change the value of the status
    self.status = [AuthorisationStatus authorisationStatusStringOfValue:kPQCheckAuthorisationStatusCancelled];
}

+ (NSDictionary *)mapping
{
    return @{@"status": @"status"};
}

@end
