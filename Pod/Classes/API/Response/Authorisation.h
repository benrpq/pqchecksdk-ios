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
#import "Links.h"
#import "AuthorisationStatus.h"

/**
 *  The class implements an authorisation representation.
 *
 *  When a user performs an operation that requires PQCheck, an authorisation has to be created in the first place. A new authorisation begins its life with OPEN state and may turn to SUCCESS state after a correct selfie video has been submitted. The transcript of what to read and the upload URL of the selfie video are all encapsulated in this class.
 *
 *  Each authorisation has a validity period, after which, the state will change to TIMED-OUT.
 */
@interface Authorisation : NSObject

/**
 *  The identifier of the authorisation.
 */
@property (nonatomic, copy)   NSString *uuid;

@property (nonatomic, copy)   NSString *status;

/**
 *  The digest represents the transcript of what a user should read while recording a selfie video.
 */
@property (nonatomic, copy)   NSString *digest;

/**
 *  The boolean value that whether or not an enrolment is mandatory before authorisation can be performed.
 */
@property (nonatomic, assign) BOOL mustHaveHistory;

/**
 *  The UNIX timestamp representing the time when the authorisation becomes active.
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/**
 *  The UNIX timestamp representing the expiry of the authorisation.
 */
@property (nonatomic, assign) NSTimeInterval expiryTime;

@property (nonatomic, strong) NSArray *attempts;

/**
 *  The links to various locations of an authorisation.
 *
 *  @see Links class
 */
@property (nonatomic, strong) Links *links;

/**
 *  The authorisation status of the authorisation.
 *
 *  @see PQCheckAuthorisationStatus
 */
@property (nonatomic, assign) PQCheckAuthorisationStatus authorisationStatus;

+ (NSDictionary *)mapping;

@end
