//
//  CancelAuthorisationRequest.m
//  PQCheckSDK
//
//  Created by CJ on 23/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "CancelAuthorisationRequest.h"

@interface CancelAuthorisationRequest ()
{
    PQCheckAuthorisationStatus _authorisationStatus;
}
@end

@implementation CancelAuthorisationRequest

- (id)init
{
    self = [super init];
    if (self)
    {
        _authorisationStatus = kPQCheckAuthorisationStatusCancelled;
        _status = [AuthorisationStatus authorisationStatusStringOfValue:kPQCheckAuthorisationStatusCancelled];
    }
    return self;
}

+ (NSDictionary *)mapping
{
    return @{@"status": @"status"};
}

@end
