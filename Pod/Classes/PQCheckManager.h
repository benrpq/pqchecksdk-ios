//
//  PQCheckManager.h
//  Pods
//
//  Created by CJ Tjhai on 01/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "AuthorisationStatus.h"

@class Authorisation;
@protocol PQCheckManagerDelegate;

/**
 *  `PQCheckManager` wraps the complexity of PQCheck into an easy-to-use class. Using this class, all you need to do to perform an authorisation or enrolment is to call the respective method and wire up the appropriate delegate methods.
 *
 *  Two types of customisation are available. The first one is for pacing a user while he/she is recording a selfie video. The other customisation is for controlling whether another selfie attempt should be launched automatically in the event of failure.
 */
@interface PQCheckManager : NSObject

/**
 *  The delegate of the PQCheck manager object.
 */
@property (nonatomic, weak)   id<PQCheckManagerDelegate> delegate;

/**
 *  The boolean value that indicates whether or not another attempt should be made automatically in the event of failure on the previous attempt.
 *
 *  @discussion If the boolean value is `NO`, in the event of attempt failure, an alert view controller will be presented to the user asking him/her to record another selfie attempt.
 */
@property (nonatomic, assign) BOOL autoAttemptOnFailure;

/**
 *  The boolean value that indicates whether or not a user should be paced while reading a selfie transcript.
 *
 *  @discussion If the boolean value is `NO`, the user needs to perform a press-and-hold action in order to record a selfie. Otherwise, the recording of selfie will start after a short delay with the transcript shown digit-by-digit and will finish after the last digit of the transcript is shown.
 */
@property (nonatomic, assign) BOOL shouldPaceUser;

#ifndef THINSDK
/**
 *  Initialises PQCheckManager object with a given `userIdentifier`
 *
 *  @param userIdentifier The user identifier
 *
 *  @return Return an initialised instance of PQCheckManager
 */
- (id)initWithUserIdentifier:(NSString *)userIdentifier;

/**
 *  Current namespace
 *
 *  @return Return the current namespace
 */
- (NSString *)currentNamespace;
#else
- (id)initWithAuthorisation:(Authorisation *)authorisation;
#endif

/**
 *  Performs an authorisation with for a given `authorisationHash` and `summary`.
 *
 *  @discussion Performing an authorisation requires a user to record a selfie video reading the transcript given by `hash`. The resulting video will then be uploaded to a URL specified in the authorisation representation. If the upload is successful, the delegate method `PQCheckManager:didFinishWithAuthorisationStatus:` will be invoked. On the other hand, if the upload has failed or there is an error during recording, the delegate method `PQCheckManager:didFailWithError:` will be invoked instead.
 *
 *  @param authorisationHash The authorisation digest or hash value
 *  @param summary           The summary of a transaction to be authorised
 *
 *  @see PQCheckManagerDelegate protocol
 */
- (void)performAuthorisationWithHash:(NSString *)authorisationHash summary:(NSString *)summary;

/**
 *  Performs a user enrolment with the given `reference` and `transcript`.
 *
 *  @discussion Enroling a user requires the user to record a selfie video reading a `transcript`. The resulting video will then be uploaded to a URL given by PQCheck server. If the upload is successful, the delegate method `PQCheckManagerDidFinishEnrolment:` will be invoked. On the other hand, if the upload has failed or there is an error during recording, the delegate method `PQCheckManager:didFailWithError:` will be invoked instead.
 *
 *  @param transcript The transcript that the user should read while recording a selfie video
 *  @param reference  The reference to the enrolment.
 *
 *  @see PQCheckManagerDelegate protocol
 */- (void)performEnrolmentWithReference:(NSString *)reference transcript:(NSString *)transcript;
@end

/**
 *  The `PQCheckManagerDelegate` protocol defines optional methods for managing operations after authorisation or enrolment is performed. When you use a `PQCheckManager` object to perform either an authorisation or enrolment operation, the PQCheck manager calls its delegate following the completion of the authorisation or enrolment operation. The PQCheck manager also calls its delegate in the event of errors encountered in recording or uploading of a selfie video.
 */
@protocol PQCheckManagerDelegate <NSObject>
@optional
/**
 *  The delegate method that is invoked after a successful upload of an enrolment video.
 *
 *  @param manager The PQCheck manager object.
 */
- (void)PQCheckManagerDidFinishEnrolment:(PQCheckManager *)manager;


/**
 *  The delegate method that is invoked after a successful upload of an authorisation video.
 *
 *  @discussion Despite a successful upload, the authorisation may not be successful. PQCheck server may reject the authorisation due to incorrect biometric or expired authorisation. Therefore, the `status` of the authorisation has to be inspected.
 *
 *  @param manager The PQCheck manager object.
 *  @param status  The status of the authorisation returned by PQCheck server
 *
 *  @see PQCheckAuthorisationStatus class
 */
- (void)PQCheckManager:(PQCheckManager *)manager didFinishWithAuthorisationStatus:(PQCheckAuthorisationStatus)status;

/**
 *  The delegate method that is invoked in the event of upload failure or error in recording selfie video.
 *
 *  @param manager The PQCheck manager object.
 *  @param error   The NSError object detailing the error.
 */
- (void)PQCheckManager:(PQCheckManager *)manager didFailWithError:(NSError *)error;
@end