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
