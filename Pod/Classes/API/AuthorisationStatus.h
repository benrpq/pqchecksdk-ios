//
//  AuthorisationStatus.h
//  PQCheckSDK
//
//  Created by CJ on 23/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PQCheckAuthorisationStatus : NSUInteger
{
    kPQCheckAuthorisationStatusUnknown,
    kPQCheckAuthorisationStatusOpen,
    kPQCheckAuthorisationStatusSuccessful,
    kPQCheckAuthorisationStatusCancelled,
    kPQCheckAuthorisationStatusTimedOut
}
PQCheckAuthorisationStatus;

@interface AuthorisationStatus : NSObject

+ (PQCheckAuthorisationStatus)authorisationStatusValueOfString:(NSString *)str;

+ (NSString *)authorisationStatusStringOfValue:(PQCheckAuthorisationStatus)value;

@end
