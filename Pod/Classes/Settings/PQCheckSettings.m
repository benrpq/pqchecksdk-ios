//
//  PQCheckSettings.m
//  Pods
//
//  Created by CJ Tjhai on 08/04/2016.
//
//

#import "PQCheckSettings.h"

static NSString *kPQCheckSDKFaceLockThreshold = @"PQCheckSDKFaceLockThreshold";
static NSString *kPQCheckSDKFaceLockAngleTolerance = @"PQCheckSDKFaceLockAngleTolerance";
static NSString *kPQCheckBannerBackgroundColour = @"PQCheckBannerBackgroundColour";
static NSString *kPQCheckShouldShowInstructions = @"PQCheckShouldShowInstructions";

@implementation PQCheckSettings

+ (void)registerDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = @{kPQCheckSDKFaceLockThreshold: @(64),
                                  kPQCheckSDKFaceLockAngleTolerance: @(15),
                                  kPQCheckBannerBackgroundColour: @"#0db94e",
                                  kPQCheckShouldShowInstructions: @(NO)
                                  };
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
}

#pragma mark - PQCheck SDK settings

+ (NSUInteger)PQCheckFaceLockThreshold
{
    return (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:kPQCheckSDKFaceLockThreshold];
}

+ (NSUInteger)PQCheckFaceLockAngleTolerance
{
    return (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:kPQCheckSDKFaceLockAngleTolerance];
}

+ (NSString *)PQCheckBannerBackgroundColourHexString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPQCheckBannerBackgroundColour];
}

+ (BOOL)PQCheckShouldShowInstructions
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kPQCheckShouldShowInstructions];
}

@end
