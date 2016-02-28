//
//  AuthorisationStatus.h
//  PQCheckSDK
//
//  Created by CJ on 23/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

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
