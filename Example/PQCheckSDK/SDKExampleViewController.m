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
}
@end

@implementation SDKExampleViewController

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

- (IBAction)authenticateButtonTapped:(id)sender
{
    PQCheckManager *manager = [[PQCheckManager alloc] initWithUserIdentifier:_userIdentifier
                                                           authorisationHash:[self randomStringOfLength:6]
                                                                     summary:[self randomStringOfLength:5]];
    NSURLCredential *adminCredential = [NSURLCredential credentialWithUser:kAdminUUID password:kAdminPassword persistence:NSURLCredentialPersistenceNone];
    [manager setAdminCredential:adminCredential];
    manager.delegate = self;
    manager.autoAttemptOnFailure = NO;
    manager.shouldPaceUser = YES;
    [manager performAuthentication];
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

- (void)PQCheckManager:(PQCheckManager *)controller didFailWithError:(NSError *)error
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

- (void)PQCheckManager:(PQCheckManager *)controller didFinishWithAuthorisationStatus:(PQCheckAuthorisationStatus)status
{
    UIView *view = [[[UIApplication sharedApplication] delegate] window];
    if (status == kPQCheckAuthorisationStatusSuccessful)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Great, job done", @"Great, job done");
        [hud hide:YES afterDelay:1.0f];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (status == kPQCheckAuthorisationStatusTimedOut)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Ooops, timed-out", @"Ooops, timed-out");
        [hud hide:YES afterDelay:1.0f];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (status == kPQCheckAuthorisationStatusCancelled)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Sorry, cancelled", @"Sorry, cancelled");
        [hud hide:YES afterDelay:1.0f];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (status == kPQCheckAuthorisationStatusOpen)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"Please try again", @"Please try again");
        [hud hide:YES afterDelay:1.0f];
    }
}

@end
