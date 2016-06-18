//
//  PQCheckSettings.h
//  Pods
//
//  Created by CJ Tjhai on 08/04/2016.
//
//

#import <Foundation/Foundation.h>

@interface PQCheckSettings : NSObject

+ (NSUInteger)PQCheckFaceLockThreshold;
+ (NSUInteger)PQCheckFaceLockAngleTolerance;
+ (NSString *)PQCheckBannerBackgroundColourHexString;
+ (BOOL)PQCheckShouldShowInstructions;

@end
