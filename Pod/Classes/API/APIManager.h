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

@class Authorisation;
@class UploadAttempt;

/**
 *  `APIManager` provides convenient methods to interface with PQCheck server. 
 *
 *  The following REST APIs are encapsulated by `APIManager` class:
 *
 *  - View an authorisation at a given secret URL,
 *  - Upload a selfie video in response to an authorisation, and
 *  - Enrol a user by uploading a selfie video to a given remote URL.
 */
@interface APIManager : NSObject

/**
 *  Returns the shared API manager object.
 *
 *  @return The default `APIManager` object
 */
+ (APIManager *)sharedManager;

/**
 *  Sets the acceptable PQCheck API profile.
 *
 *  All REST endpoints have a PQCheck API profile and the client needs to indicate acceptable profile via HTTP `Accept` header. This method does the job for the client.
 *
 *  @param profile PQCheck profile string
 */
- (void)setProfile:(NSString *)profile;

/**
 *  Sets the acceptable PQCheck API version.
 *
 *  All REST endpoints have a PQCheck API version and the client needs to indicate acceptable API version via HTTP `Accept` header. This method does the job for the client.
 *
 *  @note The version value should be a single natural number.
 *
 *  @param version PQCheck API version
 */
- (void)setVersion:(NSNumber *)version;

/**
 *  Sends a request to view an authorisation at the given secret `url`.
 *
 *  @param url             The secret URL of an authorisation
 *  @param completionBlock A block object to be executed when this request is completed. This block has no return value and takes two arguments: an instance of `Authorisation` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `Authorisation` object is `nil`. On the other hand, if it is successful, `NSError` object is `nil` and `Authorisation` object, which contains `digest` and `upload-attempt` amongst other information, should then be passed to PQCheck SDK, which in turn should request a user to perform a selfie reading `digest` and submit the resulting selfie video to `upload-attempt`.
 *
 *  @see Authorisation class
 */
- (void)viewAuthorisationAtURL:(NSURL *)url
                    completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;

/**
 *  Uploads a selfie video at file URL `mediaURL` to a URL specified in authorisation representation, `Authorisation`.
 *
 *  @param authorisation   The authorisation representation.
 *  @param mediaURL        The file URL at which the selfie video is located.
 *  @param completionBlock A block object to be executed when the upload is completed. This block has no return value and takes two arguments: an instance of `UploadAttempt` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `UploadAttempt` object is `nil`. On the other hand, if it is successful, `NSError` object is `nil` and `UploadAttempt` object, which contains `number`, `status` and `nextDigest`, should then be used to decide a follow-up action.
 *
 *  @discussion Despite a successful upload, the selfie video may be rejected by PQCheck server due to incorrect biometric or expired authorisation, therefore the status of `UploadAttempt` object needs to be inspected.
 *
 *  @see UploadAttempt class
 */
- (void)uploadAttemptWithAuthorisation:(Authorisation *)authorisation
                              mediaURL:(NSURL *)mediaURL
                            completion:(void (^)(UploadAttempt *uploadAttempt, NSError *error))completionBlock;

/**
 *  Enrols a user by uploading a selfie video, which is located at file URL `mediaURL`, to a remote URL `uploadURL`.
 *
 *  @param mediaURL        The file URL at which the selfie video is located.
 *  @param uploadURL       The remote target URL to which the selfie video will be uploaded.
 *  @param completionBlock A block object to be executed when the upload is completed. This block has no return value and takes an argument, which is an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil`, otherwise it is `nil`.
 *
 *  @discussion A user identifier is not required as it's implicitly given by the remote URL `uploadURL`.
 */
- (void)enrolUserWithMediaURL:(NSURL *)mediaURL
                    uploadURL:(NSURL *)uploadURL
                   completion:(void (^)(NSError *error))completionBlock;

@end
