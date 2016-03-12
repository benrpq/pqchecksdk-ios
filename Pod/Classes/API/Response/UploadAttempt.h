//
//  UploadAttempt.h
//  PQCheckSDK
//
//  Created by CJ on 24/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorisationStatus.h"

/**
 *  This class encapsulates the object returned by PQCheck server in response to an attempt to selfie video.
 *
 *  The status of the attempt is given by `authorisationStatus`, if the status is:
 *
 *  1. SUCCESS, then that's the end of the authorisation;
 *  2. OPEN, then the user should be asked to record another selfie video reading the transcript given by `nextDigest`;
 *  3. TIMED-OUT, then the authorisation has failed and a new authorisation has to be created;
 *  4. CANCELLED, then the authorisation has been called by the user and a new authorisation has to be created.
 */
@interface UploadAttempt : NSObject

/**
 *  The number of attempts
 */
@property (nonatomic, assign) NSUInteger number;

@property (nonatomic, copy)   NSString *status;

/**
 *  The transcript that the user needs to read while recording a selfie video if the authorisation status is still OPEN.
 */
@property (nonatomic, copy)   NSString *nextDigest;

/**
 *  The status of the authorisation
 *
 *  @see PQCheckAuthorisationStatus class
 */
@property (nonatomic, assign) PQCheckAuthorisationStatus authorisationStatus;

+ (NSDictionary *)mapping;

@end
