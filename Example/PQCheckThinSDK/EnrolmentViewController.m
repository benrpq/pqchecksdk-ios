//
//  EnrolmentViewController.m
//  PQCheckSDK
//
//  Created by CJ on 24/02/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <PQCheckSDK/PQCheckManager.h>
#import <PQCheckSDK/UIImage+Additions.h>
#import <PQCheckSDK/UIColor+Additions.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "EnrolmentViewController.h"
#import "BankClientManager.h"
#import "Enrolment.h"
#import "UserManager.h"

@interface EnrolmentViewController () <PQCheckManagerDelegate>
{
    PQCheckManager *_manager;
}
@property (nonatomic, weak) IBOutlet UILabel *enrolmentLabel;
@property (nonatomic, weak) IBOutlet UIButton *enrolButton;
@end

@implementation EnrolmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIColor *PQGreen = [UIColor colorWithRed:13.0f/255.0f green:185.0f/255.0f blue:78.0f/255.0f alpha:1.0f];
    [self.enrolButton setTitleColor:PQGreen forState:UIControlStateNormal];
    [self.enrolButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]
                                forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enrolButtonTapped:(id)sender
{
    NSAssert(self.userIdentifier != nil && self.userIdentifier.length > 0,
             @"userIdentifier cannot be nil or have empty length");
    
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Please Wait...", @"Please Wait...");
    
    [[BankClientManager defaultManager] enrolUserWithUUID:self.userIdentifier completion:^(Enrolment *enrolment, NSError *error) {
        
        [hud hide:YES];
        
        if (error == nil)
        {
            // Let PQCheckManager completes the enrolment process
            _manager = [[PQCheckManager alloc] init];
            _manager.delegate = self;
            [_manager performEnrolmentWithTranscript:enrolment.transcript uploadURI:[NSURL URLWithString:enrolment.uri]];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // Do nothing
            }];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

#pragma mark - PQCheckManager delegates

- (void)PQCheckManagerDidFinishEnrolment:(PQCheckManager *)manager
{
    [[UserManager defaultManager] addEnroledUser:self.userIdentifier];
    [[UserManager defaultManager] setCurrentUserIdentifer:self.userIdentifier];
    
    // Enrol is successful, this view controller can now be dismissed
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

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

@end
