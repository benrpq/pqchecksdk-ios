//
//  AuthorisationStatus.m
//  PQCheckSDK
//
//  Created by CJ on 23/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "AuthorisationStatus.h"

static NSString* kOpenAuthorisationStatusString = @"OPEN";
static NSString* kSuccessAuthorisationStatusString = @"SUCCESSFUL";
static NSString* kCancelledAuthorisationStatusString = @"CANCELLED";
static NSString* kTimedOutAuthorisationStatusString = @"TIMED_OUT";
static NSString* kUnknownAuthorisationStatusString = @"UNKNOWN";

@implementation AuthorisationStatus

+ (PQCheckAuthorisationStatus)authorisationStatusValueOfString:(NSString *)str
{
    if ([str caseInsensitiveCompare:kOpenAuthorisationStatusString] == 0)
    {
        return kPQCheckAuthorisationStatusOpen;
    }
    else if ([str caseInsensitiveCompare:kSuccessAuthorisationStatusString] == 0)
    {
        return kPQCheckAuthorisationStatusSuccessful;
    }
    else if ([str caseInsensitiveCompare:kCancelledAuthorisationStatusString] == 0)
    {
        return kPQCheckAuthorisationStatusCancelled;
    }
    else if ([str caseInsensitiveCompare:kTimedOutAuthorisationStatusString] == 0)
    {
        return kPQCheckAuthorisationStatusTimedOut;
    }
    else
    {
        return kPQCheckAuthorisationStatusUnknown;
    }
}

+ (NSString *)authorisationStatusStringOfValue:(PQCheckAuthorisationStatus)value
{
    switch (value) {
        case kPQCheckAuthorisationStatusOpen:
            return kOpenAuthorisationStatusString;
        case kPQCheckAuthorisationStatusSuccessful:
            return kSuccessAuthorisationStatusString;
        case kPQCheckAuthorisationStatusCancelled:
            return kCancelledAuthorisationStatusString;
        case kPQCheckAuthorisationStatusTimedOut:
            return kTimedOutAuthorisationStatusString;
        default:
            return kUnknownAuthorisationStatusString;
    }
}

@end
