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

#import <Foundation/Foundation.h>

/**
 *  Constants to specify the status of PQCheck authorisation.
 */
typedef NS_ENUM(NSUInteger, PQCheckAuthorisationStatus)
{
    /**
     *  Unknown status, which may be used for compatibility purposes
     */
    kPQCheckAuthorisationStatusUnknown,
    /**
     *  The authorisation is still OPEN. An authorisation will remain in this state until a correct selfie video is attempted, or until it has been cancelled or timed-out.
     */
    kPQCheckAuthorisationStatusOpen,
    /**
     *  The authorisation is in SUCCESS state in response to a correct selfie video attempt.
     */
    kPQCheckAuthorisationStatusSuccessful,
    /**
     *  The authorisation has been cancelled by the user.
     */
    kPQCheckAuthorisationStatusCancelled,
    /**
     *  The authorisation has timed-out.
     */
    kPQCheckAuthorisationStatusTimedOut
};

/**
 *  `AuthorisationStatus` class implements convenient methods to convert the status returned by PQCheck server to `PQCheckAuthorisationStatus` enumeration type.
 */
@interface AuthorisationStatus : NSObject

/**
 *  Returns `PQCheckAuthorisationStatus` enumeration type for a given status string.
 *
 *  @param str The status string
 *
 *  @return Return the equivalent `PQCheckAuthorisationStatus` representation.
 */
+ (PQCheckAuthorisationStatus)authorisationStatusValueOfString:(NSString *)str;

/**
 *  Returns the string value of a given `PQCheckAuthorisationStatus` enumeration type.
 *
 *  @param value The `PQCheckAuthorisationStatus` value
 *
 *  @return Return the equivalent string representation.
 */
+ (NSString *)authorisationStatusStringOfValue:(PQCheckAuthorisationStatus)value;

@end
