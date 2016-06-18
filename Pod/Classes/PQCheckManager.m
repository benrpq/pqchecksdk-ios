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

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SimpleKeychain/SimpleKeychain.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "PQCheckManager.h"
#import "API/APIManager.h"
#import "API/Response/UploadAttempt.h"
#import "NSString+Utils.h"

static NSString* kPQCheckAPIKey = @"PQCheckAPIKey";
static NSString* kPQCheckUserInfoEnrolmentReference = @"reference";
static NSString* kPQCheckUserInfoEnrolmentTranscript = @"transcript";
static NSString* kPQCheckUserInfoEnrolmentURI = @"uri";
static const CGFloat kDefaultOfflineDelayInterval = 3.0f;

@interface PQCheckManager () <PQCheckRecordSelfieDelegate>
{
    NSString *_userIdentifier;
    Authorisation *_authorisation;
    AVAuthorizationStatus _cameraAuthorisationStatus;
    AVAuthorizationStatus _microphoneAuthorisationStatus;
}
@end

@implementation PQCheckManager

+ (PQCheckManager *)defaultManager
{
    static PQCheckManager *_defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[PQCheckManager alloc] init];
    });
    return _defaultManager;
}

- (id)init
{
    NSLog(@"********** %s", __PRETTY_FUNCTION__);
    self = [super init];
    if (self)
    {
        _authorisation = nil;
        _offlineAuthorisationStatus = kPQCheckAuthorisationStatusSuccessful;
        
        [self checkCameraAndMicrophonePermissions];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"********** %s", __PRETTY_FUNCTION__);
}

- (void)performAuthorisation:(Authorisation *)authorisation
{
    NSAssert([NSThread isMainThread], @"The method %s must be called from main thread", __PRETTY_FUNCTION__);
    
    // Do any additional setup after loading the view from its nib.
    assert(authorisation != nil);
    
    _authorisation = authorisation;
    
    // Make sure that we have a camera and microphone permission
    _cameraAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    _microphoneAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ((_cameraAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _cameraAuthorisationStatus == AVAuthorizationStatusNotDetermined) &&
        (_microphoneAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _microphoneAuthorisationStatus == AVAuthorizationStatusNotDetermined))
    {
        self.selfieViewController = [[PQCheckRecordSelfieViewController alloc] initWithPQCheckSelfieMode:kPQCheckSelfieModeAuthorisation
                                                                                      transcript:_authorisation.digest];
        self.selfieViewController.delegate = self;
        self.selfieViewController.pacingEnabled = self.shouldPaceUser;
        
        UIViewController *viewController = [PQCheckManager topMostController];
        [viewController presentViewController:self.selfieViewController animated:YES completion:nil];
    }
}

- (void)performEnrolmentWithTranscript:(NSString *)transcript uploadURI:(NSURL *)uri
{
    NSAssert([NSThread isMainThread], @"The method %s must be called from main thread", __PRETTY_FUNCTION__);
    
    assert([NSString isStringNilEmptyOrNewLine:transcript] == NO);
    
    // Make sure that we have a camera and microphone permission
    _cameraAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    _microphoneAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ((_cameraAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _cameraAuthorisationStatus == AVAuthorizationStatusNotDetermined) &&
        (_microphoneAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _microphoneAuthorisationStatus == AVAuthorizationStatusNotDetermined))
    {
        self.selfieViewController = [[PQCheckRecordSelfieViewController alloc] initWithPQCheckSelfieMode:kPQCheckSelfieModeEnrolment
                                                                                      transcript:transcript];
        self.selfieViewController.delegate = self;
        self.selfieViewController.pacingEnabled = self.shouldPaceUser;
        self.selfieViewController.userInfo = @{kPQCheckUserInfoEnrolmentTranscript: transcript,
                                       kPQCheckUserInfoEnrolmentURI: [uri absoluteString]};
        
        UIViewController *viewController = [PQCheckManager topMostController];
        [viewController presentViewController:self.selfieViewController animated:YES completion:nil];
    }
}

#pragma mark - PQCheckRecordSelfie delegates

- (void)selfieViewController:(PQCheckRecordSelfieViewController *)controller didFinishWithMediaURL:(NSURL *)mediaURL
{
    if ([controller currentSelfieMode] == kPQCheckSelfieModeAuthorisation)
    {
        [self selfieController:controller performsAuthorisationWithMediaAtURL:mediaURL];
    }
    else if ([controller currentSelfieMode] == kPQCheckSelfieModeEnrolment)
    {
        [self selfieController:controller performsEnrolmentWithMediaAtURL:mediaURL];
    }
}

- (void)selfieViewController:(PQCheckRecordSelfieViewController *)controller didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(PQCheckManager:didFailWithError:)])
    {
        [self.delegate PQCheckManager:self didFailWithError:error];
    }
    self.selfieViewController.delegate = nil;
    self.selfieViewController = nil;
}

#pragma mark - Private methods

+ (UIViewController*)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void)checkCameraAndMicrophonePermissions
{
    NSString *title = nil;
    NSString *message = nil;
    if (_cameraAuthorisationStatus == AVAuthorizationStatusDenied ||
        _cameraAuthorisationStatus == AVAuthorizationStatusRestricted)
    {
        title = NSLocalizedString(@"Camera Permission", @"Camera Permission");
        message = NSLocalizedString(@"The app requires your camera permission, please enable it from Settings", @"The app requires your camera permission, please enable it from Settings");
    }
    if (_microphoneAuthorisationStatus == AVAuthorizationStatusDenied ||
        _microphoneAuthorisationStatus == AVAuthorizationStatusRestricted)
    {
        if ([title length] > 0 && [message length] > 0)
        {
            title = NSLocalizedString(@"Camera and Microphone Permissions", @"Camera and Microphone Permissions");
            message = NSLocalizedString(@"The app requires your camera and microphone permissions, please enable them from Settings", @"The app requires your camera and microphone permissions, please enable them from Settings");
        }
        else
        {
            title = NSLocalizedString(@"Microphone Permission", @"Microphone Permission");
            message = NSLocalizedString(@"The app requires your microphone permission, please enable it from Settings", @"The app requires your microphone permission, please enable it from Settings");
        }
    }
    
    if ([title length] > 0 && [message length] > 0)
    {
        __weak typeof(PQCheckManager) *weakSelf = self;
        UIViewController *viewController = [PQCheckManager topMostController];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[viewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
                weakSelf.selfieViewController.delegate = nil;
                weakSelf.selfieViewController = nil;
            }];
        }];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[viewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
                weakSelf.selfieViewController.delegate = nil;
                weakSelf.selfieViewController = nil;
            }];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        
        [viewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)selfieController:(PQCheckRecordSelfieViewController *)controller performsAuthorisationWithMediaAtURL:(NSURL *)mediaURL
{
    UIView *view = [[[UIApplication sharedApplication] delegate] window];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Validating...", @"Validating...");
    
#ifdef DEBUG
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *docURL = [self applicationDocumentsDirectory];
        NSURL *authURL = [docURL URLByAppendingPathComponent:@"authorisation" isDirectory:YES];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[authURL path]] == NO)
        {
            [[NSFileManager defaultManager] createDirectoryAtURL:authURL withIntermediateDirectories:YES attributes:nil error:nil];
        }
        authURL = [[authURL URLByAppendingPathComponent:_authorisation.uuid] URLByAppendingPathExtension:@"mp4"];
        [[NSFileManager defaultManager] copyItemAtURL:mediaURL toURL:authURL error:nil];
    });
#endif

    if (self.offlineMode == NO)
    {
        __unsafe_unretained PQCheckManager *weakSelf = self;
        APIManager *apiManager = [[APIManager alloc] init];
        __weak typeof(Authorisation) *weakAuth = _authorisation;
        
        [apiManager uploadAttemptWithAuthorisation:weakAuth mediaURL:mediaURL completion:^(UploadAttempt *uploadAttempt, NSError *error) {
            
            [hud hide:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[NSFileManager defaultManager] removeItemAtURL:mediaURL error:nil];
            });

            if (error != nil)
            {
                weakSelf.selfieViewController.delegate = nil;
                weakSelf.selfieViewController = nil;
                if ([weakSelf.delegate respondsToSelector:@selector(PQCheckManager:didFailWithError:)])
                {
                    [weakSelf.delegate PQCheckManager:weakSelf didFailWithError:error];
                }
                
                return;
            }
            
            if (uploadAttempt.authorisationStatus == kPQCheckAuthorisationStatusOpen)
            {
                [weakAuth setDigest:uploadAttempt.nextDigest];
                [weakSelf.selfieViewController setTranscript:uploadAttempt.nextDigest];
                if (weakSelf.autoAttemptOnFailure)
                {
                    [weakSelf.selfieViewController reattemptSelfie];
                }
                else
                {
                    UIViewController *viewController = [PQCheckManager topMostController];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attempt Failed", @"Attempt Failed") message:NSLocalizedString(@"Your attempt was not successful, would you like to try again?", @"Your attempt was not successful, would you like to try again?") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, thanks", @"No, thanks") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [viewController dismissViewControllerAnimated:YES completion:^{
                            weakSelf.selfieViewController.delegate = nil;
                            weakSelf.selfieViewController = nil;
                            if ([weakSelf.delegate respondsToSelector:@selector(PQCheckManager:didFinishWithAuthorisationStatus:)])
                            {
                                [weakSelf.delegate PQCheckManager:weakSelf didFinishWithAuthorisationStatus:uploadAttempt.authorisationStatus];
                            }
                        }];
                    }];
                    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes, please", @"Yes, please") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.selfieViewController reattemptSelfie];
                    }];
                    [alertController addAction:noAction];
                    [alertController addAction:yesAction];
                    
                    [viewController presentViewController:alertController animated:YES completion:nil];
                }
            }
            else
            {
                weakSelf.selfieViewController.delegate = nil;
                weakSelf.selfieViewController = nil;
                if ([weakSelf.delegate respondsToSelector:@selector(PQCheckManager:didFinishWithAuthorisationStatus:)])
                {
                    [weakSelf.delegate PQCheckManager:weakSelf didFinishWithAuthorisationStatus:uploadAttempt.authorisationStatus];
                }
            }
        }];
    }
    else
    {
        self.selfieViewController.delegate = nil;
        self.selfieViewController = nil;

        __weak typeof(PQCheckManager) *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultOfflineDelayInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[NSFileManager defaultManager] removeItemAtURL:mediaURL error:nil];
            });
            
            if ([weakSelf.delegate respondsToSelector:@selector(PQCheckManager:didFinishWithAuthorisationStatus:)])
            {
                [weakSelf.delegate PQCheckManager:weakSelf didFinishWithAuthorisationStatus:weakSelf.offlineAuthorisationStatus];
            }
            
        });
    }
}

- (void)selfieController:(PQCheckRecordSelfieViewController *)controller performsEnrolmentWithMediaAtURL:(NSURL *)mediaURL
{
    UIView *view = [[[UIApplication sharedApplication] delegate] window];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Enrolling...", @"Enrolling...");
    
    NSString *transcript = [self.selfieViewController.userInfo objectForKey:kPQCheckUserInfoEnrolmentTranscript];
    NSAssert([NSString isStringNilEmptyOrNewLine:transcript] == NO, @"Enrolment transcript cannot be nil or have zero length");
    
    NSString *uriString = [self.selfieViewController.userInfo objectForKey:kPQCheckUserInfoEnrolmentURI];
    NSAssert([NSString isStringNilEmptyOrNewLine:uriString] == NO, @"Enrolment URI cannot be nil or have zero length");
    
#ifdef DEBUG
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *docURL = [self applicationDocumentsDirectory];
        NSURL *authURL = [docURL URLByAppendingPathComponent:@"enrolment" isDirectory:YES];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[authURL path]] == NO)
        {
            [[NSFileManager defaultManager] createDirectoryAtURL:authURL withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *uuid = [[[controller userInfo] objectForKey:kPQCheckUserInfoEnrolmentURI] lastPathComponent];
        authURL = [[authURL URLByAppendingPathComponent:uuid] URLByAppendingPathExtension:@"mp4"];
        [[NSFileManager defaultManager] copyItemAtURL:mediaURL toURL:authURL error:nil];
    });
#endif

    self.selfieViewController.delegate = nil;
    self.selfieViewController = nil;

    if (self.offlineMode == NO)
    {
        NSURL *uploadURL = [NSURL URLWithString:uriString];
        [[APIManager sharedManager] enrolUserWithMediaURL:mediaURL uploadURL:uploadURL completion:^(NSError *error) {
            
            typeof(PQCheckManager) *strongSelf = self;
    
            [hud hide:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[NSFileManager defaultManager] removeItemAtURL:mediaURL error:nil];
            });
            
            if (error != nil)
            {
                if ([strongSelf.delegate respondsToSelector:@selector(PQCheckManager:didFailWithError:)])
                {
                    [strongSelf.delegate PQCheckManager:strongSelf didFailWithError:error];
                }
                
                return;
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(PQCheckManagerDidFinishEnrolment:)])
            {
                [strongSelf.delegate PQCheckManagerDidFinishEnrolment:strongSelf];
            }
            
        }];
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDefaultOfflineDelayInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            typeof(PQCheckManager) *strongSelf = self;
            [hud hide:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[NSFileManager defaultManager] removeItemAtURL:mediaURL error:nil];
            });
            
            if ([strongSelf.delegate respondsToSelector:@selector(PQCheckManagerDidFinishEnrolment:)])
            {
                [strongSelf.delegate PQCheckManagerDidFinishEnrolment:strongSelf];
            }
            
        });
    }
}


#ifdef DEBUG
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#endif

@end
