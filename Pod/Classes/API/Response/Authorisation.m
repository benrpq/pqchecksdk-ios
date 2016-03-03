//
//  Authorisation.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "Authorisation.h"

@interface Authorisation ()
{
    PQCheckAuthorisationStatus _authorisationStatus;
}
@end

@implementation Authorisation

- (void)setStatus:(NSString *)status
{
    _status = status;
    _authorisationStatus = [AuthorisationStatus authorisationStatusValueOfString:status];
}

- (PQCheckAuthorisationStatus)authorisationStatus
{
    return _authorisationStatus;
}

- (void)setAuthorisationStatus:(PQCheckAuthorisationStatus)authorisationStatus
{
    _authorisationStatus = authorisationStatus;
    _status = [AuthorisationStatus authorisationStatusStringOfValue:authorisationStatus];
}

+ (NSDictionary *)mapping
{
    return @{@"uuid": @"uuid",
             @"status": @"status",
             @"digest": @"digest",
             @"mustHaveHistory": @"mustHaveHistory",
             @"startTime": @"startTime",
             @"expiryTime": @"expiryTime"};
}

@end
