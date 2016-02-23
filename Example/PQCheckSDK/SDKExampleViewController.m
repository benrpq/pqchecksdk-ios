//
//  SDKExampleViewController.m
//  PQCheckSDK
//
//  Created by CJ Tjhai on 02/01/2016.
//  Copyright (c) 2016 CJ Tjhai. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <PQCheckSDK/PQCheckManager.h>
#import "SDKExampleViewController.h"
#import "AdminCredentials.h"

static NSString *kUserIdentiferKey = @"UserIdentifier";

@interface SDKExampleViewController () <PQCheckManagerDelegate>
{
    NSString *_userIdentifier;
    PQCheckManager *_manager;
}

@property (nonatomic, weak) IBOutlet UISwitch *offlineModeSwitch;
@end

@implementation SDKExampleViewController

@synthesize offlineModeSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _userIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kUserIdentiferKey];
    if (_userIdentifier == nil)
    {
        _userIdentifier = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:_userIdentifier forKey:kUserIdentiferKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)offlineModeSwitchChanged:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on)
    {
        NSLog(@"Offline mode is enabled");
    }
    else
    {
        NSLog(@"Offline mode is disabled");
    }
}

- (IBAction)authenticateButtonTapped:(id)sender
{
    _manager = [[PQCheckManager alloc] initWithUserIdentifier:_userIdentifier];
    NSURLCredential *adminCredential = [NSURLCredential credentialWithUser:kAdminUUID password:kAdminPassword persistence:NSURLCredentialPersistenceNone];
    [_manager setAdminCredential:adminCredential];
    _manager.delegate = self;
    _manager.autoAttemptOnFailure = NO;
    _manager.shouldPaceUser = YES;
    _manager.offlineModeEnabled = self.offlineModeSwitch.on;
    [_manager performAuthorisationWithHash:[self randomStringOfLength:6] summary:[self randomStringOfLength:5]];
}

- (IBAction)enrolButtonTapped:(id)sender
{
    _manager = [[PQCheckManager alloc] initWithUserIdentifier:_userIdentifier];
    NSURLCredential *adminCredential = [NSURLCredential credentialWithUser:kAdminUUID password:kAdminPassword persistence:NSURLCredentialPersistenceNone];
    [_manager setAdminCredential:adminCredential];
    _manager.delegate = self;
    _manager.shouldPaceUser = YES;
    _manager.offlineModeEnabled = self.offlineModeSwitch.on;
    [_manager performEnrolmentWithReference:@"Enrolment" transcript:@"0123456789"];
}

- (IBAction)resetButtonTapped:(id)sender
{
    _manager = [[PQCheckManager alloc] initWithUserIdentifier:_userIdentifier];
    [_manager resetAPIKey];
    
    // Reset user-identifier
    _userIdentifier = [[NSUUID UUID] UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:_userIdentifier forKey:kUserIdentiferKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private methods

- (NSString *)randomStringOfLength:(NSUInteger)length
{
    NSString *str = @"";
    for (int i=0; i<length; i++)
    {
        int value = arc4random() % 10;
        str = [str stringByAppendingFormat:@"%d", value];
    }
    return str;
}

#pragma mark - PQCheckViewController delegates

- (void)PQCheckManager:(PQCheckManager *)manager didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Do nothing
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)PQCheckManager:(PQCheckManager *)manager didFinishWithAuthorisationStatus:(PQCheckAuthorisationStatus)status
{
    UIView *view = [[[UIApplication sharedApplication] delegate] window];
    if (status == kPQCheckAuthorisationStatusSuccessful)
    {
        NSLog(@"Authorisation - Offline mode: %@, userIdentifier: %@, status: SUCCESS",
              manager.isOfflineModeEnabled ? @"YES" : @"NO", manager.userIdentifier);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Great, job done", @"Great, job done");
        [hud hide:YES afterDelay:1.0f];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (status == kPQCheckAuthorisationStatusTimedOut)
    {
        NSLog(@"Authorisation - Offline mode: %@, userIdentifier: %@, status: TIMED-OUT",
              manager.isOfflineModeEnabled ? @"YES" : @"NO", manager.userIdentifier);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Ooops, timed-out", @"Ooops, timed-out");
        [hud hide:YES afterDelay:1.0f];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (status == kPQCheckAuthorisationStatusCancelled)
    {
        NSLog(@"Authorisation - Offline mode: %@, userIdentifier: %@, status: CANCELLED",
              manager.isOfflineModeEnabled ? @"YES" : @"NO", manager.userIdentifier);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Sorry, cancelled", @"Sorry, cancelled");
        [hud hide:YES afterDelay:1.0f];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (status == kPQCheckAuthorisationStatusOpen)
    {
        NSLog(@"Authorisation - Offline mode: %@, userIdentifier: %@, status: OPEN",
              manager.isOfflineModeEnabled ? @"YES" : @"NO", manager.userIdentifier);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Please try again", @"Please try again");
        [hud hide:YES afterDelay:1.0f];
    }
}

- (void)PQCheckManagerDidFinishEnrolment:(PQCheckManager *)manager
{
    NSLog(@"Enrolment - Offline mode: %@, userIdentifier: %@",
          manager.isOfflineModeEnabled ? @"YES" : @"NO", manager.userIdentifier);
    UIView *view = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = NSLocalizedString(@"Great, job done", @"Great, job done");
    [hud hide:YES afterDelay:1.0f];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
