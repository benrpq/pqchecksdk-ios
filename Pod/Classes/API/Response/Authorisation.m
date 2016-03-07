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
