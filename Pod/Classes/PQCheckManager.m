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
#import "AdminCredentials.h"
#import "API/APIManager.h"

static NSString* kPQCheckAPIKey = @"PQCheckAPIKey";

@interface PQCheckManager () <PQCheckRecordSelfieDelegate>
{
    NSString *_userIdentifier;
    NSString *_summary;
    NSString *_digest;
    APIKey *_apiKey;
    Authorisation *_authorisation;
    PQCheckRecordSelfieViewController *_selfieController;
    BOOL _shouldViewAuthorisationOnFailure;
    AVAuthorizationStatus _cameraAuthorisationStatus;
    AVAuthorizationStatus _microphoneAuthorisationStatus;
}
@end

@implementation PQCheckManager

- (id)initWithUserIdentifier:(NSString *)userIdentifier
                      digest:(NSString *)digest
                     summary:(NSString *)summary
{
    self = [super init];
    if (self)
    {
        _userIdentifier = userIdentifier;
        _digest = digest;
        _summary = summary;
        _shouldViewAuthorisationOnFailure = YES;
        
        [self checkCameraAndMicrophonePermissions];
    }
    return self;
}

- (void)performAuthentication
{
    // Do any additional setup after loading the view from its nib.
    assert(_userIdentifier != nil && _userIdentifier.length > 0);
    assert(_summary != nil        && _summary.length > 0);
    assert(_digest != nil         && _digest.length > 0);
    
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
        [self prepareCredentialCompletion:^{
            
            // Create an authorisation
            NSURLCredential *credential = [NSURLCredential credentialWithUser:_apiKey.uuid
                                                                     password:_apiKey.secret
                                                                  persistence:NSURLCredentialPersistenceNone];
            [[APIManager sharedManager] createAuthorisationWithCredential:credential userIdentifier:_userIdentifier digest:_digest summary:_summary completion:^(Authorisation *authorisation, NSError *error) {
                
                [hud hide:YES];

                if (error == nil)
                {
                    _authorisation = authorisation;

                    _selfieController = [[PQCheckRecordSelfieViewController alloc] init];
                    _selfieController.delegate = self;
                    _selfieController.authorisation = _authorisation;
                    _selfieController.pacingEnabled = self.shouldPaceUser;
                    
                    UIViewController *viewController = [PQCheckManager topMostController];
                    [viewController presentViewController:_selfieController animated:YES completion:nil];
                }
                
            }];
        }];
    }

}

#pragma mark - PQCheckRecordSelfie delegates

- (void)selfieViewController:(PQCheckRecordSelfieViewController *)controller didFinishWithMediaURL:(NSURL *)mediaURL
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
        
        PQCheckAuthorisationStatus status = [AuthorisationStatus authorisationStatusValueOfString:uploadAttempt.status];
        if (status == kPQCheckAuthorisationStatusOpen)
        {
            if (_shouldViewAuthorisationOnFailure)
            {
                [self viewAuthorisationOnFailure];
            }
            
            [controller updateDigest:uploadAttempt.nextDigest];
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
        
        if ([self.delegate respondsToSelector:@selector(PQCheckManager:didFinishWithAuthorisationStatus:)])
        {
            [self.delegate PQCheckManager:self didFinishWithAuthorisationStatus:status];
        }
    }];
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

- (void)prepareCredentialCompletion:(void (^)(void))completionBlock
{
    A0SimpleKeychain *keychain = [A0SimpleKeychain keychain];
    NSData *apiData = [keychain dataForKey:kPQCheckAPIKey
                             promptMessage:NSLocalizedString(@"Please authenticate", @"Please authenticate")];
    if (apiData == nil)
    {
        // Create API-key using admin credential
        UIView *view = [[[UIApplication sharedApplication] delegate] window];
        [MBProgressHUD showHUDAddedTo:view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLCredential *adminCredential = [NSURLCredential credentialWithUser:kAdminUUID
                                                                          password:kAdminPassword
                                                                       persistence:NSURLCredentialPersistenceNone];
            NSString *namespace = [[NSUUID UUID] UUIDString];
            [[APIManager sharedManager] createAPIKeyWithCredential:adminCredential namespace:namespace completion:^(APIKey *apiKey, NSError *error) {
                // Save credential to keychain
                _apiKey = apiKey;
                //keychain.useAccessControl = YES;
                //keychain.defaultAccessiblity = A0SimpleKeychainItemAccessibleWhenPasscodeSetThisDeviceOnly;
                [keychain setData:[_apiKey data] forKey:kPQCheckAPIKey];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:view animated:YES];
                    
                    completionBlock();
                });
            }];
        });
    }
    else
    {
        _apiKey = [[APIKey alloc] initWithData:apiData];
        completionBlock();
    }
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

- (void)viewAuthorisationOnFailure
{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:_apiKey.uuid
                                                             password:_apiKey.secret
                                                          persistence:NSURLCredentialPersistenceNone];
    [[APIManager sharedManager] viewAuthorisationRequestWithCredential:credential UUID:_authorisation.uuid completion:^(Authorisation *authorisation, NSError *error) {
        // Need a way to do a pretty-print of Authorisation object
        for (NSInteger index=0; index<authorisation.attempts.count; index++)
        {
            NSLog(@"Authorisation failure (%ld): %@", (long)index, [authorisation.attempts objectAtIndex:index]);
        }
    }];
}

@end
