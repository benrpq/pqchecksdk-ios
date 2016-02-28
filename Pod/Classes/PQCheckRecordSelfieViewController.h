//
//  PQCheckRecordSelfieViewController.h
//  PQCheck Objective-C Sample
//
//  Created by CJ on 19/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol PQCheckRecordSelfieDelegate;

/**
 *  Constants to specify the mode of operation for `PQCheckRecordSelfieViewController` object.
 */
typedef NS_ENUM(NSUInteger, PQCheckSelfieMode)
{
    /**
     *  Selfie mode for authorisation
     */
    kPQCheckSelfieModeAuthorisation,
    /**
     *  Selfie mode for enrolment
     */
    kPQCheckSelfieModeEnrolment
};

/**
 *  `PQCheckRecordSelfieViewController` is a subclass of `UIViewController` that handles the recording of selfie video.
 *
 *  The use can supply a `transcript` of what to read during selfie via the appropriate setter. The recording behaviour of this view controller can be controlled with `pacingEnabled` property.
 */
@interface PQCheckRecordSelfieViewController : UIViewController

/**
 *  The delegate of the view-controller object.
 */
@property (nonatomic, weak) id<PQCheckRecordSelfieDelegate> delegate;

/**
 *  The boolean value that controls the recording behaviour of the view-controller.
 *
 *  @discussion 
 *  1. If `pacingEnabled` is YES, the recording starts automatically after a short delay with the transcript being shown digit-by-digit, and the recording stops after the last digit of the transcript is shown.
 *  2. On the other hand, if `pacingEnabled` is NO, the user performs recording with a press-and-hold action.
 */
@property (nonatomic, assign, getter=isPacingEnabled) BOOL pacingEnabled;

/**
 *  The transcript for the selfie.
 */
@property (nonatomic, copy) NSString *transcript;

/**
 *  The user info dictionary containing view-controller specific information.
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 *  Initialises the view-controller by specifing the `mode` of selfie and `transcript`.
 *
 *  @param mode       The mode of selfie
 *  @param transcript The transcript
 *
 *  @return Return `PQCheckRecordSelfieViewController` object
 */
- (id)initWithPQCheckSelfieMode:(PQCheckSelfieMode)mode
                     transcript:(NSString *)transcript;

/**
 *  Attempts a selfie recording and on completion, one of the delegates of `PQCheckRecordSelfieDelegate` protocol will be invoked.
 *
 *  @see PQCheckRecordSelfieDelegate protocol
 */
- (void)attemptSelfie;

/**
 *  Returns the currently selected selfie mode.
 *
 *  @return Return the current selfie mode.
 */
- (PQCheckSelfieMode)currentSelfieMode;

@end

/**
 *  The `PQCheckRecordSelfieDelegate` protocol defines two mandatory methods for managing operations after a selfie attempt. The first delegate method handles a successful selfie attempt, and the other method handles the opposite case.
 */
@protocol PQCheckRecordSelfieDelegate <NSObject>

/**
 *  The delegate method that is invoked after a successful selfie attempt.
 *
 *  @param controller An instance of `PQCheckRecordSelfieViewController` object.
 *  @param mediaURL   The file URL at which the recorded selfie video is located.
 */
- (void)selfieViewController:(PQCheckRecordSelfieViewController *)controller didFinishWithMediaURL:(NSURL *)mediaURL;

/**
 *  The delegate method that is invoked in the event of error while attempting a selfie.
 *
 *  @param controller An instance of `PQCheckRecordSelfieViewController` object.
 *  @param error      The NSError object detailing the error.
 */
- (void)selfieViewController:(PQCheckRecordSelfieViewController *)controller didFailWithError:(NSError *)error;
@end