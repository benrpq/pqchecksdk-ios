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

#import <PQCheckSDK/PQCheckManager.h>
#import <PQCheckSDK/UIImage+Additions.h>
#import <PQCheckSDK/UIColor+Additions.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "EnrolmentViewController.h"
#import "BankClientManager.h"
#import "Enrolment.h"
#import "User.h"
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
    UIColor *PQGreen = [UIColor colorWithRed:13.0f/255.0f
                                       green:185.0f/255.0f
                                        blue:78.0f/255.0f
                                       alpha:1.0f];
    [self.enrolButton setTitleColor:PQGreen forState:UIControlStateNormal];
    [self.enrolButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]
                                forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"********** %s", __PRETTY_FUNCTION__);
}

- (IBAction)enrolButtonTapped:(id)sender
{
    NSAssert(self.user.identifier != nil && self.user.identifier.length > 0,
             @"userIdentifier cannot be nil or have empty length");
    
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Please Wait...", @"Please Wait...");
    
    __weak __typeof__(EnrolmentViewController) *weakSelf = self;
    [[BankClientManager defaultManager] enrolUserWithUUID:self.user.identifier completion:^(Enrolment *enrolment, NSError *error) {
        
        __typeof__(EnrolmentViewController) *strongSelf = weakSelf;
        [hud hide:YES];
        
        if (error == nil)
        {
            // Let PQCheckManager completes the enrolment process
            _manager = [[PQCheckManager alloc] init];
            _manager.delegate = strongSelf;
            [_manager performEnrolmentWithTranscript:enrolment.transcript uploadURI:[NSURL URLWithString:enrolment.uri]];
            //
            // NOTE: Customisation can only be called after a call to enrolment is done
            //
            [_manager.selfieViewController enableSolidOverlayWithColor:[UIColor whiteColor] opacity:0.75f];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // Do nothing
            }];
            [alertController addAction:okAction];
            
            [strongSelf presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

#pragma mark - PQCheckManager delegates

- (void)PQCheckManagerDidFinishEnrolment:(PQCheckManager *)manager
{
    [[UserManager defaultManager] addEnrolledUser:self.user];
    [[UserManager defaultManager] setActiveUser:self.user];
    
    // Enrol is successful, this view controller can now be dismissed
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
        _manager.delegate = nil;
        _manager = nil;
    }];
}

- (void)PQCheckManager:(PQCheckManager *)manager didFailWithError:(NSError *)error
{
    __weak __typeof__(EnrolmentViewController) *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        
        __typeof__(EnrolmentViewController) *strongSelf = weakSelf;

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Do nothing
        }];
        [alertController addAction:okAction];
        
        [strongSelf presentViewController:alertController animated:YES completion:^{
            _manager.delegate = nil;
            _manager = nil;
        }];
    }];
}

@end
