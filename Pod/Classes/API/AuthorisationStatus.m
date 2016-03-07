/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
