//
//  UploadAttempt.m
//  PQCheckSDK
//
//  Created by CJ on 24/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "UploadAttempt.h"

@interface UploadAttempt ()
{
    PQCheckAuthorisationStatus _authorisationStatus;
}
@end

@implementation UploadAttempt

- (void)setStatus:(NSString *)status
{
    _status = status;
    _authorisationStatus = [AuthorisationStatus authorisationStatusValueOfString:status];
}

- (void)setAuthorisationStatus:(PQCheckAuthorisationStatus)authorisationStatus
{
    _authorisationStatus = authorisationStatus;
    _status = [AuthorisationStatus authorisationStatusStringOfValue:authorisationStatus];
}

- (PQCheckAuthorisationStatus)authorisationStatus
{
    return _authorisationStatus;
}

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
