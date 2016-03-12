//
//  PQCheckManager.m
//  Pods
//
//  Created by CJ Tjhai on 01/02/2016.
//
//

#import <SimpleKeychain/SimpleKeychain.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "PQCheckManager.h"
#import "PQCheckRecordSelfieViewController.h"
#ifdef THINKSDK
#import "API/Response/Authorisation.h"
#endif
#import "API/APIManager.h"

static NSString* kPQCheckAPIKey = @"PQCheckAPIKey";
#ifndef THINSDK
static NSString* kPQCheckUserInfoEnrolmentReference = @"reference";
static NSString* kPQCheckUserInfoEnrolmentTranscript = @"transcript";
#endif

@interface PQCheckManager () <PQCheckRecordSelfieDelegate>
{
    NSString *_userIdentifier;
#ifndef THINSDK
    APIKey *_apiKey;
    BOOL _shouldViewAuthorisation;
#endif
    Authorisation *_authorisation;
    PQCheckRecordSelfieViewController *_selfieController;
    AVAuthorizationStatus _cameraAuthorisationStatus;
    AVAuthorizationStatus _microphoneAuthorisationStatus;
}
@end

@implementation PQCheckManager

#ifndef THINSDK
- (id)initWithUserIdentifier:(NSString *)userIdentifier
{
    self = [super init];
    if (self)
    {
        _userIdentifier = userIdentifier;
        _shouldViewAuthorisation = YES;
        
        [self checkCameraAndMicrophonePermissions];
    }
    return self;
}

- (NSString *)currentNamespace
{
    if (_apiKey == nil)
    {
        return nil;
    }
    
    return _apiKey.apiNamespace;
}

#else
- (id)initWithAuthorisation:(Authorisation *)authorisation
{
    self = [super init];
    if (self)
    {
        _authorisation = authorisation;
        
        [self checkCameraAndMicrophonePermissions];
    }
    return self;
}
#endif

- (void)performAuthorisationWithHash:(NSString *)authorisationHash summary:(NSString *)summary
{
    NSAssert([NSThread isMainThread], @"The method %s must be called from main thread", __PRETTY_FUNCTION__);
    
    NSString *theAuthorisationHash = authorisationHash;
    NSString *theSummary = summary;
    
    // Do any additional setup after loading the view from its nib.
#ifndef THINSDK
    assert(_userIdentifier != nil    && _userIdentifier.length > 0);
    assert(theSummary != nil           && theSummary.length > 0);
    assert(theAuthorisationHash != nil && theAuthorisationHash.length > 0);
#endif
    
    // Make sure that we have a camera and microphone permission
    _cameraAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    _microphoneAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ((_cameraAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _cameraAuthorisationStatus == AVAuthorizationStatusNotDetermined) &&
        (_microphoneAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _microphoneAuthorisationStatus == AVAuthorizationStatusNotDetermined))
    {
#ifndef THINSDK
        UIView *view = [[[UIApplication sharedApplication] delegate] window];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = NSLocalizedString(@"Please wait...", @"Please wait...");
        
        // Do I have a correct credential?
        [self prepareManagerWithCredentialWithCompletion:^{
            
            // Create an authorisation
            [[APIManager sharedManager] createAuthorisationWithAPIKey:_apiKey userIdentifier:_userIdentifier authorisationHash:theAuthorisationHash summary:theSummary completion:^(Authorisation *authorisation, NSError *error) {
                
                [hud hide:YES];
                
                if (error == nil)
                {
                    _authorisation = authorisation;
                    
                    _selfieController = [[PQCheckRecordSelfieViewController alloc] initWithPQCheckSelfieMode:kPQCheckSelfieModeAuthorisation
                                                                                                  transcript:_authorisation.digest];
                    _selfieController.delegate = self;
                    _selfieController.pacingEnabled = self.shouldPaceUser;
                    
                    UIViewController *viewController = [PQCheckManager topMostController];
                    [viewController presentViewController:_selfieController animated:YES completion:nil];
                }
                
            }];
        }];
#else
        _selfieController = [[PQCheckRecordSelfieViewController alloc] init];
        _selfieController.delegate = self;
        _selfieController.authorisation = _authorisation;
        _selfieController.pacingEnabled = self.shouldPaceUser;
        
        UIViewController *viewController = [PQCheckManager topMostController];
        [viewController presentViewController:_selfieController animated:YES completion:nil];
#endif
    }
}

- (void)performEnrolmentWithReference:(NSString *)reference transcript:(NSString *)transcript
{
    NSAssert([NSThread isMainThread], @"The method %s must be called from main thread", __PRETTY_FUNCTION__);
    
    NSString *theReference = reference;
    NSString *theTranscript = transcript;
    
    assert(_userIdentifier != nil && _userIdentifier.length > 0);
    assert(theReference != nil    && theReference.length > 0);
    assert(theTranscript != nil   && theTranscript.length > 0);

    // Make sure that we have a camera and microphone permission
    _cameraAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    _microphoneAuthorisationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ((_cameraAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _cameraAuthorisationStatus == AVAuthorizationStatusNotDetermined) &&
        (_microphoneAuthorisationStatus == AVAuthorizationStatusAuthorized ||
         _microphoneAuthorisationStatus == AVAuthorizationStatusNotDetermined))
    {
        UIView *view = [[[UIApplication sharedApplication] delegate] window];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = NSLocalizedString(@"Please wait...", @"Please wait...");
        
        // Do I have a correct credential?
        [self prepareManagerWithCredentialWithCompletion:^{

            [hud hide:YES];
            
            _selfieController = [[PQCheckRecordSelfieViewController alloc] initWithPQCheckSelfieMode:kPQCheckSelfieModeEnrolment
                                                                                          transcript:theTranscript];
            _selfieController.delegate = self;
            _selfieController.pacingEnabled = self.shouldPaceUser;
            _selfieController.userInfo = @{kPQCheckUserInfoEnrolmentReference: reference,
                                           kPQCheckUserInfoEnrolmentTranscript: transcript};
            
            UIViewController *viewController = [PQCheckManager topMostController];
            [viewController presentViewController:_selfieController animated:YES completion:nil];
        }];
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

#ifndef THINSDK
- (void)prepareManagerWithCredentialWithCompletion:(void (^)(void))completionBlock
{
    A0SimpleKeychain *keychain = [A0SimpleKeychain keychain];
    NSData *apiData = [keychain dataForKey:kPQCheckAPIKey
                             promptMessage:NSLocalizedString(@"Please authenticate", @"Please authenticate")];
    if (apiData == nil)
    {
        /*******
         ******* Please set your API key here
         *******/
        _apiKey = [[APIKey alloc] init];
        _apiKey.uuid = @"********** REMOVED **************";
        _apiKey.apiNamespace = @"********** REMOVED **************";
        _apiKey.secret = @"********** REMOVED **************";
        completionBlock();
    }
    else
    {
        _apiKey = [[APIKey alloc] initWithData:apiData];
        completionBlock();
    }
}

- (void)viewAuthorisation
{
    [[APIManager sharedManager] viewAuthorisationRequestWithAPIKey:_apiKey UUID:_authorisation.uuid completion:^(Authorisation *authorisation, NSError *error) {
        // Need a way to do a pretty-print of Authorisation object
        for (NSInteger index=0; index<authorisation.attempts.count; index++)
        {
            NSLog(@"Authorisation result (%ld): %@", (long)index, [authorisation.attempts objectAtIndex:index]);
        }
    }];
}

#endif

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
        UIViewController *viewController = [PQCheckManager topMostController];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[viewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[viewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
    
    [[APIManager sharedManager] uploadAttemptWithAuthorisation:_authorisation mediaURL:mediaURL completion:^(UploadAttempt *uploadAttempt, NSError *error) {
        
        [hud hide:YES];
        
        if (error != nil)
        {
            if ([self.delegate respondsToSelector:@selector(PQCheckManager:didFailWithError:)])
            {
                [self.delegate PQCheckManager:self didFailWithError:error];
            }
            
            return;
        }
        
        if (uploadAttempt.authorisationStatus == kPQCheckAuthorisationStatusOpen)
        {
            [_authorisation setDigest:uploadAttempt.nextDigest];
            [controller setTranscript:uploadAttempt.nextDigest];
            if (self.autoAttemptOnFailure)
            {
                [controller attemptSelfie];
            }
            else
            {
                UIViewController *viewController = [PQCheckManager topMostController];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attempt Failed", @"Attempt Failed") message:NSLocalizedString(@"Your attempt was not successful, would you like to try again?", @"Your attempt was not successful, would you like to try again?") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, thanks", @"No, thanks") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [[viewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                }];
                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes, please", @"Yes, please") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [controller attemptSelfie];
                }];
                [alertController addAction:noAction];
                [alertController addAction:yesAction];
                
                [viewController presentViewController:alertController animated:YES completion:nil];
            }
        }

#ifndef THINSDK
        if (_shouldViewAuthorisation)
        {
            [self viewAuthorisation];
        }
#endif
        
        if ([self.delegate respondsToSelector:@selector(PQCheckManager:didFinishWithAuthorisationStatus:)])
        {
            [self.delegate PQCheckManager:self didFinishWithAuthorisationStatus:uploadAttempt.authorisationStatus];
        }
    }];
}

- (void)selfieController:(PQCheckRecordSelfieViewController *)controller performsEnrolmentWithMediaAtURL:(NSURL *)mediaURL
{
    
    UIView *view = [[[UIApplication sharedApplication] delegate] window];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Enroling...", @"Enroling...");
    
    NSString *reference = [_selfieController.userInfo objectForKey:kPQCheckUserInfoEnrolmentReference];
    NSString *transcript = [_selfieController.userInfo objectForKey:kPQCheckUserInfoEnrolmentTranscript];
    NSAssert(reference != nil && reference.length > 0, @"Enrolment reference cannot be nil or have zero length");
    NSAssert(transcript != nil && transcript.length > 0, @"Enrolment transcript cannot be nil or have zero length");
    
    [[APIManager sharedManager] enrolUserWithAPIKey:_apiKey userIdentifier:_userIdentifier reference:reference transcript:transcript mediaURL:mediaURL completion:^(NSError *error) {
        
        [hud hide:YES];
        
        if (error != nil)
        {
            if ([self.delegate respondsToSelector:@selector(PQCheckManager:didFailWithError:)])
            {
                [self.delegate PQCheckManager:self didFailWithError:error];
            }
            
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(PQCheckManagerDidFinishEnrolment:)])
        {
            [self.delegate PQCheckManagerDidFinishEnrolment:self];
        }
        
    }];
}

@end
