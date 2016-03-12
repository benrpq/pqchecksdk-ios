//
//  APIManager.h
//  PQCheckSDK
//
//  Created by CJ on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef THINSDK
#import "APIKey.h"
#endif
#import "Authorisation.h"
#import "UploadAttempt.h"

typedef NS_ENUM(NSInteger, PQCheckEndpoint)
{
    kStableEndpoint = 0,
    kUnstableEndpoint,
    kDevelopmentEndpoint,
    kDataCollectionEndpoint
};

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
 *  Returns the current PQCheck endpoint
 *
 *  @return Return URL string of the current PQCheck endpoint
 */
- (NSString *)currentPQCheckEndpoint;

/**
 *  Set the endpoint of PQCheck
 *
 *  @param endpoint The endpoint
 */
- (void)setPQCheckEndpoint:(PQCheckEndpoint)endpoint;

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

#ifndef THINSDK
/**
 *  Creates an authorisation given an identifier, authorisation hash and summary
 *
 *  @param apiKey            The API key which can be obtained from dashboard
 *  @param identifier        The identifier that represents a user
 *  @param authorisationHash The short hash value (3-digit numbers) of the authorisation
 *  @param summary           The summary of the authorisation
 *  @param completionBlock   The block to be executed when the creation request is completed. This block has no return value and takes two arguments: an instance of `Authorisation` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `Authorisation` object is `nil`. On the other hand, if it is successful, `NSError` object is `nil` and `Authorisation` object, which contains `digest` and `upload-attempt` amongst other information, should then be used for the purpose of selfie. The user should read the `digest` and submit the resulting selfie video to `upload-attempt`.
 */
- (void)createAuthorisationWithAPIKey:(APIKey *)apiKey
                       userIdentifier:(NSString *)identifier
                    authorisationHash:(NSString *)authorisationHash
                              summary:(NSString *)summary
                           completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;

/**
 *  Sends a request to view an authorisation for a given `uuid`.
 *
 *  @param apiKey            The API key which can be obtained from dashboard
 *  @param uuid              The UUID that represents the authorisation
 *  @param completionBlock   The block object to be executed when this request is completed. This block has no return value and takes two arguments: an instance of `Authorisation` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `Authorisation` object is `nil`. On the other hand, if it is successful, `NSError` object is `nil` and `Authorisation` object, which contains `digest` and `upload-attempt` amongst other information, should then be used for the purpose of selfie. The user should read the `digest` and submit the resulting selfie video to `upload-attempt`.
 *
 *  @see Authorisation class
 */
- (void)viewAuthorisationRequestWithAPIKey:(APIKey *)apiKey
                                      UUID:(NSString *)uuid
                                completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;
#else
/**
 *  Sends a request to view an authorisation at the given secret `url`.
 *
 *  @param url             The secret URL of an authorisation
 *  @param completionBlock A block object to be executed when this request is completed. This block has no return value and takes two arguments: an instance of `Authorisation` object and an instance of `NSError` object. If this request is not successful, `NSError` object is not `nil` and `Authorisation` object is `nil`. On the other hand, if it is successful, `NSError` object is `nil` and `Authorisation` object, which contains `digest` and `upload-attempt` amongst other information, should then be used for the purpose of selfie. The user should read the `digest` and submit the resulting selfie video to `upload-attempt`.
 *
 *  @see Authorisation class
 */
- (void)viewAuthorisationRequestWithUUID:(NSString *)uuid
                              completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock;
#endif

#ifndef THINSDK
/**
 *  Cancels an authorisation with a given UUID
 *
 *  @param uuid            The UUID of the authorisation to be cancelled
 *  @param completionBlock The block that is executed when the cancelation request is completed.
 */
- (void)cancelAuthorisationRequestWithUUID:(NSString *)uuid
                                completion:(void (^)(NSError *error))completionBlock;
#endif

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

#ifndef THINSDK
/**
 *  Enrols a user with a given identifier, reference, transcript and a URL to a
 *
 *  @param apiKey          The API key which can be obtained from dashboard
 *  @param identifier      The identifier of the user to be enrolled
 *  @param reference       The reference (not used at the moment)
 *  @param transcript      The transcript of enrolment
 *  @param mediaURL        The media URL of the video
 *  @param completionBlock The block to be executed when the enrolment is completed.
 */
- (void)enrolUserWithAPIKey:(APIKey *)apiKey
             userIdentifier:(NSString *)identifier
                  reference:(NSString *)reference
                 transcript:(NSString *)transcript
                   mediaURL:(NSURL *)mediaURL
                 completion:(void (^)(NSError *error))completionBlock;
#endif

@end
