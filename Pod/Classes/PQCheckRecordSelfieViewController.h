//
//  PQCheckRecordSelfieViewController.h
//  PQCheck Objective-C Sample
//
//  Created by CJ on 19/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Authorisation.h"

@protocol PQCheckRecordSelfieDelegate;

@interface PQCheckRecordSelfieViewController : UIViewController <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, assign, getter=isPacingEnabled) BOOL pacingEnabled;
@property (nonatomic, weak) id<PQCheckRecordSelfieDelegate> delegate;
@property (nonatomic, strong) Authorisation *authorisation;

- (void)updateDigest:(NSString *)digest;
- (void)attemptSelfie;

@end


@protocol PQCheckRecordSelfieDelegate <NSObject>
- (void)selfieViewController:(PQCheckRecordSelfieViewController *)controller didFinishWithMediaURL:(NSURL *)mediaURL;
- (void)selfieViewController:(PQCheckRecordSelfieViewController *)controller didFailWithError:(NSError *)error;
@end